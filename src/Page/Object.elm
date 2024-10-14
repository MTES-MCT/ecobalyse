module Page.Object exposing
    ( Model
    , Msg(..)
    , init
    , initFromExample
    , subscriptions
    , update
    , view
    )

import Autocomplete exposing (Autocomplete)
import Browser.Dom as Dom
import Browser.Events
import Browser.Navigation as Navigation
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Dataset as Dataset
import Data.Example as Example
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Object.Process as Process exposing (Process)
import Data.Object.Query as Query exposing (Query)
import Data.Object.Simulator as Simulator exposing (Results)
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Data.Uuid exposing (Uuid)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import Route
import Static.Db exposing (Db)
import Task
import Time exposing (Posix)
import Views.AutocompleteSelector as AutocompleteSelectorView
import Views.Bookmark as BookmarkView
import Views.Comparator as ComparatorView
import Views.Container as Container
import Views.Example as ExampleView
import Views.Format as Format
import Views.Icon as Icon
import Views.ImpactTabs as ImpactTabs
import Views.Modal as ModalView
import Views.Sidebar as SidebarView


type alias Model =
    { activeImpactsTab : ImpactTabs.Tab
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonType : ComparatorView.ComparisonType
    , impact : Definition
    , initialQuery : Query
    , modal : Modal
    , results : Results
    }


type Modal
    = ComparatorModal
    | NoModal
    | SelectExampleModal (Autocomplete Query)


type Msg
    = AddItem Query.Item
    | CopyToClipBoard String
    | DeleteBookmark Bookmark
    | NoOp
    | OnAutocompleteExample (Autocomplete.Msg Query)
    | OnAutocompleteSelect
    | OpenComparator
    | RemoveItem Process.Id
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SelectAllBookmarks
    | SelectNoBookmarks
    | SetModal Modal
    | SwitchBookmarksTab BookmarkView.ActiveTab
    | SwitchComparisonType ComparatorView.ComparisonType
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactTabs.Tab
    | ToggleComparedSimulation Bookmark Bool
    | UpdateBookmarkName String
    | UpdateItem Query.Item


init : Definition.Trigram -> Maybe Query -> Session -> ( Model, Session, Cmd Msg )
init trigram maybeUrlQuery session =
    let
        initialQuery =
            -- If we received a serialized query from the URL, use it
            -- Otherwise, fallback to use session query
            maybeUrlQuery
                |> Maybe.withDefault session.queries.object
    in
    ( { activeImpactsTab = ImpactTabs.StepImpactsTab
      , bookmarkName = initialQuery |> suggestBookmarkName session
      , bookmarkTab = BookmarkView.SaveTab
      , comparisonType =
            if Session.isAuthenticated session then
                ComparatorView.Subscores

            else
                ComparatorView.Steps
      , impact = Definition.get trigram session.db.definitions
      , initialQuery = initialQuery
      , modal = NoModal
      , results =
            Simulator.compute session.db initialQuery
                |> Result.withDefault Simulator.emptyResults
      }
    , session
        |> Session.updateObjectQuery initialQuery
    , case maybeUrlQuery of
        -- If we do have an URL query, we either come from a bookmark, a saved simulation click or
        -- we're tweaking params for the current simulation: we shouldn't reposition the viewport.
        Just _ ->
            Cmd.none

        -- If we don't have an URL query, we may be coming from another app page, so we should
        -- reposition the viewport at the top.
        Nothing ->
            Ports.scrollTo { x = 0, y = 0 }
    )


initFromExample : Session -> Uuid -> ( Model, Session, Cmd Msg )
initFromExample session uuid =
    let
        example =
            session.db.object.examples
                |> Example.findByUuid uuid

        exampleQuery =
            example
                |> Result.map .query
                |> Result.withDefault session.queries.object
    in
    ( { activeImpactsTab = ImpactTabs.StepImpactsTab
      , bookmarkName = exampleQuery |> suggestBookmarkName session
      , bookmarkTab = BookmarkView.SaveTab
      , comparisonType = ComparatorView.Subscores
      , impact = Definition.get Definition.Ecs session.db.definitions
      , initialQuery = exampleQuery
      , modal = NoModal
      , results =
            Simulator.compute session.db exampleQuery
                |> Result.withDefault Simulator.emptyResults
      }
    , session
        |> Session.updateObjectQuery exampleQuery
    , Ports.scrollTo { x = 0, y = 0 }
    )


