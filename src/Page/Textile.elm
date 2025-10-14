module Page.Textile exposing
    ( Model
    , Msg(..)
    , init
    , initFromExample
    , subscriptions
    , update
    , view
    )

import App exposing (PageUpdate)
import Array
import Autocomplete exposing (Autocomplete)
import Browser.Events
import Browser.Navigation as Navigation
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Component as Component exposing (Component, Index)
import Data.Country as Country
import Data.Dataset as Dataset
import Data.Example as Example
import Data.Gitbook as Gitbook
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Notification as Notification
import Data.Posthog as Posthog
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Data.Split exposing (Split)
import Data.Textile.Db as TextileDb
import Data.Textile.Dyeing as Dyeing
import Data.Textile.Economics as Economics
import Data.Textile.Fabric exposing (Fabric)
import Data.Textile.Inputs as Inputs
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Textile.Material.Spinning exposing (Spinning)
import Data.Textile.Printing exposing (Printing)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Query as Query exposing (MaterialQuery, Query)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Data.Textile.Step.Label exposing (Label)
import Data.Unit as Unit
import Data.Uuid exposing (Uuid)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Mass
import Page.Explore as Explore
import Ports
import Request.Version as Version
import Route
import Static.Db exposing (Db)
import Task
import Time exposing (Posix)
import Views.Alert as Alert
import Views.AutocompleteSelector as AutocompleteSelector
import Views.Bookmark as BookmarkView
import Views.Button as Button
import Views.CardTabs as CardTabs
import Views.Comparator as ComparatorView
import Views.Component as ComponentView
import Views.Component.DownArrow as DownArrow
import Views.Container as Container
import Views.Example as ExampleView
import Views.Format as Format
import Views.Icon as Icon
import Views.ImpactTabs as ImpactTabs
import Views.Markdown as Markdown
import Views.Modal as ModalView
import Views.RangeSlider as RangeSlider
import Views.Sidebar as SidebarView
import Views.Textile.Step as StepView


type alias Model =
    { simulator : Result String Simulator
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonType : ComparatorView.ComparisonType
    , initialQuery : Query
    , impact : Definition
    , modal : Modal
    , activeTab : Tab
    , activeImpactsTab : ImpactTabs.Tab
    }


type Modal
    = AddMaterialModal (Maybe Inputs.MaterialInput) (Autocomplete Material)
    | AddTrimModal (Autocomplete Component)
    | ComparatorModal
    | ConfirmSwitchToRegulatoryModal
    | ExplorerDetailsTab Material
    | NoModal
    | SelectExampleModal (Autocomplete Query)
    | SelectProductModal (Autocomplete Product)


type Tab
    = ExploratoryTab
    | RegulatoryTab


type Msg
    = ConfirmSwitchToRegulatory
    | CopyToClipBoard String
    | DeleteBookmark Bookmark
    | NoOp
    | OnAutocompleteExample (Autocomplete.Msg Query)
    | OnAutocompleteMaterial (Autocomplete.Msg Material)
    | OnAutocompleteProduct (Autocomplete.Msg Product)
    | OnAutocompleteSelect
    | OnAutocompleteTrim (Autocomplete.Msg Component)
    | OnStepClick String
    | OpenComparator
    | RemoveMaterial Material.Id
    | RemoveTrim Index
    | Reset
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SelectAllBookmarks
    | SelectNoBookmarks
    | SetModal Modal
    | SwitchBookmarksTab BookmarkView.ActiveTab
    | SwitchComparisonType ComparatorView.ComparisonType
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactTabs.Tab
    | SwitchTab Tab
    | ToggleComparedSimulation Bookmark Bool
    | ToggleFading Bool
    | ToggleStep Label
    | UpdateAirTransportRatio (Maybe Split)
    | UpdateBookmarkName String
    | UpdateBusiness (Result String Economics.Business)
    | UpdateDyeingProcessType Dyeing.ProcessType
    | UpdateFabricProcess Fabric
    | UpdateMakingComplexity MakingComplexity
    | UpdateMakingDeadStock (Maybe Split)
    | UpdateMakingWaste (Maybe Split)
    | UpdateMassInput String
    | UpdateMaterial MaterialQuery MaterialQuery
    | UpdateMaterialSpinning Material Spinning
    | UpdateNumberOfReferences (Maybe Int)
    | UpdatePhysicalDurability (Maybe Unit.PhysicalDurability)
    | UpdatePrice (Maybe Economics.Price)
    | UpdatePrinting (Maybe Printing)
    | UpdateStepCountry Label Country.Code
    | UpdateSurfaceMass (Maybe Unit.SurfaceMass)
    | UpdateTrimQuantity Index Component.Quantity
    | UpdateUpcycled Bool
    | UpdateYarnSize (Maybe Unit.YarnSize)


