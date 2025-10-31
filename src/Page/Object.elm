module Page.Object exposing
    ( Model
    , Msg(..)
    , init
    , initFromExample
    , subscriptions
    , update
    , view
    )

import App exposing (PageUpdate)
import Autocomplete exposing (Autocomplete)
import Browser.Events
import Browser.Navigation as Navigation
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Component as Component exposing (Component, Index, TargetElement, TargetItem)
import Data.Dataset as Dataset
import Data.Env as Env
import Data.Example as Example exposing (Example)
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Object.Query as Query exposing (Query)
import Data.Object.Simulator as Simulator
import Data.Plausible as Plausible
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Scope as Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Data.Uuid exposing (Uuid)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Ports
import Request.Version as Version
import Route
import Task
import Time exposing (Posix)
import Views.AutocompleteSelector as AutocompleteSelectorView
import Views.Bookmark as BookmarkView
import Views.Button as Button
import Views.Comparator as ComparatorView
import Views.Component as ComponentView
import Views.Container as Container
import Views.Example as ExampleView
import Views.Format as Format
import Views.Icon as Icon
import Views.ImpactTabs as ImpactTabs
import Views.Modal as ModalView
import Views.RangeSlider as RangeSlider
import Views.Sidebar as SidebarView


type alias Model =
    { activeImpactsTab : ImpactTabs.Tab
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonType : ComparatorView.ComparisonType
    , detailedComponents : List Index
    , examples : List (Example Query)
    , impact : Definition
    , initialQuery : Query
    , modal : Modal
    , lifeCycle : Result String Component.LifeCycle
    , scope : Scope
    }


type Modal
    = AddComponentModal (Autocomplete Component)
    | ComparatorModal
    | NoModal
    | SelectExampleModal (Autocomplete Query)
    | SelectProcessModal Category TargetItem (Maybe Index) (Autocomplete Process)


type Msg
    = CopyToClipBoard String
    | DeleteBookmark Bookmark
    | NoOp
    | OnAutocompleteAddComponent (Autocomplete.Msg Component)
    | OnAutocompleteAddProcess Category TargetItem (Maybe Index) (Autocomplete.Msg Process)
    | OnAutocompleteExample (Autocomplete.Msg Query)
    | OnAutocompleteSelectComponent
    | OnAutocompleteSelectExample
    | OnAutocompleteSelectProcess Category TargetItem (Maybe Index)
    | OpenComparator
    | RemoveComponentItem Int
    | RemoveElement TargetElement
    | RemoveElementTransform TargetElement Index
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SelectAllBookmarks
    | SelectNoBookmarks
    | SetDetailedComponents (List Index)
    | SetModal Modal
    | SwitchBookmarksTab BookmarkView.ActiveTab
    | SwitchComparisonType ComparatorView.ComparisonType
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactTabs.Tab
    | ToggleComparedSimulation Bookmark Bool
    | UpdateBookmarkName String
    | UpdateComponentItemName TargetItem String
    | UpdateComponentItemQuantity Index Component.Quantity
    | UpdateDurability (Result String Unit.Ratio)
    | UpdateElementAmount TargetElement (Maybe Component.Amount)


init : Scope -> Definition.Trigram -> Maybe Query -> Session -> PageUpdate Model Msg
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
    { activeImpactsTab = ImpactTabs.StepImpactsTab
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
    , lifeCycle =
        initialQuery
            |> Simulator.compute
                { config = session.componentConfig
                , db = session.db
                , scope = scope
                }
    , scope = scope
    }
        |> App.createUpdate (session |> Session.updateObjectQuery scope initialQuery)
        |> App.withCmds
            (case maybeUrlQuery of
                -- If we do have an URL query, we either come from a bookmark, a saved simulation click or
                -- we're tweaking params for the current simulation: we shouldn't reposition the viewport.
                Just _ ->
                    []

                -- If we don't have an URL query, we may be coming from another app page, so we should
                -- reposition the viewport at the top.
                Nothing ->
                    [ Ports.scrollTo { x = 0, y = 0 } ]
            )


initFromExample : Session -> Scope -> Uuid -> PageUpdate Model Msg
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
    { activeImpactsTab = ImpactTabs.StepImpactsTab
    , bookmarkName = exampleQuery |> suggestBookmarkName session examples
    , bookmarkTab = BookmarkView.SaveTab
    , comparisonType = ComparatorView.Subscores
    , detailedComponents = []
    , examples = examples
    , impact = Definition.get Definition.Ecs session.db.definitions
    , initialQuery = exampleQuery
    , modal = NoModal
    , lifeCycle =
        exampleQuery
            |> Simulator.compute
                { config = session.componentConfig
                , db = session.db
                , scope = scope
                }
    , scope = scope
    }
        |> App.createUpdate (session |> Session.updateObjectQuery scope exampleQuery)
        |> App.withCmds [ Ports.scrollTo { x = 0, y = 0 } ]


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
            query.components
                |> Component.itemsToString db
                |> Result.withDefault "N/A"


