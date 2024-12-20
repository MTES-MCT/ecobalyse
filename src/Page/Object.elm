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
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Component as Component exposing (Component, ComponentItem)
import Data.Dataset as Dataset
import Data.Example as Example exposing (Example)
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Object.Query as Query exposing (Query)
import Data.Object.Simulator as Simulator exposing (Results)
import Data.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Data.Uuid exposing (Uuid)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Ports
import Route
import Static.Db exposing (Db)
import Task
import Time exposing (Posix)
import Views.Alert as Alert
import Views.AutocompleteSelector as AutocompleteSelectorView
import Views.Bookmark as BookmarkView
import Views.Comparator as ComparatorView
import Views.Container as Container
import Views.Example as ExampleView
import Views.Format as Format
import Views.Icon as Icon
import Views.ImpactTabs as ImpactTabs
import Views.Link as Link
import Views.Modal as ModalView
import Views.Sidebar as SidebarView


type alias Model =
    { activeImpactsTab : ImpactTabs.Tab
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonType : ComparatorView.ComparisonType
    , detailedComponents : List Component.Id
    , examples : List (Example Query)
    , impact : Definition
    , initialQuery : Query
    , modal : Modal
    , results : Results
    , scope : Scope
    }


type Modal
    = AddComponentModal (Autocomplete Component)
    | ComparatorModal
    | NoModal
    | SelectExampleModal (Autocomplete Query)


type Msg
    = CopyToClipBoard String
    | DeleteBookmark Bookmark
    | NoOp
    | OnAutocompleteAddComponent (Autocomplete.Msg Component)
    | OnAutocompleteExample (Autocomplete.Msg Query)
    | OnAutocompleteSelect
    | OnAutocompleteSelectComponent
    | OpenComparator
    | RemoveComponentItem Component.Id
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SelectAllBookmarks
    | SelectNoBookmarks
    | SetDetailedComponents (List Component.Id)
    | SetModal Modal
    | SwitchBookmarksTab BookmarkView.ActiveTab
    | SwitchComparisonType ComparatorView.ComparisonType
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactTabs.Tab
    | ToggleComparedSimulation Bookmark Bool
    | UpdateBookmarkName String
    | UpdateComponentItem ComponentItem