init : Definition.Trigram -> Maybe Query -> Session -> PageUpdate Model Msg
init trigram maybeUrlQuery session =
    let
        initialQuery =
            -- If we received a serialized query from the URL, use it
            -- Otherwise, fallback to use session query
            maybeUrlQuery
                |> Maybe.withDefault session.queries.textile

        simulator =
            initialQuery
                |> Simulator.compute session.db
    in
    { simulator = simulator
    , bookmarkName = initialQuery |> suggestBookmarkName session
    , bookmarkTab = BookmarkView.SaveTab
    , comparisonType =
        if Session.isAuthenticated session then
            ComparatorView.Subscores

        else
            ComparatorView.Steps
    , initialQuery = initialQuery
    , impact = Definition.get trigram session.db.definitions
    , modal = NoModal
    , activeTab =
        if Query.isAdvancedQuery initialQuery then
            ExploratoryTab

        else
            RegulatoryTab
    , activeImpactsTab = ImpactTabs.StepImpactsTab
    }
        |> App.createUpdate (session |> Session.updateTextileQuery initialQuery)
        |> App.withAppMsgs
            (case simulator of
                Err error ->
                    [ App.AddToast (Notification.error "Erreur de récupération des paramètres d'entrée" error) ]

                Ok _ ->
                    []
            )
        |> App.withCmds
            [ case maybeUrlQuery of
                -- If we do have an URL query, we either come from a bookmark, a saved simulation click or
                -- we're tweaking params for the current simulation: we shouldn't reposition the viewport.
                Just _ ->
                    Cmd.none

                -- If we don't have an URL query, we may be coming from another app page, so we should
                -- reposition the viewport at the top.
                Nothing ->
                    Ports.scrollTo { x = 0, y = 0 }
            ]


initFromExample : Session -> Uuid -> PageUpdate Model Msg
initFromExample session uuid =
    let
        example =
            session.db.textile.examples
                |> Example.findByUuid uuid

        exampleQuery =
            example
                |> Result.map .query
                |> Result.withDefault session.queries.textile

        simulator =
            exampleQuery
                |> Simulator.compute session.db
    in
    { simulator = simulator
    , bookmarkName = exampleQuery |> suggestBookmarkName session
    , bookmarkTab = BookmarkView.SaveTab
    , comparisonType = ComparatorView.Subscores
    , initialQuery = exampleQuery
    , impact = Definition.get Definition.Ecs session.db.definitions
    , modal = NoModal
    , activeTab =
        if Query.isAdvancedQuery exampleQuery then
            ExploratoryTab

        else
            RegulatoryTab
    , activeImpactsTab = ImpactTabs.StepImpactsTab
    }
        |> App.createUpdate (session |> Session.updateTextileQuery exampleQuery)
        |> App.withAppMsgs
            (case simulator of
                Err error ->
                    [ App.AddToast (Notification.error "Erreur de récupération des paramètres d'entrée" error) ]

                Ok _ ->
                    []
            )
        |> App.withCmds [ Ports.scrollTo { x = 0, y = 0 } ]


suggestBookmarkName : Session -> Query -> String
suggestBookmarkName { db, store } query =
    let
        -- Existing user bookmark?
        userBookmark =
            store.bookmarks
                |> Bookmark.findByTextileQuery query

        -- Matching product example name?
        exampleName =
            db.textile.examples
                |> Example.findByQuery query
                |> Result.toMaybe
    in
    case ( userBookmark, exampleName ) of
        ( Just { name }, _ ) ->
            name

        ( _, Just { name } ) ->
            name

        _ ->
            query
                |> Inputs.fromQuery db
                |> Result.map (Inputs.toString db.textile.wellKnown)
                |> Result.withDefault ""


updateQuery : Query -> PageUpdate Model Msg -> PageUpdate Model Msg
updateQuery query ({ model, session } as pageUpdate) =
    { pageUpdate
        | model =
            { model
                | simulator = query |> Simulator.compute session.db
                , bookmarkName = query |> suggestBookmarkName session
            }
        , session = session |> Session.updateTextileQuery query
    }