suggestBookmarkName : Session -> Query -> String
suggestBookmarkName { db, store } query =
    let
        -- Existing user bookmark?
        userBookmark =
            store.bookmarks
                |> Bookmark.findByObjectQuery query

        -- Matching product example name?
        exampleName =
            db.object.examples
                |> Example.findByQuery query
                |> Result.toMaybe
    in
    case ( userBookmark, exampleName ) of
        ( Just { name }, _ ) ->
            name

        ( _, Just { name } ) ->
            name

        _ ->
            Query.toString db.object.processes query
                |> Result.withDefault "N/A"


updateQuery : Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, commands ) =
    ( { model
        | initialQuery = query
        , bookmarkName =
            query
                |> suggestBookmarkName session
        , results =
            query
                |> Simulator.compute session.db
                |> Result.withDefault Simulator.emptyResults
      }
    , session |> Session.updateObjectQuery query
    , commands
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ queries, navKey } as session) msg model =
    let
        query =
            queries.object
    in
    case ( msg, model.modal ) of
        ( AddItem item, _ ) ->
            update session (SetModal NoModal) model
                |> updateQuery { query | items = item :: query.items }

        ( CopyToClipBoard shareableLink, _ ) ->
            ( model, session, Ports.copyToClipboard shareableLink )

        ( DeleteBookmark bookmark, _ ) ->
            ( model
            , session |> Session.deleteBookmark bookmark
            , Cmd.none
            )

        ( NoOp, _ ) ->
            ( model, session, Cmd.none )

        ( OnAutocompleteExample autocompleteMsg, SelectExampleModal autocompleteState ) ->
            let
                ( newAutocompleteState, autoCompleteCmd ) =
                    Autocomplete.update autocompleteMsg autocompleteState
            in
            ( { model | modal = SelectExampleModal newAutocompleteState }
            , session
            , Cmd.map OnAutocompleteExample autoCompleteCmd
            )

        ( OnAutocompleteExample _, _ ) ->
            ( model, session, Cmd.none )

        ( OnAutocompleteSelect, SelectExampleModal autocompleteState ) ->
            ( model, session, Cmd.none )
                |> selectExample autocompleteState

        ( OnAutocompleteSelect, _ ) ->
            ( model, session, Cmd.none )

        ( OpenComparator, _ ) ->
            ( { model | modal = ComparatorModal }
            , session |> Session.checkComparedSimulations
            , Cmd.none
            )

        ( RemoveItem processId, _ ) ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.removeItem processId query)

        ( SaveBookmark, _ ) ->
            ( model
            , session
            , Time.now
                |> Task.perform
                    (SaveBookmarkWithTime model.bookmarkName
                        (Bookmark.Object query)
                    )
            )

        ( SaveBookmarkWithTime name objectQuery now, _ ) ->
            ( model
            , session
                |> Session.saveBookmark
                    { name = String.trim name
                    , query = objectQuery
                    , created = now
                    }
            , Cmd.none
            )

        ( SelectAllBookmarks, _ ) ->
            ( model, Session.selectAllBookmarks session, Cmd.none )

        ( SelectNoBookmarks, _ ) ->
            ( model, Session.selectNoBookmarks session, Cmd.none )

        ( SetModal ComparatorModal, _ ) ->
            ( { model | modal = ComparatorModal }
            , session
            , Ports.addBodyClass "prevent-scrolling"
            )

        ( SetModal NoModal, _ ) ->
            ( { model | modal = NoModal }
            , session
            , commandsForNoModal model.modal
            )

        ( SetModal (SelectExampleModal autocomplete), _ ) ->
            ( { model | modal = SelectExampleModal autocomplete }
            , session
            , Ports.addBodyClass "prevent-scrolling"
            )

        ( SwitchBookmarksTab bookmarkTab, _ ) ->
            ( { model | bookmarkTab = bookmarkTab }
            , session
            , Cmd.none
            )

        ( SwitchComparisonType displayChoice, _ ) ->
            ( { model | comparisonType = displayChoice }, session, Cmd.none )

        ( SwitchImpact (Ok trigram), _ ) ->
            ( model
            , session
            , Just query
                |> Route.ObjectSimulator trigram
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

        ( SwitchImpact (Err error), _ ) ->
            ( model
            , session |> Session.notifyError "Erreur de sélection d'impact: " error
            , Cmd.none
            )

        ( SwitchImpactsTab impactsTab, _ ) ->
            ( { model | activeImpactsTab = impactsTab }
            , session
            , Cmd.none
            )

        ( ToggleComparedSimulation bookmark checked, _ ) ->
            ( model
            , session |> Session.toggleComparedSimulation bookmark checked
            , Cmd.none
            )

        ( UpdateBookmarkName newName, _ ) ->
            ( { model | bookmarkName = newName }, session, Cmd.none )

        ( UpdateItem item, _ ) ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateItem item query)


