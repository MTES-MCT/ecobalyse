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
import Data.Component as Component exposing (Component, TargetElement, TargetItem)
import Data.Dataset as Dataset
import Data.Example as Example exposing (Example)
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Object.Query as Query exposing (Query)
import Data.Object.Simulator as Simulator
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Data.Uuid exposing (Uuid)
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Extra as LE
import Ports
import Request.Version as Version
import Route
import Task
import Time exposing (Posix)
import Views.AutocompleteSelector as AutocompleteSelectorView
import Views.Bookmark as BookmarkView
import Views.Comparator as ComparatorView
import Views.Component as ComponentView
import Views.Container as Container
import Views.Example as ExampleView
import Views.ImpactTabs as ImpactTabs
import Views.Modal as ModalView
import Views.Sidebar as SidebarView


type alias Model =
    { activeImpactsTab : ImpactTabs.Tab
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonType : ComparatorView.ComparisonType
    , detailedComponents : List Int
    , examples : List (Example Query)
    , impact : Definition
    , initialQuery : Query
    , modal : Modal
    , results : Component.Results
    , scope : Scope
    }


type Modal
    = AddComponentModal (Autocomplete Component)
    | ComparatorModal
    | NoModal
    | SelectExampleModal (Autocomplete Query)
    | SelectProcessModal Category TargetItem (Maybe Int) (Autocomplete Process)


type Msg
    = CopyToClipBoard String
    | DeleteBookmark Bookmark
    | NoOp
    | OnAutocompleteAddComponent (Autocomplete.Msg Component)
    | OnAutocompleteAddProcess Category TargetItem (Maybe Int) (Autocomplete.Msg Process)
    | OnAutocompleteExample (Autocomplete.Msg Query)
    | OnAutocompleteSelect
    | OnAutocompleteSelectComponent
    | OnAutocompleteSelectProcess Category TargetItem (Maybe Int)
    | OpenComparator
    | RemoveComponentItem Int
    | RemoveElement TargetElement
    | RemoveElementTransform TargetElement Int
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SelectAllBookmarks
    | SelectNoBookmarks
    | SetDetailedComponents (List Int)
    | SetModal Modal
    | SwitchBookmarksTab BookmarkView.ActiveTab
    | SwitchComparisonType ComparatorView.ComparisonType
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactTabs.Tab
    | ToggleComparedSimulation Bookmark Bool
    | UpdateBookmarkName String
    | UpdateComponentItemName TargetItem String
    | UpdateComponentItemQuantity Int Component.Quantity
    | UpdateElementAmount TargetElement (Maybe Component.Amount)


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
                |> Result.withDefault Component.emptyResults
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
                |> Result.withDefault Component.emptyResults
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
            Query.toString db.components db.processes query
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
                |> Result.withDefault Component.emptyResults
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

        ( OnAutocompleteAddProcess processType targetItem maybeIndex autocompleteMsg, SelectProcessModal _ _ _ autocompleteState ) ->
            let
                ( newAutocompleteState, autoCompleteCmd ) =
                    Autocomplete.update autocompleteMsg autocompleteState
            in
            ( { model | modal = SelectProcessModal processType targetItem maybeIndex newAutocompleteState }
            , session
            , Cmd.map (OnAutocompleteAddProcess processType targetItem maybeIndex) autoCompleteCmd
            )

        ( OnAutocompleteAddProcess _ _ _ _, _ ) ->
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

        ( OnAutocompleteSelectProcess processType targetItem elementIndex, SelectProcessModal _ _ _ autocompleteState ) ->
            ( model, session, Cmd.none )
                |> selectProcess processType targetItem elementIndex autocompleteState query

        ( OnAutocompleteSelectProcess _ _ _, _ ) ->
            ( model, session, Cmd.none )

        ( OpenComparator, _ ) ->
            ( { model | modal = ComparatorModal }
            , session |> Session.checkComparedSimulations
            , Cmd.none
            )

        ( RemoveComponentItem itemIndex, _ ) ->
            ( { model | detailedComponents = [] }, session, Cmd.none )
                |> updateQuery (Query.removeComponent itemIndex query)

        ( RemoveElement targetElement, _ ) ->
            case Query.removeElement targetElement query of
                Err err ->
                    ( model, session |> Session.notifyError "Erreur" err, Cmd.none )

                Ok query_ ->
                    updateQuery query_ ( model, session, Cmd.none )

        ( RemoveElementTransform targetElement transformIndex, _ ) ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.removeElementTransform targetElement transformIndex query)

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
                    , version = Version.toMaybe session.currentVersion
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

        ( SetModal NoModal, _ ) ->
            ( { model | modal = NoModal }
            , session
            , commandsForNoModal model.modal
            )

        ( SetModal modal, _ ) ->
            ( { model | modal = modal }
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

        ( UpdateComponentItemName targetItem name, _ ) ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateComponentItemName targetItem name query)

        ( UpdateComponentItemQuantity itemIndex quantity, _ ) ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateComponentItemQuantity itemIndex quantity query)

        ( UpdateElementAmount _ Nothing, _ ) ->
            ( model, session, Cmd.none )

        ( UpdateElementAmount targetElement (Just amount), _ ) ->
            ( model, session, Cmd.none )
                |> updateQuery (Query.updateElementAmount targetElement amount query)


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