update : Session -> Msg -> Model -> PageUpdate Model Msg
update ({ db, queries, navKey } as session) msg model =
    let
        query =
            queries.textile
    in
    case ( msg, model.modal ) of
        ( ConfirmSwitchToRegulatory, _ ) ->
            { model | activeTab = RegulatoryTab }
                |> App.createUpdate session
                |> App.apply update (SetModal NoModal)
                |> updateQuery (Query.regulatory query)

        ( CopyToClipBoard shareableLink, _ ) ->
            App.createUpdate session model
                |> App.withCmds [ Ports.copyToClipboard shareableLink ]

        ( DeleteBookmark bookmark, _ ) ->
            App.createUpdate (session |> Session.deleteBookmark bookmark) model

        ( NoOp, _ ) ->
            App.createUpdate session model

        ( OpenComparator, _ ) ->
            { model | modal = ComparatorModal }
                |> App.createUpdate (session |> Session.checkComparedSimulations)
                |> App.withCmds [ Posthog.send <| Posthog.ComparatorOpened Scope.Textile ]

        ( OnAutocompleteTrim autocompleteMsg, AddTrimModal autocompleteState ) ->
            let
                ( newAutocompleteState, autoCompleteCmd ) =
                    Autocomplete.update autocompleteMsg autocompleteState
            in
            { model | modal = AddTrimModal newAutocompleteState }
                |> App.createUpdate session
                |> App.withCmds [ Cmd.map OnAutocompleteTrim autoCompleteCmd ]

        ( OnAutocompleteTrim _, _ ) ->
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

        ( OnAutocompleteProduct autocompleteMsg, SelectProductModal autocompleteState ) ->
            let
                ( newAutocompleteState, autoCompleteCmd ) =
                    Autocomplete.update autocompleteMsg autocompleteState
            in
            { model | modal = SelectProductModal newAutocompleteState }
                |> App.createUpdate session
                |> App.withCmds [ Cmd.map OnAutocompleteProduct autoCompleteCmd ]

        ( OnAutocompleteProduct _, _ ) ->
            App.createUpdate session model

        ( OnAutocompleteMaterial autocompleteMsg, AddMaterialModal maybeOldMaterial autocompleteState ) ->
            let
                ( newAutocompleteState, autoCompleteCmd ) =
                    Autocomplete.update autocompleteMsg autocompleteState
            in
            { model | modal = AddMaterialModal maybeOldMaterial newAutocompleteState }
                |> App.createUpdate session
                |> App.withCmds [ Cmd.map OnAutocompleteMaterial autoCompleteCmd ]

        ( OnAutocompleteMaterial _, _ ) ->
            App.createUpdate session model

        ( OnAutocompleteSelect, AddMaterialModal maybeOldMaterial autocompleteState ) ->
            App.createUpdate session model
                |> updateMaterial query maybeOldMaterial autocompleteState

        ( OnAutocompleteSelect, AddTrimModal autocompleteState ) ->
            App.createUpdate session model
                |> selectTrim autocompleteState

        ( OnAutocompleteSelect, SelectExampleModal autocompleteState ) ->
            App.createUpdate session model
                |> selectExample autocompleteState

        ( OnAutocompleteSelect, SelectProductModal autocompleteState ) ->
            App.createUpdate session model
                |> selectProduct autocompleteState

        ( OnAutocompleteSelect, _ ) ->
            App.createUpdate session model

        ( OnStepClick stepId, _ ) ->
            App.createUpdate session model
                |> App.withCmds [ Ports.scrollIntoView stepId ]

        ( RemoveMaterial materialId, _ ) ->
            App.createUpdate session model
                |> updateQuery (Query.removeMaterial materialId query)

        ( RemoveTrim itemIndex, _ ) ->
            App.createUpdate session model
                |> updateQuery (query |> Query.updateTrims db.textile.products (LE.removeAt itemIndex))

        ( Reset, _ ) ->
            App.createUpdate session model
                |> updateQuery model.initialQuery

        ( SaveBookmark, _ ) ->
            App.createUpdate session model
                |> App.withCmds
                    [ Time.now
                        |> Task.perform
                            (SaveBookmarkWithTime model.bookmarkName
                                (Bookmark.Textile query)
                            )
                    , Posthog.send <| Posthog.BookmarkSaved Scope.Textile
                    ]

        ( SaveBookmarkWithTime name foodQuery now, _ ) ->
            App.createUpdate
                (session
                    |> Session.saveBookmark
                        { name = String.trim name
                        , query = foodQuery
                        , created = now
                        , subScope = Nothing
                        , version = Version.toMaybe session.currentVersion
                        }
                )
                model

        ( SelectAllBookmarks, _ ) ->
            App.createUpdate (Session.selectAllBookmarks session) model

        ( SelectNoBookmarks, _ ) ->
            App.createUpdate (Session.selectNoBookmarks session) model

        ( SetModal modal, _ ) ->
            { model | modal = modal }
                |> App.createUpdate session
                |> App.withCmds [ commandsForModal modal ]

        ( SwitchBookmarksTab bookmarkTab, _ ) ->
            { model | bookmarkTab = bookmarkTab }
                |> App.createUpdate session
                |> App.withCmds
                    [ Posthog.TabSelected Scope.Textile "Partager"
                        |> Posthog.sendIf (bookmarkTab == BookmarkView.ShareTab)
                    ]

        ( SwitchComparisonType displayChoice, _ ) ->
            { model | comparisonType = displayChoice }
                |> App.createUpdate session
                |> App.withCmds
                    [ ComparatorView.comparisonTypeToString displayChoice
                        |> Posthog.ComparisonTypeSelected Scope.Textile
                        |> Posthog.send
                    ]

        ( SwitchImpact (Ok trigram), _ ) ->
            App.createUpdate session model
                |> App.withCmds
                    [ Just query
                        |> Route.TextileSimulator trigram
                        |> Route.toString
                        |> Navigation.pushUrl navKey
                    , Posthog.send <| Posthog.ImpactSelected Scope.Textile trigram
                    ]

        ( SwitchImpact (Err error), _ ) ->
            App.createUpdate session model
                |> App.notifyError "Erreur de sélection d'impact: " error

        ( SwitchImpactsTab impactsTab, _ ) ->
            { model | activeImpactsTab = impactsTab }
                |> App.createUpdate session
                |> App.withCmds
                    [ ImpactTabs.tabToString impactsTab
                        |> Posthog.TabSelected Scope.Textile
                        |> Posthog.send
                    ]

        ( SwitchTab RegulatoryTab, _ ) ->
            App.createUpdate session
                (if Query.isAdvancedQuery query then
                    { model | modal = ConfirmSwitchToRegulatoryModal }

                 else
                    { model | activeTab = RegulatoryTab }
                )
                |> App.withCmds [ Posthog.send <| Posthog.TabSelected Scope.Textile "Regulatory" ]

        ( SwitchTab ExploratoryTab, _ ) ->
            { model | activeTab = ExploratoryTab }
                |> App.createUpdate session
                |> App.withCmds [ Posthog.send <| Posthog.TabSelected Scope.Textile "Exploratory" ]

        ( ToggleComparedSimulation bookmark checked, _ ) ->
            model
                |> App.createUpdate (session |> Session.toggleComparedSimulation bookmark checked)

        ( ToggleFading fading, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | fading = Just fading }

        ( ToggleStep label, _ ) ->
            App.createUpdate session model
                |> updateQuery (Query.toggleStep label query)

        ( UpdateAirTransportRatio airTransportRatio, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | airTransportRatio = airTransportRatio }

        ( UpdateBookmarkName newName, _ ) ->
            { model | bookmarkName = newName }
                |> App.createUpdate session

        ( UpdateBusiness (Ok business), _ ) ->
            App.createUpdate session model
                |> updateQuery { query | business = Just business }

        ( UpdateBusiness (Err error), _ ) ->
            App.createUpdate session model
                |> App.notifyError "Erreur de type d'entreprise" error

        ( UpdateDyeingProcessType dyeingProcessType, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | dyeingProcessType = Just dyeingProcessType }

        ( UpdateFabricProcess fabricProcess, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | fabricProcess = Just fabricProcess }

        ( UpdatePhysicalDurability physicalDurability, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | physicalDurability = physicalDurability }

        ( UpdateMakingComplexity makingComplexity, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | makingComplexity = Just makingComplexity }

        ( UpdateMakingWaste makingWaste, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | makingWaste = makingWaste }

        ( UpdateMakingDeadStock makingDeadStock, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | makingDeadStock = makingDeadStock }

        ( UpdateMassInput massInput, _ ) ->
            App.createUpdate session model
                |> (case massInput |> String.toFloat |> Maybe.map Mass.kilograms of
                        Just mass ->
                            updateQuery { query | mass = mass }

                        Nothing ->
                            identity
                   )

        ( UpdateMaterial oldMaterial newMaterial, _ ) ->
            App.createUpdate session model
                |> updateQuery (Query.updateMaterial oldMaterial.id newMaterial query)

        ( UpdateMaterialSpinning material spinning, _ ) ->
            App.createUpdate session model
                |> updateQuery (Query.updateMaterialSpinning material spinning query)

        ( UpdateNumberOfReferences numberOfReferences, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | numberOfReferences = numberOfReferences }

        ( UpdatePrice price, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | price = price }

        ( UpdatePrinting printing, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | printing = printing }

        ( UpdateStepCountry label code, _ ) ->
            App.createUpdate session model
                |> updateQuery (Query.updateStepCountry label code query)

        ( UpdateSurfaceMass surfaceMass, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | surfaceMass = surfaceMass }

        ( UpdateTrimQuantity trimIndex quantity, _ ) ->
            App.createUpdate session model
                |> updateQuery
                    (query
                        |> Query.updateTrims db.textile.products
                            (Component.updateItem trimIndex (\item -> { item | quantity = quantity }))
                    )

        ( UpdateUpcycled upcycled, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | upcycled = upcycled }

        ( UpdateYarnSize yarnSize, _ ) ->
            App.createUpdate session model
                |> updateQuery { query | yarnSize = yarnSize }


