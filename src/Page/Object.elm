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
import Data.Dataset as Dataset
import Data.Example as Example
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Object.Db exposing (Db)
import Data.Object.Process as Process exposing (Process)
import Data.Object.Query as Query exposing (Query)
import Data.Object.Simulator as Simulator
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Data.Uuid exposing (Uuid)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import Quantity
import Result.Extra as RE
import Route
import Task
import Views.AutocompleteSelector as AutocompleteSelectorView
import Views.Bookmark as BookmarkView
import Views.Container as Container
import Views.Example as ExampleView
import Views.Format as Format
import Views.Icon as Icon
import Views.Sidebar as SidebarView


type alias Model =
    { initialQuery : Query
    , impact : Definition
    , modal : Modal
    }


type Modal
    = NoModal
    | SelectExampleModal (Autocomplete Query)


type Msg
    = AddItem Query.Item
    | CopyToClipBoard String
    | NoOp
    | OnAutocompleteExample (Autocomplete.Msg Query)
    | OnAutocompleteSelect
    | RemoveItem Process.Id
    | SetModal Modal
    | SwitchImpact (Result String Definition.Trigram)
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
    ( { initialQuery = initialQuery
      , impact = Definition.get trigram session.db.definitions
      , modal = NoModal
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
    ( { initialQuery = exampleQuery
      , impact = Definition.get Definition.Ecs session.db.definitions
      , modal = NoModal
      }
    , session
        |> Session.updateObjectQuery exampleQuery
    , Ports.scrollTo { x = 0, y = 0 }
    )


updateQuery : Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, commands ) =
    ( { model | initialQuery = query }
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

        -- ( OnAutocompleteSelect, AddMaterialModal maybeOldMaterial autocompleteState ) ->
        --     updateMaterial query model session maybeOldMaterial autocompleteState
        ( OnAutocompleteSelect, SelectExampleModal autocompleteState ) ->
            ( model, session, Cmd.none )
                |> selectExample autocompleteState

        ( OnAutocompleteSelect, _ ) ->
            ( model, session, Cmd.none )

        ( RemoveItem processId, _ ) ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.removeItem processId query)

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
        example =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.withDefault Query.default
    in
    update session (SetModal NoModal) { model | initialQuery = example }
        |> updateQuery example



-- massField : String -> Html Msg
-- massField massInput =
--     div [ class "d-flex flex-column" ]
--         [ label [ for "mass", class "form-label text-truncate" ]
--             [ text "Masse du produit fini" ]
--         , div
--             [ class "input-group" ]
--             [ input
--                 [ type_ "number"
--                 , class "form-control"
--                 , id "mass"
--                 , Attr.min "0.01"
--                 , step "0.01"
--                 , value massInput
--                 , onInput UpdateAmount
--                 ]
--                 []
--             , span [ class "input-group-text" ] [ text "kg" ]
--             ]
--         ]


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
            , session.queries.object
                |> itemListView session.db.object model.impact
                |> div [ class "d-flex flex-column bg-white" ]
            ]
        , div [ class "col-lg-4 bg-white" ]
            [ SidebarView.view
                { session = session
                , scope = Scope.Textile

                -- Impact selector
                , selectedImpact = model.impact
                , switchImpact = SwitchImpact

                -- Score
                , customScoreInfo = Nothing
                , productMass = Quantity.zero
                , totalImpacts =
                    Simulator.compute session.db.object session.queries.object
                        |> Result.withDefault Impact.empty

                -- Impacts tabs
                , impactTabsConfig = Nothing

                -- FIXME: bookmarks
                , activeBookmarkTab = BookmarkView.ShareTab
                , bookmarkName = ""
                , copyToClipBoard = CopyToClipBoard
                , compareBookmarks = NoOp
                , deleteBookmark = always NoOp
                , saveBookmark = NoOp
                , updateBookmarkName = always NoOp
                , switchBookmarkTab = always NoOp
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
    li [ class "list-group-item p-0" ]
        [ button
            [ class "btn btn-outline-primary"
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
        ]


itemListView : Db -> Definition -> Query -> List (Html Msg)
itemListView db selectedImpact query =
    [ div [ class "card-header d-flex align-items-center justify-content-between" ]
        [ h2 [ class "h5 mb-0" ] [ text "Éléments" ] ]
    , ul [ class "CardList list-group list-group-flush" ]
        (if List.isEmpty query.items then
            [ li [ class "list-group-item" ] [ text "Aucun éléments" ] ]

         else
            case
                query.items
                    |> List.map (\{ amount, processId } -> ( amount, processId ))
                    |> List.map (RE.combineMapSecond (Process.findById db.processes))
                    |> RE.combine
            of
                Err error ->
                    [ text error ]

                Ok items ->
                    List.map (itemView db selectedImpact) items ++ [ addItemButton db query ]
        )
    ]


itemView : Db -> Definition -> ( Query.Amount, Process ) -> Html Msg
itemView db selectedImpact ( amount, process ) =
    li [ class "list-group-item d-flex align-items-center gap-2" ]
        [ div [ class "input-group w-33" ]
            [ input
                [ type_ "number"
                , class "form-control"
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
            , span [ class "input-group-text" ] [ text process.unit ]
            ]
        , span [ class "flex-fill text-nowrap" ] [ text process.displayName ]
        , span []
            [ { amount = amount, processId = process.id }
                |> itemImpactView db selectedImpact
            ]
        , button
            [ class "btn btn-outline-secondary"
            , onClick (RemoveItem process.id)
            ]
            [ Icon.trash ]
        ]


itemImpactView : Db -> Definition -> Query.Item -> Html Msg
itemImpactView db selectedImpact item =
    item
        |> Simulator.computeItemImpacts db
        |> Result.map (Format.formatImpact selectedImpact)
        |> Result.withDefault (text "N/A")


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Simulateur"
    , [ Container.centered [ class "Simulator pb-3" ]
            [ simulatorView session model
            , case model.modal of
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