updateQuery : Query -> PageUpdate Model Msg -> PageUpdate Model Msg
updateQuery query ({ model, session } as pageUpdate) =
    { pageUpdate
        | model =
            { model
                | initialQuery = query
                , bookmarkName = query |> suggestBookmarkName session model.examples
                , lifeCycle =
                    query
                        |> Simulator.compute
                            { config = session.componentConfig
                            , db = session.db
                            , scope = model.scope
                            }
            }
        , session = session |> Session.updateObjectQuery model.scope query
    }


update : Session -> Msg -> Model -> PageUpdate Model Msg
update ({ navKey } as session) msg model =
    let
        query =
            session
                |> Session.objectQueryFromScope model.scope
    in
    case ( msg, model.modal ) of
        ( CopyToClipBoard shareableLink, _ ) ->
            App.createUpdate session model
                |> App.withCmds [ Ports.copyToClipboard shareableLink ]

        ( DeleteBookmark bookmark, _ ) ->
            model
                |> App.createUpdate (session |> Session.deleteBookmark bookmark)

        ( NoOp, _ ) ->
            App.createUpdate session model

        ( OnAutocompleteAddComponent autocompleteMsg, AddComponentModal autocompleteState ) ->
            let
                ( newAutocompleteState, autoCompleteCmd ) =
                    Autocomplete.update autocompleteMsg autocompleteState
            in
            { model | modal = AddComponentModal newAutocompleteState }
                |> App.createUpdate session
                |> App.withCmds [ Cmd.map OnAutocompleteAddComponent autoCompleteCmd ]

        ( OnAutocompleteAddComponent _, _ ) ->
            App.createUpdate session model

        ( OnAutocompleteAddProcess category targetItem maybeIndex autocompleteMsg, SelectProcessModal _ _ _ autocompleteState ) ->
            let
                ( newAutocompleteState, autoCompleteCmd ) =
                    Autocomplete.update autocompleteMsg autocompleteState
            in
            { model | modal = SelectProcessModal category targetItem maybeIndex newAutocompleteState }
                |> App.createUpdate session
                |> App.withCmds [ Cmd.map (OnAutocompleteAddProcess category targetItem maybeIndex) autoCompleteCmd ]

        ( OnAutocompleteAddProcess _ _ _ _, _ ) ->
            App.createUpdate session model

        ( OnAutocompleteExample autocompleteMsg, SelectExampleModal autocompleteState ) ->
            let
                ( newAutocompleteState, autoCompleteCmd ) =
                    Autocomplete.update autocompleteMsg autocompleteState
            in
            { model | modal = SelectExampleModal newAutocompleteState }
                |> App.createUpdate session
                |> App.withCmds [ Cmd.map OnAutocompleteExample autoCompleteCmd ]

        ( OnAutocompleteExample _, _ ) ->
            App.createUpdate session model

        ( OnAutocompleteSelectComponent, AddComponentModal autocompleteState ) ->
            App.createUpdate session model
                |> selectComponent query autocompleteState

        ( OnAutocompleteSelectComponent, _ ) ->
            App.createUpdate session model

        ( OnAutocompleteSelectExample, SelectExampleModal autocompleteState ) ->
            App.createUpdate session model
                |> selectExample autocompleteState

        ( OnAutocompleteSelectExample, _ ) ->
            App.createUpdate session model

        ( OnAutocompleteSelectProcess category targetItem elementIndex, SelectProcessModal _ _ _ autocompleteState ) ->
            App.createUpdate session model
                |> selectProcess category targetItem elementIndex autocompleteState query

        ( OnAutocompleteSelectProcess _ _ _, _ ) ->
            App.createUpdate session model

        ( OpenComparator, _ ) ->
            { model | modal = ComparatorModal }
                |> App.createUpdate (session |> Session.checkComparedSimulations)
                |> App.withCmds [ Plausible.send session <| Plausible.ComparatorOpened model.scope ]

        ( RemoveComponentItem itemIndex, _ ) ->
            { model
                | detailedComponents =
                    model.detailedComponents
                        |> LE.remove itemIndex
                        |> LE.updateIf (\x -> x > itemIndex) (\x -> x - 1)
            }
                |> App.createUpdate session
                |> updateQuery (query |> Query.updateComponents (LE.removeAt itemIndex))
                |> App.withCmds [ Plausible.send session <| Plausible.ComponentUpdated model.scope ]

        ( RemoveElement targetElement, _ ) ->
            App.createUpdate session model
                |> updateQuery (query |> Query.updateComponents (Component.removeElement targetElement))
                |> App.withCmds [ Plausible.send session <| Plausible.ComponentUpdated model.scope ]

        ( RemoveElementTransform targetElement transformIndex, _ ) ->
            App.createUpdate session model
                |> updateQuery
                    (query
                        |> Query.updateComponents
                            (Component.removeElementTransform targetElement transformIndex)
                    )
                |> App.withCmds [ Plausible.send session <| Plausible.ComponentUpdated model.scope ]

        ( SaveBookmark, _ ) ->
            App.createUpdate session model
                |> App.withCmds
                    [ Time.now
                        |> Task.perform
                            (SaveBookmarkWithTime model.bookmarkName
                                (if model.scope == Scope.Veli then
                                    Bookmark.Veli query

                                 else
                                    Bookmark.Object query
                                )
                            )
                    , Plausible.send session <| Plausible.BookmarkSaved model.scope
                    ]

        ( SaveBookmarkWithTime name objectQuery now, _ ) ->
            model
                |> App.createUpdate
                    (session
                        |> Session.saveBookmark
                            { name = String.trim name
                            , query = objectQuery
                            , created = now
                            , subScope = Just model.scope
                            , version = Version.toMaybe session.currentVersion
                            }
                    )

        ( SelectAllBookmarks, _ ) ->
            model
                |> App.createUpdate (Session.selectAllBookmarks session)

        ( SelectNoBookmarks, _ ) ->
            model
                |> App.createUpdate (Session.selectNoBookmarks session)

        ( SetDetailedComponents detailedComponents, _ ) ->
            { model | detailedComponents = detailedComponents }
                |> App.createUpdate session

        ( SetModal modal, _ ) ->
            { model | modal = modal }
                |> App.createUpdate session
                |> App.withCmds [ commandsForModal modal ]

        ( SwitchBookmarksTab bookmarkTab, _ ) ->
            { model | bookmarkTab = bookmarkTab }
                |> App.createUpdate session
                |> App.withCmds
                    [ Plausible.TabSelected model.scope "Partager"
                        |> Plausible.sendIf session (bookmarkTab == BookmarkView.ShareTab)
                    ]

        ( SwitchComparisonType displayChoice, _ ) ->
            { model | comparisonType = displayChoice }
                |> App.createUpdate session
                |> App.withCmds
                    [ ComparatorView.comparisonTypeToString displayChoice
                        |> Plausible.ComparisonTypeSelected model.scope
                        |> Plausible.send session
                    ]

        ( SwitchImpact (Ok trigram), _ ) ->
            App.createUpdate session model
                |> App.withCmds
                    [ Just query
                        |> Route.ObjectSimulator model.scope trigram
                        |> Route.toString
                        |> Navigation.pushUrl navKey
                    , Plausible.send session <| Plausible.ImpactSelected model.scope trigram
                    ]

        ( SwitchImpact (Err error), _ ) ->
            App.createUpdate session model
                |> App.notifyError "Erreur de sélection d'impact" error

        ( SwitchImpactsTab impactsTab, _ ) ->
            { model | activeImpactsTab = impactsTab }
                |> App.createUpdate session
                |> App.withCmds
                    [ ImpactTabs.tabToString impactsTab
                        |> Plausible.TabSelected model.scope
                        |> Plausible.send session
                    ]

        ( ToggleComparedSimulation bookmark checked, _ ) ->
            model
                |> App.createUpdate (session |> Session.toggleComparedSimulation bookmark checked)

        ( UpdateBookmarkName newName, _ ) ->
            { model | bookmarkName = newName }
                |> App.createUpdate session

        ( UpdateComponentItemName targetItem name, _ ) ->
            App.createUpdate session model
                |> updateQuery
                    (query
                        |> Query.updateComponents
                            (Component.updateItemCustomName targetItem name)
                    )

        ( UpdateComponentItemQuantity itemIndex quantity, _ ) ->
            App.createUpdate session model
                |> updateQuery
                    (query
                        |> Query.updateComponents
                            (Component.updateItem itemIndex (\item -> { item | quantity = quantity }))
                    )
                |> App.withCmds [ Plausible.send session <| Plausible.ComponentUpdated model.scope ]

        ( UpdateDurability (Ok durability), _ ) ->
            App.createUpdate session model
                |> updateQuery (query |> Query.updateDurability durability)

        ( UpdateDurability (Err error), _ ) ->
            App.createUpdate session model
                |> App.notifyError "Erreur de durabilité" error

        ( UpdateElementAmount _ Nothing, _ ) ->
            App.createUpdate session model

        ( UpdateElementAmount targetElement (Just amount), _ ) ->
            App.createUpdate session model
                |> updateQuery
                    (query
                        |> Query.updateComponents
                            (Component.updateElement targetElement (\el -> { el | amount = amount }))
                    )