commandsForModal : Modal -> Cmd Msg
commandsForModal modal =
    case modal of
        NoModal ->
            Ports.removeBodyClass "prevent-scrolling"

        _ ->
            Ports.addBodyClass "prevent-scrolling"


updateExistingMaterial : Query -> PageUpdate Model Msg -> Inputs.MaterialInput -> Material -> PageUpdate Model Msg
updateExistingMaterial query pageUpdate oldMaterial newMaterial =
    let
        materialQuery : MaterialQuery
        materialQuery =
            { id = newMaterial.id
            , share = oldMaterial.share
            , spinning = Nothing
            , country = Nothing
            }
    in
    pageUpdate
        |> App.apply update (SetModal NoModal)
        |> updateQuery (Query.updateMaterial oldMaterial.material.id materialQuery query)


updateMaterial : Query -> Maybe Inputs.MaterialInput -> Autocomplete Material -> PageUpdate Model Msg -> PageUpdate Model Msg
updateMaterial query maybeOldMaterial autocompleteState pageUpdate =
    let
        maybeSelectedValue =
            Autocomplete.selectedValue autocompleteState
    in
    Maybe.map2
        (updateExistingMaterial query pageUpdate)
        maybeOldMaterial
        maybeSelectedValue
        |> Maybe.withDefault
            -- Add a new Material
            (pageUpdate
                |> App.apply update (SetModal NoModal)
                |> selectMaterial autocompleteState
            )