init : Scope -> Definition.Trigram -> Maybe Query -> Session -> ( Model, Session, Cmd Msg )
init scope trigram maybeUrlQuery session =
    let
        initialQuery =
            -- If we received a serialized query from the URL, use it
            -- Otherwise, fallback to use session query
            maybeUrlQuery
                |> Maybe.withDefault (Session.objectQueryFromScope scope session)

        examples =
            session.db.object.examples
                |> Example.forScope scope
    in
    ( { activeImpactsTab = ImpactTabs.StepImpactsTab
      , bookmarkName = initialQuery |> suggestBookmarkName session examples
      , bookmarkTab = BookmarkView.SaveTab
      , comparisonType =
            if Session.isAuthenticated session then
                ComparatorView.Subscores

            else
                ComparatorView.Steps
      , detailedComponents = []
      , examples = examples
      , impact = Definition.get trigram session.db.definitions
      , initialQuery = initialQuery
      , modal = NoModal
      , results =
            Simulator.compute session.db initialQuery
                |> Result.withDefault Simulator.emptyResults
      , scope = scope
      }
    , session
        |> Session.updateObjectQuery scope initialQuery
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


initFromExample : Session -> Scope -> Uuid -> ( Model, Session, Cmd Msg )
initFromExample session scope uuid =
    let
        examples =
            session.db.object.examples
                |> Example.forScope scope

        example =
            examples
                |> Example.findByUuid uuid

        exampleQuery =
            example
                |> Result.map .query
                |> Result.withDefault (Session.objectQueryFromScope scope session)
    in
    ( { activeImpactsTab = ImpactTabs.StepImpactsTab
      , bookmarkName = exampleQuery |> suggestBookmarkName session examples
      , bookmarkTab = BookmarkView.SaveTab
      , comparisonType = ComparatorView.Subscores
      , detailedComponents = []
      , examples = examples
      , impact = Definition.get Definition.Ecs session.db.definitions
      , initialQuery = exampleQuery
      , modal = NoModal
      , results =
            Simulator.compute session.db exampleQuery
                |> Result.withDefault Simulator.emptyResults
      , scope = scope
      }
    , session
        |> Session.updateObjectQuery scope exampleQuery
    , Ports.scrollTo { x = 0, y = 0 }
    )


suggestBookmarkName : Session -> List (Example Query) -> Query -> String
suggestBookmarkName { db, store } examples query =
    let
        -- Existing user bookmark?
        userBookmark =
            store.bookmarks
                |> Bookmark.findByObjectQuery query

        -- Matching product example name?
        exampleName =
            examples
                |> Example.findByQuery query
                |> Result.toMaybe
    in
    case ( userBookmark, exampleName ) of
        ( Just { name }, _ ) ->
            name

        ( _, Just { name } ) ->
            name

        _ ->
            Query.toString db.object.components db.object.processes query
                |> Result.withDefault "N/A"


updateQuery : Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, commands ) =
    ( { model
        | initialQuery = query
        , bookmarkName =
            query
                |> suggestBookmarkName session model.examples
        , results =
            query
                |> Simulator.compute session.db
                |> Result.withDefault Simulator.emptyResults
      }
    , session |> Session.updateObjectQuery model.scope query
    , commands
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ navKey } as session) msg model =
    let
        query =
            session
                |> Session.objectQueryFromScope model.scope
    in
    case ( msg, model.modal ) of
        ( CopyToClipBoard shareableLink, _ ) ->
            ( model, session, Ports.copyToClipboard shareableLink )

        ( DeleteBookmark bookmark, _ ) ->
            ( model
            , session |> Session.deleteBookmark bookmark
            , Cmd.none
            )

        ( NoOp, _ ) ->
            ( model, session, Cmd.none )

        ( OnAutocompleteAddComponent autocompleteMsg, AddComponentModal autocompleteState ) ->
            let
                ( newAutocompleteState, autoCompleteCmd ) =
                    Autocomplete.update autocompleteMsg autocompleteState
            in
            ( { model | modal = AddComponentModal newAutocompleteState }
            , session
            , Cmd.map OnAutocompleteAddComponent autoCompleteCmd
            )

        ( OnAutocompleteAddComponent _, _ ) ->
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

        ( OnAutocompleteSelectComponent, AddComponentModal autocompleteState ) ->
            ( model, session, Cmd.none )
                |> selectComponent query autocompleteState

        ( OnAutocompleteSelectComponent, _ ) ->
            ( model, session, Cmd.none )

        ( OpenComparator, _ ) ->
            ( { model | modal = ComparatorModal }
            , session |> Session.checkComparedSimulations
            , Cmd.none
            )

        ( RemoveComponentItem id, _ ) ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.removeComponent id query)

        ( SaveBookmark, _ ) ->
            ( model
            , session
            , Time.now
                |> Task.perform
                    (SaveBookmarkWithTime model.bookmarkName
                        (if model.scope == Scope.Veli then
                            Bookmark.Veli query

                         else
                            Bookmark.Object query
                        )
                    )
            )

        ( SaveBookmarkWithTime name objectQuery now, _ ) ->
            ( model
            , session
                |> Session.saveBookmark
                    { name = String.trim name
                    , query = objectQuery
                    , created = now
                    , subScope = Just model.scope
                    }
            , Cmd.none
            )

        ( SelectAllBookmarks, _ ) ->
            ( model, Session.selectAllBookmarks session, Cmd.none )

        ( SelectNoBookmarks, _ ) ->
            ( model, Session.selectNoBookmarks session, Cmd.none )

        ( SetDetailedComponents detailedComponents, _ ) ->
            ( { model | detailedComponents = LE.unique detailedComponents }
            , session
            , Cmd.none
            )

        ( SetModal (AddComponentModal autocomplete), _ ) ->
            ( { model | modal = AddComponentModal autocomplete }
            , session
            , Ports.addBodyClass "prevent-scrolling"
            )

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
                |> Route.ObjectSimulator model.scope trigram
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

        ( UpdateComponentItem component, _ ) ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateComponentItem component query)


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


selectComponent : Query -> Autocomplete Component -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
selectComponent query autocompleteState ( model, session, _ ) =
    case Autocomplete.selectedValue autocompleteState of
        Just component ->
            update session (SetModal NoModal) model
                |> updateQuery (Query.addComponentItem component.id query)

        Nothing ->
            ( model, session |> Session.notifyError "Erreur" "Aucun composant sélectionné", Cmd.none )