commandsForModal : Modal -> Cmd Msg
commandsForModal modal =
    case modal of
        NoModal ->
            Ports.removeBodyClass "prevent-scrolling"

        _ ->
            Ports.addBodyClass "prevent-scrolling"


selectExample : Autocomplete Query -> PageUpdate Model Msg -> PageUpdate Model Msg
selectExample autocompleteState ({ model } as pageUpdate) =
    let
        exampleQuery =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.withDefault Query.default
    in
    pageUpdate
        |> updateQuery exampleQuery
        |> App.apply update (SetModal NoModal)
        |> App.withCmds [ Plausible.send pageUpdate.session <| Plausible.ExampleSelected model.scope ]


selectComponent : Query -> Autocomplete Component -> PageUpdate Model Msg -> PageUpdate Model Msg
selectComponent query autocompleteState ({ model } as pageUpdate) =
    case Autocomplete.selectedValue autocompleteState of
        Just component ->
            pageUpdate
                |> updateQuery (query |> Query.updateComponents (Component.addItem component.id))
                |> App.apply update (SetModal NoModal)
                |> App.withCmds [ Plausible.send pageUpdate.session <| Plausible.ComponentAdded model.scope ]

        Nothing ->
            pageUpdate |> App.notifyWarning "Aucun composant sélectionné"