selectExample : Autocomplete Query -> PageUpdate Model Msg -> PageUpdate Model Msg
selectExample autocompleteState { model, session } =
    let
        example =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.withDefault Query.default
    in
    { model | initialQuery = example }
        |> App.createUpdate (Session.updateTextileQuery example session)
        |> App.apply update (SetModal NoModal)
        |> updateQuery example
        |> App.withCmds [ Posthog.send <| Posthog.ExampleSelected Scope.Textile ]


selectTrim : Autocomplete Component -> PageUpdate Model Msg -> PageUpdate Model Msg
selectTrim autocompleteState ({ session } as pageUpdate) =
    case Autocomplete.selectedValue autocompleteState of
        Just trim ->
            pageUpdate
                |> App.apply update (SetModal NoModal)
                |> updateQuery
                    (session.queries.textile
                        |> Query.updateTrims session.db.textile.products (Component.addItem trim.id)
                    )

        Nothing ->
            pageUpdate |> App.notifyError "Erreur" "Aucun accessoire sélectionné"


selectProduct : Autocomplete Product -> PageUpdate Model Msg -> PageUpdate Model Msg
selectProduct autocompleteState ({ session } as pageUpdate) =
    case Autocomplete.selectedValue autocompleteState of
        Just product ->
            pageUpdate
                |> App.apply update (SetModal NoModal)
                |> updateQuery
                    (session.queries.textile
                        |> Query.updateProduct product
                    )

        Nothing ->
            pageUpdate |> App.notifyError "Erreur" "Aucun produit sélectionné"


selectMaterial : Autocomplete Material -> PageUpdate Model Msg -> PageUpdate Model Msg
selectMaterial autocompleteState ({ session } as pageUpdate) =
    case Autocomplete.selectedValue autocompleteState of
        Just material ->
            pageUpdate
                |> App.apply update (SetModal NoModal)
                |> updateQuery
                    (session.queries.textile
                        |> Query.addMaterial material
                    )

        Nothing ->
            pageUpdate |> App.notifyError "Erreur" "Aucun matériau sélectionné"


productCategoryField : TextileDb.Db -> Query -> Html Msg
productCategoryField { products } query =
    let
        autocompleteState =
            products
                |> List.sortBy .name
                |> AutocompleteSelector.init .name
    in
    div [ class "d-flex flex-column" ]
        [ div [ class "d-flex justify-content-between align-items-center" ]
            [ label [ for "selector-product", class "form-label text-truncate" ]
                [ text "Catégorie de produit" ]
            , Button.smallPillLink
                [ class "text-primary"
                , Route.href <| Route.Explore Scope.Textile (Dataset.TextileProducts Nothing)
                , title "Explorer les catégories de produit"
                , target "_blank"
                ]
                [ Icon.question ]
            ]
        , button
            [ id "selector-product"
            , class "form-select ElementSelector text-start w-auto"
            , onClick (SetModal (SelectProductModal autocompleteState))
            ]
            [ products
                |> Product.findById query.product
                |> Result.map .name
                |> Result.withDefault ""
                |> text
            ]
        ]


numberOfReferencesField : Int -> Html Msg
numberOfReferencesField numberOfReferences =
    input
        [ type_ "number"
        , id "number-of-references"
        , class "form-control"

        -- WARNING: be careful when reordering attributes: for obscure reasons,
        -- the `value` one MUST be set AFTER the `step` one.
        , Attr.min <| String.fromInt <| Economics.minNumberOfReferences
        , Attr.max <| String.fromInt <| Economics.maxNumberOfReferences
        , step "1"
        , value (String.fromInt numberOfReferences)
        , onInput (String.toInt >> UpdateNumberOfReferences)
        ]
        []


productPriceField : Economics.Price -> Html Msg
productPriceField productPrice =
    div [ class "input-group" ]
        [ input
            [ type_ "number"
            , id "product-price"
            , class "form-control"
            , Attr.min <| String.fromFloat <| Economics.priceToFloat <| Economics.minPrice
            , Attr.max <| String.fromFloat <| Economics.priceToFloat <| Economics.maxPrice
            , productPrice |> Economics.priceToFloat |> String.fromFloat |> value
            , onInput (String.toFloat >> Maybe.map Economics.priceFromFloat >> UpdatePrice)
            ]
            []
        , span [ class "input-group-text" ] [ text "€" ]
        ]


physicalDurabilityField : Unit.PhysicalDurability -> Html Msg
physicalDurabilityField durability =
    div [ class "input-group" ]
        [ RangeSlider.physicalDurability
            { id = "physicalDurability"
            , update = UpdatePhysicalDurability
            , value = durability
            , toString = Unit.physicalDurabilityToFloat >> String.fromFloat
            , disabled = False
            }
        ]


businessField : Economics.Business -> Html Msg
businessField business =
    [ Economics.SmallBusiness
    , Economics.LargeBusinessWithoutServices
    , Economics.LargeBusinessWithServices
    ]
        |> List.map
            (\b ->
                option [ value (Economics.businessToString b), selected (business == b) ]
                    [ text (Economics.businessToLabel b) ]
            )
        |> select
            [ id "business"
            , class "form-select"
            , onInput (Economics.businessFromString >> UpdateBusiness)
            ]