commandsForNoModal : Modal -> Cmd Msg
commandsForNoModal modal =
    case modal of
        SelectExampleModal _ ->
            Cmd.batch
                [ Ports.removeBodyClass "prevent-scrolling"
                , Dom.focus "selector-example"
                    |> Task.attempt (always NoOp)
                ]

        _ ->
            Ports.removeBodyClass "prevent-scrolling"


selectExample : Autocomplete Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
selectExample autocompleteState ( model, session, _ ) =
    let
        exampleQuery =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.withDefault Query.default
    in
    update session (SetModal NoModal) { model | initialQuery = exampleQuery }
        |> updateQuery exampleQuery


simulatorView : Session -> Model -> Html Msg
simulatorView session model =
    div [ class "row" ]
        [ div [ class "col-lg-8 bg-white" ]
            [ h1 [ class "visually-hidden" ] [ text "Simulateur " ]
            , div [ class "sticky-md-top bg-white pb-3" ]
                [ ExampleView.view
                    { currentQuery = session.queries.object
                    , emptyQuery = Query.default
                    , examples = session.db.object.examples
                    , helpUrl = Nothing
                    , onOpen = SelectExampleModal >> SetModal
                    , routes =
                        -- FIXME: explore route
                        { explore = Route.Explore Scope.Textile (Dataset.TextileExamples Nothing)
                        , load = Route.ObjectSimulatorExample
                        , scopeHome = Route.ObjectSimulatorHome
                        }
                    }
                ]
            , div [ class "card shadow-sm mb-3" ]
                [ session.queries.object
                    |> itemListView session.db model.impact model.results
                    |> div [ class "d-flex flex-column bg-white" ]
                ]
            ]
        , div [ class "col-lg-4 bg-white" ]
            [ SidebarView.view
                { session = session
                , scope = Scope.Object

                -- Impact selector
                , selectedImpact = model.impact
                , switchImpact = SwitchImpact

                -- Score
                , customScoreInfo = Nothing
                , productMass = Simulator.extractMass model.results
                , totalImpacts = Simulator.extractImpacts model.results

                -- Impacts tabs
                , impactTabsConfig =
                    SwitchImpactsTab
                        |> ImpactTabs.createConfig session model.impact model.activeImpactsTab (always NoOp)
                        |> ImpactTabs.forObject model.results
                        |> Just

                -- Bookmarks
                , activeBookmarkTab = model.bookmarkTab
                , bookmarkName = model.bookmarkName
                , copyToClipBoard = CopyToClipBoard
                , compareBookmarks = OpenComparator
                , deleteBookmark = DeleteBookmark
                , saveBookmark = SaveBookmark
                , updateBookmarkName = UpdateBookmarkName
                , switchBookmarkTab = SwitchBookmarksTab
                }
            ]
        ]


addItemButton : Db -> Query -> Html Msg
addItemButton db query =
    let
        firstAvailableProcess =
            query
                |> Simulator.availableProcesses db
                |> List.head
    in
    button
        [ class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class " gap-1 w-100"
        , id "add-new-element"
        , disabled <| firstAvailableProcess == Nothing
        , onClick <|
            case firstAvailableProcess of
                Just process ->
                    AddItem (Query.defaultItem process)

                Nothing ->
                    NoOp
        ]
        [ i [ class "icon icon-plus" ] []
        , text "Ajouter un élément"
        ]