selectProcess :
    Category
    -> TargetItem
    -> Maybe Index
    -> Autocomplete Process
    -> Query
    -> PageUpdate Model Msg
    -> PageUpdate Model Msg
selectProcess category targetItem maybeElementIndex autocompleteState query ({ model } as pageUpdate) =
    case Autocomplete.selectedValue autocompleteState of
        Just process ->
            case
                query
                    |> Query.attemptUpdateComponents
                        (Component.addOrSetProcess category targetItem maybeElementIndex process)
            of
                Err err ->
                    pageUpdate |> App.notifyError "Erreur" err

                Ok validQuery ->
                    pageUpdate
                        |> updateQuery validQuery
                        |> App.apply update (SetModal NoModal)
                        |> App.withCmds [ Plausible.send pageUpdate.session <| Plausible.ComponentUpdated model.scope ]

        Nothing ->
            pageUpdate |> App.notifyWarning "Aucun composant sélectionné"


simulatorView : Session -> Model -> Html Msg
simulatorView session model =
    let
        currentQuery =
            session |> Session.objectQueryFromScope model.scope

        currentDurability =
            currentQuery |> .durability
    in
    div [ class "row" ]
        [ div [ class "col-lg-8 bg-white" ]
            [ h1 [ class "visually-hidden" ] [ text "Simulateur " ]
            , div [ class "sticky-md-top bg-white pb-3" ]
                [ ExampleView.view
                    { currentQuery = currentQuery
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
            , durabilityView currentDurability
            , ComponentView.editorView
                { addLabel = "Ajouter un composant"
                , componentConfig = session.componentConfig
                , customizable = True
                , db = session.db
                , debug = True
                , detailed = model.detailedComponents
                , docsUrl = Nothing
                , explorerRoute = Just (Route.Explore model.scope (Dataset.Components model.scope Nothing))
                , impact = model.impact
                , items = currentQuery |> .components
                , maxItems = Nothing
                , noOp = NoOp
                , openSelectComponentModal = AddComponentModal >> SetModal
                , openSelectProcessModal =
                    \p ti ei s ->
                        SelectProcessModal p ti ei s
                            |> SetModal
                , removeElement = RemoveElement
                , removeElementTransform = RemoveElementTransform
                , removeItem = RemoveComponentItem
                , lifeCycle = model.lifeCycle
                , scope = model.scope
                , setDetailed = SetDetailedComponents
                , title = "Production des composants"
                , updateElementAmount = UpdateElementAmount

                -- FIXME: implement
                , updateItemCountry = \_ _ -> NoOp
                , updateItemName = UpdateComponentItemName
                , updateItemQuantity = UpdateComponentItemQuantity
                }
            ]
        , div [ class "col-lg-4 bg-white" ]
            [ let
                lifeCycle =
                    model.lifeCycle
                        |> Result.withDefault Component.emptyLifeCycle
              in
              SidebarView.view
                { session = session
                , scope = model.scope

                -- Impact selector
                , selectedImpact = model.impact
                , switchImpact = SwitchImpact

                -- Score
                , customScoreInfo = Nothing
                , productMass = Component.extractMass lifeCycle.production
                , totalImpacts =
                    lifeCycle
                        |> Component.sumLifeCycleImpacts
                        |> Impact.divideBy (Unit.ratioToFloat currentDurability)
                , totalImpactsWithoutDurability =
                    if currentDurability == Unit.ratio 1 then
                        Nothing

                    else
                        lifeCycle
                            |> Component.sumLifeCycleImpacts
                            |> Just

                -- Impacts tabs
                , impactTabsConfig =
                    SwitchImpactsTab
                        |> ImpactTabs.createConfig session model.impact model.activeImpactsTab (always NoOp)
                        |> ImpactTabs.forObject lifeCycle
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


durabilityView : Unit.Ratio -> Html Msg
durabilityView currentDurability =
    -- Note: this is considered a temporary implementation for object and veli simulators,
    -- things might actually want to be factored out and appropriately typed and handled
    -- when ongoing discussions around holostic durability are completed.
    div [ class "card shadow-sm pb-2 mb-3" ]
        [ div [ class "card-header d-flex justify-content-between align-items-center" ]
            [ h2 [ class "h5 mb-1 text-truncate" ] [ text "Durabilité" ]
            , div [ class "d-flex align-items-center gap-2" ]
                [ Button.docsPillLink
                    [ class "bg-secondary"
                    , style "height" "24px"
                    , href Env.gitbookUrl
                    , title "Documentation"
                    , target "_blank"
                    ]
                    [ Icon.question ]
                ]
            ]
        , div [ class "card-body pb-1 row g-3 align-items-start flex-md-columns" ]
            [ div [ class "col-sm-6 col-md-4" ]
                [ label [ for "durability", class "text-truncate" ]
                    [ text "Coefficient de durabilité" ]
                ]
            , div [ class "col-sm-2 col-md-2" ]
                [ currentDurability
                    |> Unit.ratioToFloat
                    |> Format.formatFloat 2
                    |> text
                ]
            , div [ class "col-sm-4 col-md-6 text-nowrap d-flex align-items-center gap-2" ]
                [ RangeSlider.generic [ Attr.id "durability" ]
                    { disabled = False
                    , fromString =
                        String.toFloat
                            >> Result.fromMaybe "Durabilité invalide (un nombre est requis)"
                            >> Result.andThen
                                (\float ->
                                    if float < 0.5 then
                                        Err "Durabilité trop faible (minimum: 0.5)"

                                    else if float > 1.5 then
                                        Err "Durabilité trop élevée (maximum: 1.5)"

                                    else
                                        Ok float
                                )
                            >> Result.map Unit.ratio
                    , max = Unit.ratio 1.5
                    , min = Unit.ratio 0.5
                    , step = "0.01"
                    , toString = Unit.ratioToFloat >> String.fromFloat
                    , update = UpdateDurability
                    , value = currentDurability
                    }
                , button
                    [ type_ "button"
                    , class "btn text-primary p-0 border-0"
                    , onClick (UpdateDurability (Ok (Unit.ratio 1)))
                    , title "Réinitialiser la durabilité"
                    , disabled (currentDurability == Unit.ratio 1)
                    ]
                    [ Icon.crossRounded ]
                ]
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
                        , onAutocompleteSelect = OnAutocompleteSelectExample
                        , placeholderText = "tapez ici le nom du produit pour le rechercher"
                        , title = "Sélectionnez un produit"
                        , toLabel = Example.toName model.examples
                        , toCategory = Example.toCategory model.examples
                        }

                SelectProcessModal category targetItem maybeElementIndex autocompleteState ->
                    let
                        ( placeholderText, title ) =
                            case category of
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
                        , onAutocomplete = OnAutocompleteAddProcess category targetItem maybeElementIndex
                        , onAutocompleteSelect = OnAutocompleteSelectProcess category targetItem maybeElementIndex
                        , placeholderText = placeholderText
                        , title = title
                        , toLabel = Process.getDisplayName
                        , toCategory = .unit >> Process.unitToString
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