simulatorView : Session -> Model -> Html Msg
simulatorView session model =
    div [ class "row" ]
        [ div [ class "col-lg-8 bg-white" ]
            [ h1 [ class "visually-hidden" ] [ text "Simulateur " ]
            , div [ class "sticky-md-top bg-white pb-3" ]
                [ ExampleView.view
                    { currentQuery = session |> Session.objectQueryFromScope model.scope
                    , emptyQuery = Query.default
                    , examples = model.examples
                    , helpUrl = Nothing
                    , onOpen = SelectExampleModal >> SetModal
                    , routes =
                        -- FIXME: explore route object/veli
                        { explore = Route.Explore model.scope (Dataset.ObjectExamples Nothing)
                        , load = Route.ObjectSimulatorExample model.scope
                        , scopeHome = Route.ObjectSimulatorHome model.scope
                        }
                    }
                ]
            , session
                |> Session.objectQueryFromScope model.scope
                |> componentListView session.db model
                |> div [ class "card shadow-sm mb-3" ]
            ]
        , div [ class "col-lg-4 bg-white" ]
            [ SidebarView.view
                { session = session
                , scope = model.scope

                -- Impact selector
                , selectedImpact = model.impact
                , switchImpact = SwitchImpact

                -- Score
                , customScoreInfo = Nothing
                , productMass = Simulator.extractMass model.results
                , totalImpacts = Simulator.extractImpacts model.results
                , totalImpactsWithoutDurability = Nothing

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


addComponentButton : Db -> Query -> Html Msg
addComponentButton db query =
    let
        availableComponents =
            Simulator.availableComponents db query

        autocompleteState =
            AutocompleteSelector.init .name availableComponents
    in
    button
        [ class "btn btn-outline-primary w-100"
        , class "d-flex justify-content-center align-items-center"
        , class "gap-1 w-100"
        , id "add-new-element"
        , disabled <| List.length availableComponents == 0
        , onClick (SetModal (AddComponentModal autocompleteState))
        ]
        [ i [ class "icon icon-plus" ] []
        , text "Ajouter un composant"
        ]


componentListView : Db -> Model -> Query -> List (Html Msg)
componentListView db { detailedComponents, impact, results } query =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 mb-0" ]
            [ text "Production des composants"
            , Link.smallPillExternal
                -- FIXME: link to Veli explorer?
                [ Route.href (Route.Explore Scope.Object (Dataset.ObjectProcesses Nothing))
                , title "Explorer"
                , attribute "aria-label" "Explorer"
                ]
                [ Icon.search ]
            ]
        ]
    , if List.isEmpty query.components then
        div [ class "card-body" ] [ text "Aucun élément." ]

      else
        case Component.expandComponentItems db.object query.components of
            Err error ->
                Alert.simple
                    { close = Nothing
                    , content = [ text error ]
                    , level = Alert.Danger
                    , title = Just "Erreur"
                    }

            Ok elements ->
                div [ class "table-responsive" ]
                    [ table [ class "table mb-0" ]
                        [ thead []
                            [ tr [ class "fs-7 text-muted" ]
                                [ th [] []
                                , th [ class "ps-0", scope "col" ] [ text "Quantité" ]
                                , th [ scope "col", colspan 2 ] [ text "Composant" ]
                                , th [ scope "col" ] [ text "Masse" ]
                                , th [ scope "col" ] [ text "Impact" ]
                                , th [ scope "col" ] []
                                ]
                            ]
                        , Simulator.extractItems results
                            |> List.map2 (componentView impact detailedComponents) elements
                            |> List.concat
                            |> tbody []
                        ]
                    ]
    , addComponentButton db query
    ]


componentView : Definition -> List Component.Id -> ( Component.Quantity, Component, List ( Component.Amount, Process ) ) -> Results -> List (Html Msg)
componentView selectedImpact detailedComponents ( quantity, component, processAmounts ) itemResults =
    let
        collapsed =
            not <| List.member component.id detailedComponents
    in
    List.concat
        [ [ tr []
                [ th [ class "ps-3 align-middle", scope "col" ]
                    [ button
                        [ class "btn btn-link text-dark text-decoration-none font-monospace fs-5  p-0 m-0"
                        , onClick <|
                            SetDetailedComponents
                                (if collapsed && not (List.member component.id detailedComponents) then
                                    LE.unique <| component.id :: detailedComponents

                                 else
                                    List.filter ((/=) component.id) detailedComponents
                                )
                        ]
                        [ if collapsed then
                            text "▶"

                          else
                            text "▼"
                        ]
                    ]
                , td [ class "ps-0 align-middle" ]
                    [ quantity |> quantityInput component.id ]
                , td [ class "align-middle text-truncate w-100 fw-bold", colspan 2 ]
                    [ text component.name ]
                , td [ class "text-end align-middle text-nowrap" ]
                    [ Simulator.extractMass itemResults
                        |> Format.kg
                    ]
                , td [ class "text-end align-middle text-nowrap" ]
                    [ Simulator.extractImpacts itemResults
                        |> Format.formatImpact selectedImpact
                    ]
                , td [ class "pe-3 align-middle text-nowrap" ]
                    [ button [ class "btn btn-outline-secondary", onClick (RemoveComponentItem component.id) ]
                        [ Icon.trash ]
                    ]
                ]
          , if not collapsed then
                tr [ class "fs-7 text-muted" ]
                    [ th [] []
                    , th [ class "text-end", scope "col" ] [ text "Quantité" ]
                    , th [ scope "col" ] [ text "Procédé" ]
                    , th [ scope "col" ] [ text "Densité" ]
                    , th [ scope "col" ] [ text "Masse" ]
                    , th [ scope "col" ] [ text "Impact" ]
                    , th [ scope "col" ] [ text "" ]
                    ]

            else
                text ""
          ]
        , if not collapsed then
            Simulator.extractItems itemResults
                |> List.map2 (processView selectedImpact) processAmounts

          else
            []
        ]


processView : Definition -> ( Component.Amount, Process ) -> Results -> Html Msg
processView selectedImpact ( amount, process ) itemResults =
    tr [ class "fs-7" ]
        [ td [] []
        , td [ class "text-end text-nowrap" ]
            [ Format.amount process amount ]
        , td [ class "align-middle text-truncate w-100" ]
            [ text <| Process.getDisplayName process ]
        , td [ class "align-middle text-end text-nowrap" ]
            [ Format.density process ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ Format.kg <| Simulator.extractMass itemResults ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ Simulator.extractImpacts itemResults
                |> Format.formatImpact selectedImpact
            ]
        , td [ class "pe-3 align-middle text-nowrap" ]
            []
        ]


quantityInput : Component.Id -> Component.Quantity -> Html Msg
quantityInput id quantity =
    div [ class "input-group", style "min-width" "90px", style "max-width" "120px" ]
        [ input
            [ type_ "number"
            , class "form-control text-end"
            , quantity |> Component.quantityToInt |> String.fromInt |> value
            , step "1"
            , Html.Attributes.min "1"
            , onInput <|
                \str ->
                    String.toInt str
                        |> Maybe.andThen
                            (\int ->
                                if int > 0 then
                                    Just int

                                else
                                    Nothing
                            )
                        |> Maybe.map
                            (\nonNullInt ->
                                UpdateComponentItem
                                    { id = id
                                    , quantity = Component.quantityFromInt nonNullInt
                                    }
                            )
                        |> Maybe.withDefault NoOp
            ]
            []
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Simulateur"
    , [ Container.centered [ class "Simulator pb-3" ]
            [ simulatorView session model
            , case model.modal of
                AddComponentModal autocompleteState ->
                    AutocompleteSelectorView.view
                        { autocompleteState = autocompleteState
                        , closeModal = SetModal NoModal
                        , footer = []
                        , noOp = NoOp
                        , onAutocomplete = OnAutocompleteAddComponent
                        , onAutocompleteSelect = OnAutocompleteSelectComponent
                        , placeholderText = "tapez ici le nom du composant pour le rechercher"
                        , title = "Sélectionnez un composant"
                        , toLabel = .name
                        , toCategory = \_ -> ""
                        }

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
                        , toLabel = Example.toName model.examples
                        , toCategory = Example.toCategory model.examples
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