selectProcess : Category -> TargetItem -> Maybe Int -> Autocomplete Process -> Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
selectProcess category targetItem maybeElementIndex autocompleteState query ( model, session, _ ) =
    case Autocomplete.selectedValue autocompleteState of
        Just process ->
            case Query.addOrSetProcess category targetItem maybeElementIndex process query of
                Err err ->
                    ( model, session |> Session.notifyError "Erreur" err, Cmd.none )

                Ok validQuery ->
                    update session (SetModal NoModal) model
                        |> updateQuery validQuery

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
            , ComponentView.editorView
                { addLabel = "Ajouter un composant"
                , customizable = True
                , db = session.db
                , detailed = model.detailedComponents
                , docsUrl = Nothing
                , impact = model.impact
                , items =
                    session
                        |> Session.objectQueryFromScope model.scope
                        |> .components
                , noOp = NoOp
                , openSelectComponentModal = AddComponentModal >> SetModal
                , openSelectProcessModal =
                    \p ti ei s ->
                        SelectProcessModal p ti ei s
                            |> SetModal
                , removeElement = RemoveElement
                , removeElementTransform = RemoveElementTransform
                , removeItem = RemoveComponentItem
                , results = model.results
                , scope = model.scope
                , setDetailed = SetDetailedComponents
                , title = "Production des composants"
                , updateElementAmount = UpdateElementAmount
                , updateItemName = UpdateComponentItemName
                , updateItemQuantity = UpdateComponentItemQuantity
                }
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
                , productMass = Component.extractMass model.results
                , totalImpacts = Component.extractImpacts model.results
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

                SelectProcessModal processType targetItem maybeElementIndex autocompleteState ->
                    let
                        ( placeholderText, title ) =
                            case processType of
                                Category.Material ->
                                    ( "tapez ici le nom d'une matière pour la rechercher"
                                    , "Sélectionnez une matière première"
                                    )

                                Category.Transform ->
                                    ( "tapez ici le nom d'un procédé de transformation pour le rechercher"
                                    , "Sélectionnez un procédé de transformation"
                                    )

                                _ ->
                                    ( "tapez ici le nom d'un procédé pour le rechercher"
                                    , "Sélectionnez un procédé"
                                    )
                    in
                    AutocompleteSelectorView.view
                        { autocompleteState = autocompleteState
                        , closeModal = SetModal NoModal
                        , footer = []
                        , noOp = NoOp
                        , onAutocomplete = OnAutocompleteAddProcess processType targetItem maybeElementIndex
                        , onAutocompleteSelect = OnAutocompleteSelectProcess processType targetItem maybeElementIndex
                        , placeholderText = placeholderText
                        , title = title
                        , toLabel = Process.getDisplayName
                        , toCategory = \_ -> ""
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