massField : String -> Html Msg
massField massInput =
    div [ class "d-flex flex-column" ]
        [ label [ for "mass", class "form-label text-truncate" ]
            [ text "Masse du produit fini" ]
        , div
            [ class "input-group" ]
            [ input
                [ type_ "number"
                , class "form-control"
                , id "mass"
                , Attr.min "0.01"
                , step "0.01"
                , value massInput
                , onInput UpdateMassInput
                ]
                []
            , span [ class "input-group-text" ] [ text "kg" ]
            ]
        ]


lifeCycleStepsView : Db -> Model -> Simulator -> Html Msg
lifeCycleStepsView db { activeTab, impact } simulator =
    simulator.lifeCycle
        |> Array.indexedMap
            (\index current ->
                StepView.view
                    { db = db
                    , current = current
                    , daysOfWear = simulator.daysOfWear
                    , useNbCycles = simulator.useNbCycles
                    , index = index
                    , inputs = simulator.inputs
                    , next = LifeCycle.getNextEnabledStep current.label simulator.lifeCycle
                    , selectedImpact = impact
                    , showAdvancedFields = activeTab == ExploratoryTab

                    -- Events
                    , addMaterialModal = AddMaterialModal
                    , deleteMaterial = .id >> RemoveMaterial
                    , openExplorerDetails = ExplorerDetailsTab >> SetModal
                    , setModal = SetModal
                    , toggleFading = ToggleFading
                    , toggleStep = ToggleStep
                    , updateCountry = UpdateStepCountry
                    , updateAirTransportRatio = UpdateAirTransportRatio
                    , updateDyeingProcessType = UpdateDyeingProcessType
                    , updateMaterial = UpdateMaterial
                    , updateMaterialSpinning = UpdateMaterialSpinning
                    , updateFabricProcess = UpdateFabricProcess
                    , updatePrinting = UpdatePrinting
                    , updateMakingComplexity = UpdateMakingComplexity
                    , updateMakingWaste = UpdateMakingWaste
                    , updateMakingDeadStock = UpdateMakingDeadStock
                    , updateSurfaceMass = UpdateSurfaceMass
                    , updateYarnSize = UpdateYarnSize
                    }
            )
        |> Array.toList
        |> List.concatMap
            (\{ step, transport } ->
                [ step
                , DownArrow.view [] [ transport ]
                ]
            )
        -- Drop the very last item, which is the last arrow showing the mass out of the end of life step
        -- which doesn't really make sense
        |> List.reverse
        |> List.drop 1
        |> List.reverse
        |> div [ class "pt-1", attribute "data-testid" "life-cycle-steps" ]