itemListView : Db -> Definition -> Results -> Query -> List (Html Msg)
itemListView db selectedImpact results query =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 mb-0" ] [ text "Éléments" ] ]
    , div [ class "table-responsive" ]
        [ table [ class "table mb-0" ]
            [ thead []
                [ tr [ class "fs-7 text-muted" ]
                    [ th [] [ text "Quantité" ]
                    , th [] [ text "Procédé" ]
                    , th [] [ text "Densité" ]
                    , th [] [ text "Masse" ]
                    , th [] [ text "Impact" ]
                    , th [] []
                    ]
                ]
            , tbody []
                (if List.isEmpty query.items then
                    [ tr [] [ td [] [ text "Aucun élément." ] ] ]

                 else
                    case Simulator.expandItems db query of
                        Err error ->
                            [ tr [] [ td [ class "text-danger" ] [ text "Error: ", text error ] ] ]

                        Ok items ->
                            Simulator.extractItems results
                                |> List.map2 (itemView selectedImpact) items
                )
            ]
        ]
    , addItemButton db query
    ]


itemView : Definition -> ( Query.Amount, Process ) -> Results -> Html Msg
itemView selectedImpact ( amount, process ) itemResults =
    tr []
        [ td [ class "input-group text-nowrap", style "min-width" "180px" ]
            [ input
                [ type_ "number"
                , class "form-control text-end"
                , amount |> Query.amountToFloat |> String.fromFloat |> value
                , step <|
                    case process.unit of
                        "kg" ->
                            "0.01"

                        "m3" ->
                            "0.00001"

                        _ ->
                            "1"
                , onInput <|
                    \str ->
                        case String.toFloat str of
                            Just float ->
                                UpdateItem { amount = Query.amount float, processId = process.id }

                            Nothing ->
                                NoOp
                ]
                []
            , span [ class "input-group-text justify-content-center fs-8", style "width" "38px" ]
                [ text process.unit ]
            ]
        , td [ class "align-middle text-truncate w-100" ]
            [ text process.displayName ]
        , td [ class "align-middle text-end" ]
            [ if process.unit /= "kg" then
                process.density |> Format.formatRichFloat 0 ("kg/" ++ process.unit)

              else
                text ""
            ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ Format.kg <| Simulator.extractMass itemResults ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ Format.formatImpact selectedImpact <| Simulator.extractImpacts itemResults ]
        , td [ class "align-middle text-nowrap" ]
            [ button [ class "btn btn-outline-secondary", onClick (RemoveItem process.id) ] [ Icon.trash ] ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Simulateur"
    , [ Container.centered [ class "Simulator pb-3" ]
            [ simulatorView session model
            , case model.modal of
                ComparatorModal ->
                    ModalView.view
                        { size = ModalView.ExtraLarge
                        , close = SetModal NoModal
                        , noOp = NoOp
                        , title = "Comparateur de simulations sauvegardées"
                        , subTitle = Just "en score d'impact, par produit"
                        , formAction = Nothing
                        , content =
                            [ ComparatorView.view
                                { session = session
                                , impact = model.impact
                                , comparisonType = model.comparisonType
                                , selectAll = SelectAllBookmarks
                                , selectNone = SelectNoBookmarks
                                , switchComparisonType = SwitchComparisonType
                                , toggle = ToggleComparedSimulation
                                }
                            ]
                        , footer = []
                        }

                NoModal ->
                    text ""

                SelectExampleModal autocompleteState ->
                    AutocompleteSelectorView.view
                        { autocompleteState = autocompleteState
                        , closeModal = SetModal NoModal
                        , footer = []
                        , noOp = NoOp
                        , onAutocomplete = OnAutocompleteExample
                        , onAutocompleteSelect = OnAutocompleteSelect
                        , placeholderText = "tapez ici le nom du produit pour le rechercher"
                        , title = "Sélectionnez un produit"
                        , toLabel = Example.toName session.db.object.examples
                        , toCategory = Example.toCategory session.db.object.examples
                        }
            ]
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        NoModal ->
            Sub.none

        _ ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))