simulatorFormView : Session -> Model -> Simulator -> List (Html Msg)
simulatorFormView session model ({ inputs } as simulator) =
    [ div [ class "row align-items-start flex-md-columns g-2" ]
        [ div [ class "col-md-6" ]
            [ inputs
                |> Inputs.toQuery
                |> productCategoryField session.db.textile
            ]
        , div [ class "col-md-3" ]
            [ inputs.mass
                |> Mass.inKilograms
                |> String.fromFloat
                |> massField
            ]
        , div [ class "col-md-3 d-flex align-items-end flex-row" ]
            [ div [ class "d-flex flex-column" ]
                [ label [ class "form-label d-none d-md-block", attribute "aria-hidden" "true" ] [ text "\u{00A0}" ]
                , div [ class "UpcycledCheck form-check text-truncate ms-1" ]
                    [ input
                        [ type_ "checkbox"
                        , class "form-check-input"
                        , id "upcycled"
                        , checked <| inputs.upcycled
                        , onCheck UpdateUpcycled
                        ]
                        []
                    , label
                        [ for "upcycled"
                        , class "form-check-label text-truncate"
                        , title "Le vêtement est-il upcyclé\u{00A0}?"
                        ]
                        [ text "Remanufacturé" ]
                    ]
                ]
            ]
        ]
    , ComponentView.editorView
        { addLabel = "Ajouter un accessoire"
        , customizable = False
        , db = session.db
        , debug = False
        , detailed = []
        , docsUrl = Just <| Gitbook.publicUrlFromPath Gitbook.TextileTrims
        , explorerRoute = Just (Route.Explore Scope.Textile (Dataset.Components Scope.Textile Nothing))
        , impact = model.impact
        , items = inputs.trims
        , maxItems = Nothing
        , noOp = NoOp
        , openSelectComponentModal = AddTrimModal >> SetModal
        , openSelectProcessModal = \_ _ _ _ -> SetModal NoModal
        , removeElement = \_ -> NoOp
        , removeElementTransform = \_ _ -> NoOp
        , removeItem = RemoveTrim
        , results =
            inputs.trims
                |> Component.compute session.db
                |> Result.withDefault Component.emptyResults
        , scopes = [ Scope.Textile ]
        , setDetailed = \_ -> NoOp
        , title = "Accessoires"
        , updateElementAmount = \_ _ -> NoOp
        , updateItemName = \_ _ -> NoOp
        , updateItemQuantity = UpdateTrimQuantity
        }
    , div [ class "card shadow-sm pb-2" ]
        [ div [ class "card-header d-flex justify-content-between align-items-center" ]
            [ h2 [ class "h5 mb-1 text-truncate" ] [ text "Durabilité" ]
            , div [ class "d-flex align-items-center gap-2" ]
                [ span [ class "d-none d-sm-flex text-truncate" ] [ text "Coefficient de durabilité\u{00A0}:" ]
                , simulator.durability
                    |> Unit.floatDurabilityFromHolistic
                    |> Format.formatFloat 2
                    |> text
                , Button.docsPillLink
                    [ class "bg-secondary"
                    , style "height" "24px"
                    , href (Gitbook.publicUrlFromPath Gitbook.TextileDurability)
                    , title "Documentation"
                    , target "_blank"
                    ]
                    [ Icon.question ]
                ]
            ]
        , div [ class "card-body pt-3 py-2 row g-3 align-items-start flex-md-columns" ]
            [ div [ class "col-md-2" ]
                [ label
                    [ for "product-price"
                    , class "col-form-label text-truncate"
                    ]
                    [ text "Prix neuf" ]
                ]
            , div [ class "col-md-3" ]
                [ inputs.price
                    |> Maybe.withDefault inputs.product.economics.price
                    |> productPriceField
                ]
            , div [ class "col-md-4" ]
                [ label
                    [ for "number-of-references"
                    , class "col-form-label text-truncate"
                    ]
                    [ text "Nombre de références" ]
                ]
            , div [ class "col-md-3" ]
                [ inputs.numberOfReferences
                    |> Maybe.withDefault inputs.product.economics.numberOfReferences
                    |> numberOfReferencesField
                ]
            ]
        , div [ class "card-body py-2 row g-3 align-items-start flex-md-columns" ]
            [ div [ class "col-md-2" ]
                [ label
                    [ for "business"
                    , class "col-form-label text-truncate"
                    ]
                    [ text "Entreprise" ]
                ]
            , div [ class "col-md-10" ]
                [ inputs.business
                    |> Maybe.withDefault inputs.product.economics.business
                    |> businessField
                ]
            ]
        , if model.activeTab == ExploratoryTab then
            div []
                [ div [ class "card-body py-2 row g-3 align-items-start flex-md-columns" ]
                    [ div [ class "col-md-4" ] [ text "Durabilité non physique" ]
                    , div [ class "col-md-8" ]
                        [ simulator.durability.nonPhysical
                            |> Unit.nonPhysicalDurabilityToFloat
                            |> String.fromFloat
                            |> text
                        ]
                    ]
                , div [ class "card-body py-2 row g-3 align-items-start flex-md-columns" ]
                    [ div [ class "col-md-4" ] [ text "Durabilité physique" ]
                    , div [ class "col-md-8" ] [ physicalDurabilityField simulator.durability.physical ]
                    ]
                ]

          else
            text ""
        ]
    , div []
        [ lifeCycleStepsView session.db model simulator
        , div [ class "d-flex align-items-center justify-content-between mt-3" ]
            [ a [ Route.href Route.Home ]
                [ text "« Retour à l'accueil" ]
            , button
                [ class "btn btn-secondary"
                , onClick Reset
                , disabled (session.queries.textile == model.initialQuery)
                ]
                [ text "Réinitialiser le produit" ]
            ]
        ]
    ]


simulatorView : Session -> Model -> Simulator -> Html Msg
simulatorView session model ({ inputs, impacts } as simulator) =
    let
        tabLabel help name =
            span [ class "d-flex justify-content-between align-items-center gap-1" ]
                [ span [ class "d-flex flex-fill justify-content-center" ] [ text name ]
                , span [ class "text-muted fs-8 cursor-help opacity-50", title help ] [ Icon.question ]
                ]
    in
    div [ class "row" ]
        [ div [ class "col-lg-8 bg-white" ]
            [ h1 [ class "visually-hidden" ] [ text "Simulateur " ]
            , div [ class "sticky-md-top bg-white pb-3" ]
                [ ExampleView.view
                    { currentQuery = session.queries.textile
                    , emptyQuery = Query.default
                    , examples = session.db.textile.examples
                    , helpUrl = Just Gitbook.TextileExamples
                    , onOpen = SelectExampleModal >> SetModal
                    , routes =
                        { explore = Route.Explore Scope.Textile (Dataset.TextileExamples Nothing)
                        , load = Route.TextileSimulatorExample
                        , scopeHome = Route.TextileSimulatorHome
                        }
                    }
                ]
            , div [ class "d-flex flex-column bg-white" ]
                [ CardTabs.view
                    { attrs = [ class "sticky-md-top", style "top" "50px" ]
                    , tabs =
                        [ { label =
                                "Mode règlementaire"
                                    |> tabLabel "N’affiche que les champs proposés dans le projet de cadre réglementaire"
                          , active = model.activeTab == RegulatoryTab
                          , onTabClick = SwitchTab RegulatoryTab
                          }
                        , { label =
                                "Mode exploratoire"
                                    |> tabLabel "Affiche des champs supplémentaires, hors cadre réglementaire"
                          , active = model.activeTab == ExploratoryTab
                          , onTabClick = SwitchTab ExploratoryTab
                          }
                        ]
                    , content =
                        [ simulator
                            |> simulatorFormView session model
                            |> div [ class "card-body p-2 d-flex flex-column gap-3" ]
                        ]
                    }
                ]
            ]
        , div [ class "col-lg-4 bg-white" ]
            [ SidebarView.view
                { session = session
                , scope = Scope.Textile

                -- Impact selector
                , selectedImpact = model.impact
                , switchImpact = SwitchImpact

                -- Score
                , customScoreInfo =
                    Just
                        (div [ class "fs-8" ]
                            [ text "Pour 100g\u{00A0}:\u{00A0}"
                            , impacts
                                |> Impact.per100grams inputs.mass
                                |> Format.formatImpact model.impact
                            ]
                        )
                , productMass = inputs.mass
                , totalImpacts = impacts
                , totalImpactsWithoutDurability = Just <| Simulator.getTotalImpactsWithoutDurability simulator

                -- Impacts tabs
                , impactTabsConfig =
                    SwitchImpactsTab
                        |> ImpactTabs.createConfig session model.impact model.activeImpactsTab OnStepClick
                        |> ImpactTabs.forTextile session.db.definitions simulator
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
            (case model.simulator of
                Err error ->
                    [ Alert.simple
                        { attributes = []
                        , level = Alert.Danger
                        , close = Nothing
                        , title = Just "Erreur"
                        , content = [ text error ]
                        }
                    ]

                Ok simulator ->
                    [ simulatorView session model simulator
                    , case model.modal of
                        AddMaterialModal _ autocompleteState ->
                            AutocompleteSelector.view
                                { autocompleteState = autocompleteState
                                , closeModal = SetModal NoModal
                                , footer = []
                                , noOp = NoOp
                                , onAutocomplete = OnAutocompleteMaterial
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici le nom de la matière première pour la rechercher"
                                , title = "Sélectionnez une matière première"
                                , toLabel = .shortName
                                , toCategory = .origin >> Origin.toLabel
                                }

                        AddTrimModal autocompleteState ->
                            AutocompleteSelector.view
                                { autocompleteState = autocompleteState
                                , closeModal = SetModal NoModal
                                , footer = []
                                , noOp = NoOp
                                , onAutocomplete = OnAutocompleteTrim
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici un nom d'accesoire pour le rechercher"
                                , title = "Sélectionnez un accessoire"
                                , toLabel = .name
                                , toCategory = always ""
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

                        ConfirmSwitchToRegulatoryModal ->
                            ModalView.view
                                { size = ModalView.Standard
                                , close = SetModal NoModal
                                , noOp = NoOp
                                , title = "Avertissement"
                                , subTitle = Nothing
                                , formAction = Nothing
                                , content =
                                    [ div [ class "p-3" ]
                                        [ """Basculer en mode règlementaire réinitialisera les valeurs renseignées
                                             pour les champs avancés du mode exploratoire."""
                                            |> Markdown.simple []
                                        , p
                                            [ class "d-flex justify-content-center align-items-center gap-1 mt-4" ]
                                            [ button
                                                [ class "btn btn-primary"
                                                , onClick ConfirmSwitchToRegulatory
                                                ]
                                                [ text "Confirmer" ]
                                            , text "ou"
                                            , button [ class "btn btn-link ps-0", onClick (SetModal NoModal) ]
                                                [ text "rester en mode exploratoire" ]
                                            ]
                                        ]
                                    ]
                                , footer = []
                                }

                        ExplorerDetailsTab material ->
                            ModalView.view
                                { size = ModalView.Large
                                , close = SetModal NoModal
                                , noOp = NoOp
                                , title = material.name
                                , subTitle = Nothing
                                , formAction = Nothing
                                , content = [ Explore.textileMaterialDetails session.db material ]
                                , footer = []
                                }

                        NoModal ->
                            text ""

                        SelectExampleModal autocompleteState ->
                            AutocompleteSelector.view
                                { autocompleteState = autocompleteState
                                , closeModal = SetModal NoModal
                                , footer = []
                                , noOp = NoOp
                                , onAutocomplete = OnAutocompleteExample
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici le nom du produit pour le rechercher"
                                , title = "Sélectionnez un produit"
                                , toLabel = Example.toName session.db.textile.examples
                                , toCategory = Example.toCategory session.db.textile.examples
                                }

                        SelectProductModal autocompleteState ->
                            AutocompleteSelector.view
                                { autocompleteState = autocompleteState
                                , closeModal = SetModal NoModal
                                , footer =
                                    [ a
                                        [ class "d-flex justify-content-between gap-2 align-items-center btn btn-primary"
                                        , href "https://forms.gle/JY6QYMppqRTiCM6g8"
                                        , target "_blank"
                                        ]
                                        [ Icon.plus
                                        , text "Suggérer une nouvelle catégorie"
                                        ]
                                    ]
                                , noOp = NoOp
                                , onAutocomplete = OnAutocompleteProduct
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici une catégorie pour la rechercher"
                                , title = "Sélectionnez une catégorie de produit"
                                , toLabel = .name
                                , toCategory = always ""
                                }
                    ]
            )
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions { modal } =
    case modal of
        NoModal ->
            Sub.none

        _ ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))
