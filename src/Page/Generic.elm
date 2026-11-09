module Page.Generic exposing
    ( Model
    , Msg
    , init
    , initFromExample
    , refreshResults
    , shouldTrackUsage
    , subscriptions
    , update
    , view
    )

import App exposing (PageUpdate)
import Autocomplete exposing (Autocomplete)
import Browser.Events
import Browser.Navigation as Navigation
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Component as Component exposing (Index, Query, TargetElement, TargetItem)
import Data.Component.Amount as Amount exposing (Amount)
import Data.Component.Config as Config
import Data.Component.ProductCategory as Product
import Data.Country.Code as CountryCode
import Data.Dataset as Dataset
import Data.Db exposing (Db)
import Data.Example as Example exposing (Example)
import Data.Generic.Simulator as Simulator
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Plausible as Plausible
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (Category)
import Data.Sector as Sector exposing (GenericSector, Sector)
import Data.Session as Session exposing (Session)
import Data.Split exposing (Split)
import Data.Unit as Unit
import Data.Uuid as Uuid exposing (Uuid)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Mass exposing (Mass)
import Ports
import Quantity
import RemoteData
import Request.BackendHttp exposing (WebData)
import Request.BackendHttp.Error as BackendHttpError
import Request.Contrib as Contrib
import Result.Extra as RE
import Route
import Task
import Time exposing (Posix)
import Views.AutocompleteSelector as AutocompleteSelectorView
import Views.Bookmark as BookmarkView
import Views.Button as Button
import Views.Comparator as ComparatorView
import Views.Component as ComponentView
import Views.Component.Context as Context
import Views.Container as Container
import Views.Example as ExampleView
import Views.FloatInput as FloatInput
import Views.Format as Format
import Views.Icon as Icon
import Views.ImpactTabs as ImpactTabs
import Views.Modal as ModalView
import Views.RangeSlider as RangeSlider
import Views.Sidebar as SidebarView


type alias Model =
    { activeImpactsTab : ImpactTabs.Tab
    , bookmarkBeingDragged : Maybe Bookmark
    , bookmarkBeingOvered : Maybe Bookmark
    , bookmarkBeingRenamed : Maybe Bookmark
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonType : ComparatorView.ComparisonType
    , contributionDescription : String
    , contributionName : String
    , contributionRequestPending : Bool
    , detailedComponents : List Index
    , examples : List (Example Query)
    , floatInputState : Maybe FloatInput.State
    , impact : Definition
    , initialQuery : Query
    , modals : List Modal
    , lifeCycle : Result String Component.LifeCycle
    , genericSector : GenericSector
    }


type Modal
    = AddProductionItemModal (Autocomplete Component.ProductionItem)
    | ComparatorModal
    | ItemEditModal TargetItem
    | SelectAssemblyOperationModal (Autocomplete Process)
    | SelectConsumptionModal (Autocomplete Process)
    | SelectExampleModal (Autocomplete Query)
    | SelectPackagingModal (Autocomplete Process)
    | SelectProcessModal Category TargetItem (Maybe Index) (Autocomplete Process)


type Msg
    = AppendModal Modal
    | CopyToClipBoard String
    | CreateExampleContrib
    | DeleteBookmark Bookmark
    | ExampleContribCreated (WebData Contrib.ExampleContribResponse)
    | ExportBookmarks
    | ImportBookmarks
    | NoOp
    | OnAutocompleteAddAssemblyOperation (Autocomplete.Msg Process)
    | OnAutocompleteAddConsumption (Autocomplete.Msg Process)
    | OnAutocompleteAddProcess Category TargetItem (Maybe Index) (Autocomplete.Msg Process)
    | OnAutocompleteAddProductionItem (Autocomplete.Msg Component.ProductionItem)
    | OnAutocompleteExample (Autocomplete.Msg Query)
    | OnAutocompletePackaging (Autocomplete.Msg Process)
    | OnAutocompleteSelectAssemblyOperation
    | OnAutocompleteSelectConsumption
    | OnAutocompleteSelectExample
    | OnAutocompleteSelectPackaging
    | OnAutocompleteSelectProcess Category TargetItem (Maybe Index)
    | OnAutocompleteSelectProductionItem
    | OnDragLeaveBookmark
    | OnDragOverBookmark Bookmark
    | OnDragStartBookmark Bookmark
    | OnDropBookmark Bookmark
    | OpenComparator
    | RemoveAssemblyOperation Index
    | RemoveComponentItem Int
    | RemoveConsumption Index
    | RemoveElement TargetElement
    | RemoveElementTransform TargetElement Index
    | RemovePackaging Index
    | RenameBookmark
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SelectAllBookmarks
    | SelectNoBookmarks
    | SetDetailedComponents (List Index)
    | SetModals (List Modal)
    | SwitchBookmarksTab BookmarkView.ActiveTab
    | SwitchComparisonType ComparatorView.ComparisonType
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactTabs.Tab
    | ToggleComparedSimulation Bookmark Bool
    | ToggleTransportByAir Split
    | ToggleTransportCooling Bool
    | UpdateAssemblyCountry (Maybe CountryCode.Code)
    | UpdateBookmarkName String
    | UpdateComponentItemName TargetItem String
    | UpdateComponentItemQuantity Index Component.Quantity
    | UpdateConsumptionAmount Index FloatInput.State
    | UpdateContributionDescription String
    | UpdateContributionName String
    | UpdateDistribution (Result String Process.Id)
    | UpdateDurability (Result String Unit.Ratio)
    | UpdateElementAmount TargetElement FloatInput.State
    | UpdateElementMaterialCountry TargetElement (Maybe CountryCode.Code)
    | UpdateElementTransformCountry TargetElement Index (Maybe CountryCode.Code)
    | UpdateItemUnitMass Index FloatInput.State
    | UpdatePackagingAmount Index FloatInput.State
    | UpdateProduct (Maybe Product.Id)
    | UpdateRecyclability Bool
    | UpdateRenamedBookmarkName Bookmark String


init : GenericSector -> Definition.Trigram -> Maybe Query -> Session -> PageUpdate Model Msg
init genericSector trigram maybeUrlQuery session =
    let
        initialQuery =
            initQuery session genericSector maybeUrlQuery

        examples =
            session.db.generic.examples
                |> Example.forScope (Sector.Generic genericSector)
    in
    { activeImpactsTab = ImpactTabs.StagesImpactsTab
    , bookmarkName = initialQuery |> suggestBookmarkName session genericSector examples
    , bookmarkTab = BookmarkView.SaveTab
    , comparisonType =
        if Session.isAuthenticated session then
            ComparatorView.Subscores

        else
            ComparatorView.Stages
    , contributionDescription = ""
    , contributionName = ""
    , contributionRequestPending = False
    , detailedComponents = []
    , bookmarkBeingDragged = Nothing
    , bookmarkBeingOvered = Nothing
    , bookmarkBeingRenamed = Nothing
    , examples = examples
    , floatInputState = Nothing
    , impact = Definition.get trigram session.db.definitions
    , initialQuery = initialQuery
    , modals = []
    , lifeCycle =
        initialQuery
            |> Simulator.compute
                { config = session.componentConfig
                , db = session.db
                , sector = Sector.Generic genericSector
                }
    , genericSector = genericSector
    }
        |> createPageUpdate (session |> Session.updateGenericQuery genericSector initialQuery)
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


initFromExample : Session -> GenericSector -> Uuid -> PageUpdate Model Msg
initFromExample session genericSector uuid =
    let
        sector =
            Sector.Generic genericSector

        examples =
            session.db.generic.examples
                |> Example.forScope sector

        example =
            examples
                |> Example.findByUuid uuid

        exampleQuery =
            example
                |> Result.map .query
                |> Result.withDefault Component.emptyQuery
    in
    { activeImpactsTab = ImpactTabs.StagesImpactsTab
    , bookmarkName = exampleQuery |> suggestBookmarkName session genericSector examples
    , bookmarkTab = BookmarkView.SaveTab
    , comparisonType = ComparatorView.Subscores
    , contributionDescription = ""
    , contributionName = ""
    , contributionRequestPending = False
    , detailedComponents = []
    , bookmarkBeingDragged = Nothing
    , bookmarkBeingOvered = Nothing
    , bookmarkBeingRenamed = Nothing
    , examples = examples
    , floatInputState = Nothing
    , impact = Definition.get Definition.Ecs session.db.definitions
    , initialQuery = exampleQuery
    , modals = []
    , lifeCycle =
        exampleQuery
            |> Simulator.compute
                { config = session.componentConfig
                , db = session.db
                , sector = sector
                }
    , genericSector = genericSector
    }
        |> createPageUpdate (session |> Session.updateGenericQuery genericSector exampleQuery)
        |> App.notifyErrorIf (RE.isErr example) "Exemple introuvable" ("L’exemple de produit " ++ Uuid.toString uuid ++ " n’existe pas.")
        |> App.withCmds [ Ports.scrollTo { x = 0, y = 0 } ]


{-| Initializes the initial query to load, using the URL query if any, or falling back to use:

  - the session query if it's not empty
  - the default configured example for this sector, if any
  - an empty query

-}
initQuery : Session -> GenericSector -> Maybe Query -> Query
initQuery session genericSector =
    Maybe.withDefault <|
        let
            sessionQuery =
                Session.genericQuery genericSector session
        in
        if List.isEmpty sessionQuery.items then
            session.componentConfig.defaultExamples
                |> Sector.dictGet (Sector.Generic genericSector)
                |> Maybe.andThen
                    (\uuid ->
                        session.db.generic.examples
                            |> Example.findByUuid uuid
                            |> Result.toMaybe
                            |> Maybe.map .query
                    )
                |> Maybe.withDefault Component.emptyQuery

        else
            sessionQuery


selectProductCategory : Session -> Query -> Maybe Product.Id -> PageUpdate Model Msg -> PageUpdate Model Msg
selectProductCategory session query maybeProductId =
    case maybeProductId of
        Just productId ->
            case Product.findById productId session.db.products of
                Err error ->
                    App.notifyError "Catégorie de produit introuvable" error

                Ok product ->
                    updateQuery (query |> Component.updateProduct (Just product))

        Nothing ->
            updateQuery (query |> Component.updateProduct Nothing)


{-| Recomputes results after detailed processes have been loaded and session updated
-}
refreshResults : Session -> Model -> Model
refreshResults session model =
    { model
        | lifeCycle =
            session
                |> Session.genericQuery model.genericSector
                |> Simulator.compute
                    { config = session.componentConfig
                    , db = session.db
                    , sector = Sector.Generic model.genericSector
                    }
    }


suggestBookmarkName : Session -> GenericSector -> List (Example Query) -> Query -> String
suggestBookmarkName { db, store } genericSector examples query =
    let
        -- Existing user bookmark?
        userBookmark =
            store.bookmarks
                |> Bookmark.findByGenericQuery genericSector query

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
            query.items
                |> Component.itemsToString db
                |> Result.withDefault "N/A"


updateQuery : Query -> PageUpdate Model Msg -> PageUpdate Model Msg
updateQuery query ({ model, session } as pageUpdate) =
    let
        sector =
            Sector.Generic model.genericSector
    in
    { pageUpdate
        | model =
            { model
                | initialQuery = query
                , bookmarkName = query |> suggestBookmarkName session model.genericSector model.examples
                , lifeCycle =
                    query
                        |> Simulator.compute
                            { config = session.componentConfig
                            , db = session.db
                            , sector = sector
                            }
            }
        , session = session |> Session.updateGenericQuery model.genericSector query
    }


applyAmountInputState : FloatInput.State -> (Model -> Amount -> PageUpdate Model Msg) -> ( Session, Model ) -> PageUpdate Model Msg
applyAmountInputState state applyAmount ( session, model ) =
    let
        newModel =
            model |> applyFloatInputState state
    in
    case state.value of
        Just float ->
            applyAmount newModel (Amount.fromFloat float)

        Nothing ->
            createPageUpdate session newModel


applyElementAmount : Session -> Model -> Query -> TargetElement -> Amount -> PageUpdate Model Msg
applyElementAmount session model query targetElement amount =
    case Component.updateElementAmount session.db targetElement amount query.items of
        Err error ->
            createPageUpdate session model
                |> App.notifyError "Erreur de mise à jour de la quantité" error

        Ok items ->
            createPageUpdate session model
                |> updateQuery (Component.setQueryItems items query)


applyFloatInputState : FloatInput.State -> Model -> Model
applyFloatInputState state model =
    { model
        | floatInputState =
            model.floatInputState
                |> FloatInput.applyState state
    }


applyItemUnitMass : Session -> Model -> Query -> Index -> Mass -> PageUpdate Model Msg
applyItemUnitMass session model query itemIndex mass =
    let
        currentUnitMassAllowsEdit =
            Result.toMaybe model.lifeCycle
                |> Maybe.andThen (.production >> Component.extractItems >> LE.getAt itemIndex)
                |> Maybe.map (\itemResults -> Mass.inKilograms (Component.extractUnitMass itemResults) > 0)
                |> Maybe.withDefault True

        hasMass =
            mass |> Quantity.greaterThan Quantity.zero
    in
    if hasMass && currentUnitMassAllowsEdit then
        createPageUpdate session model
            |> updateQuery
                (query
                    |> Component.mapItems
                        (Component.updateItem itemIndex
                            (\item -> { item | unitMass = Just mass })
                        )
                )

    else
        createPageUpdate session model


applyUnitMassInputState : Session -> Model -> Query -> Index -> FloatInput.State -> PageUpdate Model Msg
applyUnitMassInputState session model query itemIndex state =
    let
        newModel =
            model |> applyFloatInputState state
    in
    case state.value of
        Just kilograms ->
            Mass.kilograms kilograms
                |> applyItemUnitMass session newModel query itemIndex

        Nothing ->
            createPageUpdate session newModel


update : Session -> Msg -> Model -> PageUpdate Model Msg
update ({ navKey } as session) msg model =
    let
        globalScope =
            Sector.Generic model.genericSector

        query =
            session
                |> Session.genericQuery model.genericSector

        requirements =
            { config = session.componentConfig
            , db = session.db
            , sector = globalScope
            }
    in
    case msg of
        AppendModal modal ->
            { model | modals = modal :: model.modals } |> createPageUpdate session

        CopyToClipBoard shareableLink ->
            createPageUpdate session model |> App.withCmds [ Ports.copyToClipboard shareableLink ]

        CreateExampleContrib ->
            if Session.isAuthenticated session then
                case createExampleContribData model of
                    Err errors ->
                        { model | contributionRequestPending = False } |> createPageUpdate session |> App.notifyError "Erreur lors de la création de votre contribution" (String.join ", " errors)

                    Ok contribData ->
                        { model | contributionRequestPending = True } |> createPageUpdate session |> App.withCmds [ Contrib.createExampleContrib session contribData ExampleContribCreated ]

            else
                { model | contributionRequestPending = False } |> createPageUpdate session |> App.notifyWarning "Vous devez être authentifié pour soumettre une contribution"

        DeleteBookmark bookmark ->
            model |> createPageUpdate (session |> Session.deleteBookmark bookmark)

        ExampleContribCreated (RemoteData.Failure error) ->
            { model | contributionRequestPending = False } |> createPageUpdate session |> App.notifyError "Erreur de contribution" (BackendHttpError.errorToString error)

        ExampleContribCreated (RemoteData.Success { pullRequestUrl }) ->
            { model | contributionRequestPending = False } |> createPageUpdate session |> App.notifySuccess ("La contribution est soumise à validation par l’équipe méthode d’Ecobalyse.\n                              Vous pouvez suivre [sur ce lien](pr_url) l’état d’avancement de l’intégration de votre exemple de produit.\n                              " |> String.replace "pr_url" pullRequestUrl)

        ExampleContribCreated _ ->
            createPageUpdate session model

        ExportBookmarks ->
            createPageUpdate session model |> App.withCmds [ Ports.exportBookmarks () ]

        ImportBookmarks ->
            createPageUpdate session model |> App.withCmds [ Ports.importBookmarks () ]

        NoOp ->
            createPageUpdate session model

        OnAutocompleteAddAssemblyOperation autocompleteMsg ->
            case model.modals of
                (SelectAssemblyOperationModal autocompleteState) :: otherModals ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    { model | modals = SelectAssemblyOperationModal newAutocompleteState :: otherModals }
                        |> createPageUpdate session
                        |> App.withCmds [ Cmd.map OnAutocompleteAddAssemblyOperation autoCompleteCmd ]

                _ ->
                    createPageUpdate session model

        OnAutocompleteAddConsumption autocompleteMsg ->
            case model.modals of
                (SelectConsumptionModal autocompleteState) :: otherModals ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    { model | modals = SelectConsumptionModal newAutocompleteState :: otherModals }
                        |> createPageUpdate session
                        |> App.withCmds [ Cmd.map OnAutocompleteAddConsumption autoCompleteCmd ]

                _ ->
                    createPageUpdate session model

        OnAutocompleteAddProcess category targetItem maybeIndex autocompleteMsg ->
            case model.modals of
                (SelectProcessModal _ _ _ autocompleteState) :: otherModals ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    { model | modals = SelectProcessModal category targetItem maybeIndex newAutocompleteState :: otherModals }
                        |> createPageUpdate session
                        |> App.withCmds [ Cmd.map (OnAutocompleteAddProcess category targetItem maybeIndex) autoCompleteCmd ]

                _ ->
                    createPageUpdate session model

        OnAutocompleteAddProductionItem autocompleteMsg ->
            case model.modals of
                (AddProductionItemModal autocompleteState) :: otherModals ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    { model | modals = AddProductionItemModal newAutocompleteState :: otherModals }
                        |> createPageUpdate session
                        |> App.withCmds [ Cmd.map OnAutocompleteAddProductionItem autoCompleteCmd ]

                _ ->
                    createPageUpdate session model

        OnAutocompleteExample autocompleteMsg ->
            case model.modals of
                (SelectExampleModal autocompleteState) :: otherModals ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    { model | modals = SelectExampleModal newAutocompleteState :: otherModals }
                        |> createPageUpdate session
                        |> App.withCmds [ Cmd.map OnAutocompleteExample autoCompleteCmd ]

                _ ->
                    createPageUpdate session model

        OnAutocompletePackaging autocompleteMsg ->
            case model.modals of
                (SelectPackagingModal autocompleteState) :: otherModals ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    { model | modals = SelectPackagingModal newAutocompleteState :: otherModals }
                        |> createPageUpdate session
                        |> App.withCmds [ Cmd.map OnAutocompletePackaging autoCompleteCmd ]

                _ ->
                    createPageUpdate session model

        OnAutocompleteSelectAssemblyOperation ->
            case model.modals of
                (SelectAssemblyOperationModal autocompleteState) :: _ ->
                    createPageUpdate session model
                        |> selectAssemblyOperation requirements query autocompleteState

                _ ->
                    createPageUpdate session model

        OnAutocompleteSelectConsumption ->
            case model.modals of
                (SelectConsumptionModal autocompleteState) :: _ ->
                    createPageUpdate session model
                        |> selectConsumption requirements query autocompleteState

                _ ->
                    createPageUpdate session model

        OnAutocompleteSelectExample ->
            case model.modals of
                (SelectExampleModal autocompleteState) :: _ ->
                    createPageUpdate session model
                        |> selectExample autocompleteState

                _ ->
                    createPageUpdate session model

        OnAutocompleteSelectPackaging ->
            case model.modals of
                (SelectPackagingModal autocompleteState) :: _ ->
                    createPageUpdate session model
                        |> addPackaging query autocompleteState

                _ ->
                    createPageUpdate session model

        OnAutocompleteSelectProcess category targetItem elementIndex ->
            case model.modals of
                (SelectProcessModal _ _ _ autocompleteState) :: _ ->
                    createPageUpdate session model
                        |> selectProcess category targetItem elementIndex autocompleteState query

                _ ->
                    createPageUpdate session model

        OnAutocompleteSelectProductionItem ->
            case model.modals of
                (AddProductionItemModal autocompleteState) :: _ ->
                    createPageUpdate session model
                        |> selectProductionItem query autocompleteState

                _ ->
                    createPageUpdate session model

        OnDragLeaveBookmark ->
            { model | bookmarkBeingOvered = Nothing }
                |> createPageUpdate session

        OnDragOverBookmark bookmarkBeingOvered ->
            { model | bookmarkBeingOvered = Just bookmarkBeingOvered }
                |> createPageUpdate session

        OnDragStartBookmark bookmark ->
            { model | bookmarkBeingDragged = Just bookmark }
                |> createPageUpdate session

        OnDropBookmark target ->
            case model.bookmarkBeingDragged of
                Just dragged ->
                    { model | bookmarkBeingDragged = Nothing, bookmarkBeingOvered = Nothing }
                        |> createPageUpdate
                            (session
                                |> Session.moveBookmark dragged target
                            )

                Nothing ->
                    createPageUpdate session model

        OpenComparator ->
            { model | modals = [ ComparatorModal ] }
                |> createPageUpdate (session |> Session.checkComparedSimulations)
                |> App.withCmds
                    [ Plausible.send session <| Plausible.ComparatorOpened globalScope
                    , Ports.loadCharts ()
                    ]

        RemoveAssemblyOperation index ->
            createPageUpdate session model
                |> updateQuery (query |> Component.removeAssemblyOperation requirements index)

        RemoveComponentItem itemIndex ->
            { model
                | detailedComponents =
                    model.detailedComponents
                        |> LE.remove itemIndex
                        |> LE.updateIf (\x -> x > itemIndex) (\x -> x - 1)
            }
                |> createPageUpdate session
                |> updateQuery (query |> Component.mapItems (LE.removeAt itemIndex))
                |> App.withCmds [ Plausible.send session <| Plausible.ComponentUpdated globalScope ]

        RemoveConsumption index ->
            createPageUpdate session model
                |> updateQuery (query |> Component.removeConsumption requirements index)

        RemoveElement targetElement ->
            createPageUpdate session model
                |> updateQuery (query |> Component.mapItems (Component.removeElement targetElement))
                |> App.withCmds [ Plausible.send session <| Plausible.ComponentUpdated globalScope ]

        RemoveElementTransform targetElement transformIndex ->
            createPageUpdate session model
                |> updateQuery
                    (query
                        |> Component.mapItems
                            (Component.removeElementTransform targetElement transformIndex)
                    )
                |> App.withCmds [ Plausible.send session <| Plausible.ComponentUpdated globalScope ]

        RemovePackaging index ->
            createPageUpdate session model
                |> updateQuery (query |> Component.removePackaging index)

        RenameBookmark ->
            case model.bookmarkBeingRenamed of
                Just bookmark ->
                    { model | bookmarkBeingRenamed = Nothing }
                        |> createPageUpdate
                            (session
                                |> Session.replaceBookmark bookmark
                            )

                Nothing ->
                    createPageUpdate session model

        SaveBookmark ->
            createPageUpdate session model
                |> App.withCmds
                    [ Time.now
                        |> Task.perform
                            (query
                                |> Bookmark.Generic model.genericSector
                                |> SaveBookmarkWithTime model.bookmarkName
                            )
                    , Plausible.send session <| Plausible.BookmarkSaved globalScope
                    ]

        SaveBookmarkWithTime name bookmarkQuery now ->
            model
                |> createPageUpdate
                    (session
                        |> Session.saveBookmark
                            { name = String.trim name
                            , query = bookmarkQuery
                            , created = now
                            , genericSector = Nothing
                            }
                    )

        SelectAllBookmarks ->
            model
                |> createPageUpdate (Session.selectAllBookmarks session)

        SelectNoBookmarks ->
            model
                |> createPageUpdate (Session.selectNoBookmarks session)

        SetDetailedComponents detailedComponents ->
            { model | detailedComponents = detailedComponents }
                |> createPageUpdate session

        SetModals modals ->
            createPageUpdate session { model | modals = modals }
                |> App.withCmdIf (List.any isAutocompleteModal modals) (AutocompleteSelectorView.focusInput NoOp)

        SwitchBookmarksTab bookmarkTab ->
            { model | bookmarkTab = bookmarkTab }
                |> createPageUpdate session
                |> App.withCmds
                    [ Plausible.TabSelected (Sector.Generic model.genericSector) "Partager"
                        |> Plausible.sendIf session (bookmarkTab == BookmarkView.ShareTab)
                    ]

        SwitchComparisonType displayChoice ->
            { model | comparisonType = displayChoice }
                |> createPageUpdate session
                |> App.withCmds
                    [ ComparatorView.comparisonTypeToString displayChoice
                        |> Plausible.ComparisonTypeSelected globalScope
                        |> Plausible.send session
                    ]

        SwitchImpact (Err error) ->
            createPageUpdate session model
                |> App.notifyError "Erreur de sélection d'impact" error

        SwitchImpact (Ok trigram) ->
            createPageUpdate session model
                |> App.withCmds
                    [ Just query
                        |> Route.GenericSimulator model.genericSector trigram
                        |> Route.toString
                        |> Navigation.pushUrl navKey
                    , Plausible.send session <| Plausible.ImpactSelected globalScope trigram
                    ]

        SwitchImpactsTab impactsTab ->
            { model | activeImpactsTab = impactsTab }
                |> createPageUpdate session
                |> App.withCmds
                    [ ImpactTabs.tabToString impactsTab
                        |> Plausible.TabSelected globalScope
                        |> Plausible.send session
                    ]

        ToggleComparedSimulation bookmark checked ->
            model
                |> createPageUpdate (session |> Session.toggleComparedSimulation bookmark checked)

        ToggleTransportByAir byAir ->
            createPageUpdate session model
                |> updateQuery (query |> Component.setTransportByAir byAir)

        ToggleTransportCooling cooling ->
            createPageUpdate session model
                |> updateQuery (query |> Component.setTransportCooling cooling)

        UpdateAssemblyCountry maybeCountry ->
            createPageUpdate session model
                |> updateQuery (query |> Component.updateAssemblyCountry maybeCountry)

        UpdateBookmarkName newName ->
            { model | bookmarkName = newName }
                |> createPageUpdate session

        UpdateComponentItemName targetItem name ->
            createPageUpdate session model
                |> updateQuery
                    (query
                        |> Component.mapItems (Component.updateItemCustomName targetItem name)
                    )

        UpdateComponentItemQuantity itemIndex quantity ->
            createPageUpdate session model
                |> updateQuery
                    (query
                        |> Component.mapItems (Component.updateItem itemIndex (\item -> { item | quantity = quantity }))
                    )
                |> App.withCmds [ Plausible.send session <| Plausible.ComponentUpdated globalScope ]

        UpdateConsumptionAmount index state ->
            ( session, model )
                |> applyAmountInputState state
                    (\newModel amount ->
                        createPageUpdate session newModel
                            |> updateQuery (query |> Component.updateConsumptionAmount requirements index amount)
                    )

        UpdateContributionDescription description ->
            { model | contributionDescription = description }
                |> createPageUpdate session

        UpdateContributionName name ->
            { model | contributionName = name }
                |> createPageUpdate session

        UpdateDistribution (Ok distributionProcessId) ->
            createPageUpdate session model
                |> updateQuery (query |> Component.updateDistribution (Just distributionProcessId))

        UpdateDistribution (Err error) ->
            createPageUpdate session model
                |> App.notifyError "Erreur de sélection du procédé de distribution" error

        UpdateDurability (Ok durability) ->
            createPageUpdate session model
                |> updateQuery (query |> Component.updateDurability durability)

        UpdateDurability (Err error) ->
            createPageUpdate session model
                |> App.notifyError "Erreur de durabilité" error

        UpdateElementAmount targetElement state ->
            ( session, model )
                |> applyAmountInputState state
                    (\newModel -> applyElementAmount session newModel query targetElement)

        UpdateElementMaterialCountry targetElement maybeCountryCode ->
            createPageUpdate session model
                |> updateQuery
                    (query
                        |> Component.mapItems
                            (Component.updateElementMaterialCountry targetElement maybeCountryCode)
                    )
                |> App.withCmds [ Plausible.send session <| Plausible.ComponentUpdated globalScope ]

        UpdateElementTransformCountry targetElement transformIndex maybeCountryCode ->
            createPageUpdate session model
                |> updateQuery
                    (query
                        |> Component.mapItems
                            (Component.updateElementTransformCountry targetElement transformIndex maybeCountryCode)
                    )
                |> App.withCmds [ Plausible.send session <| Plausible.ComponentUpdated globalScope ]

        UpdateItemUnitMass itemIndex state ->
            applyUnitMassInputState session model query itemIndex state

        UpdatePackagingAmount index state ->
            ( session, model )
                |> applyAmountInputState state
                    (\newModel amount ->
                        createPageUpdate session newModel
                            |> updateQuery (query |> Component.updatePackagingAmount index amount)
                    )

        UpdateProduct maybeProductId ->
            createPageUpdate session model
                |> selectProductCategory session query maybeProductId

        UpdateRecyclability recyclable ->
            createPageUpdate session model
                |> updateQuery (query |> Component.updateRecyclable recyclable)

        UpdateRenamedBookmarkName bookmark name ->
            { model | bookmarkBeingRenamed = Just { bookmark | name = name } }
                |> createPageUpdate session


{-| Create a page update preventing the body to be scrollable when one or more modals are opened.
-}
createPageUpdate : Session -> Model -> PageUpdate Model Msg
createPageUpdate session model =
    App.createUpdate session model
        |> App.withCmds
            [ case model.modals of
                [] ->
                    Ports.removeBodyClass "prevent-scrolling"

                _ ->
                    Ports.addBodyClass "prevent-scrolling"
            ]


createExampleContribData : Model -> Result (List String) Contrib.ExampleContribData
createExampleContribData model =
    let
        ( cleanDescription, cleanName ) =
            ( String.trim model.contributionDescription
            , String.trim model.contributionName
            )
    in
    if String.isEmpty cleanName then
        Err [ "Le nom de la contribution est requis" ]

    else if String.isEmpty cleanDescription then
        Err [ "La description de la contribution est requise" ]

    else
        Ok
            { description = cleanDescription
            , name = cleanName
            , query = model.initialQuery
            , sector = Sector.Generic model.genericSector
            }


isAutocompleteModal : Modal -> Bool
isAutocompleteModal modal =
    case modal of
        AddProductionItemModal _ ->
            True

        SelectAssemblyOperationModal _ ->
            True

        SelectConsumptionModal _ ->
            True

        SelectExampleModal _ ->
            True

        SelectProcessModal _ _ _ _ ->
            True

        _ ->
            False


isItemEditModalOpen : List Modal -> Bool
isItemEditModalOpen =
    List.any
        (\modal ->
            case modal of
                ItemEditModal _ ->
                    True

                _ ->
                    False
        )


selectExample : Autocomplete Query -> PageUpdate Model Msg -> PageUpdate Model Msg
selectExample autocompleteState ({ model } as pageUpdate) =
    let
        exampleQuery =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.withDefault Component.emptyQuery
    in
    pageUpdate
        |> updateQuery exampleQuery
        |> App.apply update (SetModals [])
        |> App.withCmds [ Plausible.send pageUpdate.session <| Plausible.ExampleSelected (Sector.Generic model.genericSector) ]


selectProductionItem : Query -> Autocomplete Component.ProductionItem -> PageUpdate Model Msg -> PageUpdate Model Msg
selectProductionItem query autocompleteState ({ model, session } as pageUpdate) =
    let
        plausibleCommand =
            Plausible.send pageUpdate.session <| Plausible.ComponentAdded (Sector.Generic model.genericSector)
    in
    case Autocomplete.selectedValue autocompleteState of
        Just (Component.ComponentItem component) ->
            pageUpdate
                |> updateQuery (query |> Component.mapItems (Component.addItem component.id))
                |> App.apply update (SetModals [])
                |> App.withCmds [ plausibleCommand ]

        Just (Component.MaterialItem process) ->
            let
                newItemIndex =
                    List.length query.items

                newItem =
                    { custom = Nothing
                    , id = Nothing
                    , quantity = Component.quantityFromInt 1
                    , unitMass = Nothing
                    }

                targetItem =
                    ( Component.emptyComponent, newItemIndex )
            in
            case
                { query | items = query.items ++ [ newItem ] }
                    |> Component.tryMapItems
                        (Component.addOrSetProcess session.db Category.Material targetItem Nothing process)
            of
                Err error ->
                    pageUpdate |> App.notifyError "Erreur" error

                Ok validQuery ->
                    pageUpdate
                        |> updateQuery validQuery
                        |> App.apply update (SetModals [])
                        |> App.withCmds [ plausibleCommand ]

        Nothing ->
            pageUpdate |> App.notifyWarning "Aucun composant sélectionné"


selectAssemblyOperation : Component.Requirements Db -> Query -> Autocomplete Process -> PageUpdate Model Msg -> PageUpdate Model Msg
selectAssemblyOperation requirements query autocompleteState pageUpdate =
    case Autocomplete.selectedValue autocompleteState of
        Just process ->
            pageUpdate
                |> updateQuery (query |> Component.addAssemblyOperation requirements process)
                |> App.apply update (SetModals [])

        Nothing ->
            pageUpdate |> App.notifyWarning "Aucun procédé d’assemblage sélectionné"


selectConsumption :
    Component.Requirements db
    -> Query
    -> Autocomplete Process
    -> PageUpdate Model Msg
    -> PageUpdate Model Msg
selectConsumption requirements query autocompleteState ({ model } as pageUpdate) =
    case Autocomplete.selectedValue autocompleteState of
        Just process ->
            pageUpdate
                |> updateQuery (query |> Component.addConsumption requirements process)
                |> App.apply update (SetModals [])
                |> App.withCmds [ Plausible.send pageUpdate.session <| Plausible.ConsumptionAdded (Sector.Generic model.genericSector) ]

        Nothing ->
            pageUpdate |> App.notifyWarning "Aucun composant sélectionné"


addPackaging : Query -> Autocomplete Process -> PageUpdate Model Msg -> PageUpdate Model Msg
addPackaging query autocompleteState pageUpdate =
    case Autocomplete.selectedValue autocompleteState of
        Just process ->
            pageUpdate
                |> updateQuery
                    { query
                        | packagings =
                            query.packagings
                                ++ [ Component.packaging (Amount.fromFloat 1) process.id ]
                    }
                |> App.apply update (SetModals [])

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
selectProcess category targetItem maybeElementIndex autocompleteState query ({ model, session } as pageUpdate) =
    case Autocomplete.selectedValue autocompleteState of
        Just process ->
            case
                query
                    |> Component.tryMapItems
                        (Component.addOrSetProcess session.db category targetItem maybeElementIndex process)
            of
                Err err ->
                    pageUpdate |> App.notifyError "Erreur" err

                Ok validQuery ->
                    pageUpdate
                        |> updateQuery validQuery
                        |> App.apply update (SetModals (List.drop 1 model.modals))
                        |> App.withCmds [ Plausible.send pageUpdate.session <| Plausible.ComponentUpdated (Sector.Generic model.genericSector) ]

        Nothing ->
            pageUpdate |> App.notifyWarning "Aucun composant sélectionné"


{-| Simulator actions that count as usage.
-}
shouldTrackUsage : Msg -> Bool
shouldTrackUsage msg =
    case msg of
        AppendModal _ ->
            False

        CopyToClipBoard _ ->
            False

        CreateExampleContrib ->
            False

        DeleteBookmark _ ->
            False

        ExampleContribCreated _ ->
            False

        ExportBookmarks ->
            False

        ImportBookmarks ->
            False

        NoOp ->
            False

        OnAutocompleteAddAssemblyOperation _ ->
            False

        OnAutocompleteAddConsumption _ ->
            False

        OnAutocompleteAddProcess _ _ _ _ ->
            False

        OnAutocompleteAddProductionItem _ ->
            False

        OnAutocompleteExample _ ->
            False

        OnAutocompletePackaging _ ->
            False

        OnAutocompleteSelectAssemblyOperation ->
            True

        OnAutocompleteSelectConsumption ->
            True

        OnAutocompleteSelectExample ->
            True

        OnAutocompleteSelectPackaging ->
            True

        OnAutocompleteSelectProcess _ _ _ ->
            True

        OnAutocompleteSelectProductionItem ->
            True

        OnDragLeaveBookmark ->
            False

        OnDragOverBookmark _ ->
            False

        OnDragStartBookmark _ ->
            False

        OnDropBookmark _ ->
            False

        OpenComparator ->
            False

        RemoveAssemblyOperation _ ->
            True

        RemoveComponentItem _ ->
            True

        RemoveConsumption _ ->
            True

        RemoveElement _ ->
            True

        RemoveElementTransform _ _ ->
            True

        RemovePackaging _ ->
            True

        RenameBookmark ->
            False

        SaveBookmark ->
            False

        SaveBookmarkWithTime _ _ _ ->
            False

        SelectAllBookmarks ->
            False

        SelectNoBookmarks ->
            False

        SetDetailedComponents _ ->
            False

        SetModals _ ->
            False

        SwitchBookmarksTab _ ->
            False

        SwitchComparisonType _ ->
            True

        SwitchImpact _ ->
            True

        SwitchImpactsTab _ ->
            True

        ToggleComparedSimulation _ _ ->
            True

        ToggleTransportByAir _ ->
            True

        ToggleTransportCooling _ ->
            True

        UpdateAssemblyCountry _ ->
            True

        UpdateBookmarkName _ ->
            False

        UpdateComponentItemName _ _ ->
            False

        UpdateComponentItemQuantity _ _ ->
            True

        UpdateConsumptionAmount _ _ ->
            True

        UpdateContributionDescription _ ->
            False

        UpdateContributionName _ ->
            False

        UpdateDistribution _ ->
            True

        UpdateDurability _ ->
            False

        UpdateElementAmount _ _ ->
            True

        UpdateElementMaterialCountry _ _ ->
            True

        UpdateElementTransformCountry _ _ _ ->
            True

        UpdateItemUnitMass _ _ ->
            True

        UpdatePackagingAmount _ _ ->
            True

        UpdateProduct _ ->
            True

        UpdateRecyclability _ ->
            True

        UpdateRenamedBookmarkName _ _ ->
            False


editorConfig : Session -> Model -> ComponentView.Config Db Msg
editorConfig session ({ genericSector } as model) =
    let
        sector =
            Sector.Generic genericSector
    in
    { componentConfig = session.componentConfig
    , context = Context.Generic
    , db = session.db
    , debug = True
    , detailed = model.detailedComponents
    , docsUrl = Nothing
    , explorerRoute = Just (Route.Explore sector (Dataset.Components sector Nothing))
    , floatInputState = model.floatInputState
    , impact = model.impact
    , labels = ComponentView.scopeLabels Context.Generic sector
    , noOp = NoOp
    , openItemEditModal = \targetItem -> AppendModal (ItemEditModal targetItem)
    , openSelectAssemblyOperationModal = SelectAssemblyOperationModal >> AppendModal
    , openSelectConsumptionModal = SelectConsumptionModal >> AppendModal
    , openSelectPackagingModal = SelectPackagingModal >> AppendModal
    , openSelectProcessModal = \c ti mi ac -> AppendModal (SelectProcessModal c ti mi ac)
    , openSelectProductionItem = AddProductionItemModal >> AppendModal
    , query = session |> Session.genericQuery genericSector
    , removeAssemblyOperation = RemoveAssemblyOperation
    , removeConsumption = RemoveConsumption
    , removeElement = RemoveElement
    , removeElementTransform = RemoveElementTransform
    , removeItem = RemoveComponentItem
    , removePackaging = RemovePackaging
    , lifeCycle = model.lifeCycle
    , sector = sector
    , setDetailed = SetDetailedComponents
    , toggleTransportByAir = ToggleTransportByAir
    , unitMassLocked = isItemEditModalOpen model.modals
    , toggleTransportCooling = ToggleTransportCooling
    , updateAssemblyCountry = UpdateAssemblyCountry
    , updateConsumptionAmount = UpdateConsumptionAmount
    , updateDistribution = UpdateDistribution
    , updateElementAmount = UpdateElementAmount
    , updateElementMaterialCountry = UpdateElementMaterialCountry
    , updateElementTransformCountry = UpdateElementTransformCountry
    , updateItemName = UpdateComponentItemName
    , updateItemQuantity = UpdateComponentItemQuantity
    , updateItemUnitMass = UpdateItemUnitMass
    , updatePackagingAmount = UpdatePackagingAmount
    , updateRecyclable = UpdateRecyclability
    }


simulatorView : Session -> Model -> Html Msg
simulatorView ({ componentConfig } as session) ({ genericSector } as model) =
    let
        sector =
            Sector.Generic genericSector

        currentQuery =
            session |> Session.genericQuery genericSector
    in
    div [ class "row" ]
        [ div [ class "col-lg-8 bg-white" ]
            [ h1 [ class "visually-hidden" ] [ text "Simulateur " ]
            , div [ class "sticky-md-top bg-white pb-3" ]
                [ ExampleView.view
                    { currentQuery = currentQuery
                    , emptyQuery = Component.emptyQuery
                    , examples = model.examples
                    , helpUrl = Nothing
                    , onOpen = SelectExampleModal >> AppendModal
                    , routes =
                        { explore = Route.Explore sector (Dataset.GenericExamples genericSector Nothing)
                        , load = Route.GenericSimulatorExample genericSector
                        , scopeHome = Route.GenericSimulatorHome genericSector
                        }
                    }
                , ComponentView.productCategorySelectorView
                    { onSelect = UpdateProduct
                    , products = session.db.products
                    , query = currentQuery
                    , sector = genericSector
                    }
                ]
            , durabilityView componentConfig sector currentQuery.durability
            , editorConfig session model
                |> ComponentView.editorView
            ]
        , div [ class "col-lg-4 bg-white" ]
            [ let
                lifeCycle =
                    model.lifeCycle
                        |> Result.withDefault Component.emptyLifeCycle
              in
              SidebarView.view
                { noOp = NoOp
                , session = session
                , sector = sector

                -- Impact selector
                , selectedImpact = model.impact
                , switchImpact = SwitchImpact

                -- Score
                , customScoreInfo = Nothing
                , productMass = lifeCycle.productMass
                , totalImpacts = lifeCycle |> Component.applyDurability currentQuery.durability
                , totalImpactsWithoutDurability = lifeCycle |> Component.sumLifeCycleImpacts |> Just

                -- Impacts tabs
                , impactTabsConfig =
                    if not <| List.isEmpty currentQuery.items then
                        SwitchImpactsTab
                            |> ImpactTabs.createConfig session model.impact model.activeImpactsTab (always NoOp)
                            |> ImpactTabs.forGeneric session.db.definitions lifeCycle
                            |> Just

                    else
                        Nothing

                -- Bookmarks
                , activeBookmarkTab = model.bookmarkTab
                , bookmarkBeingRenamed = model.bookmarkBeingRenamed
                , bookmarkName = model.bookmarkName
                , copyToClipBoard = CopyToClipBoard
                , compareBookmarks = OpenComparator
                , deleteBookmark = DeleteBookmark
                , exportBookmarks = ExportBookmarks
                , importBookmarks = ImportBookmarks
                , renameBookmark = RenameBookmark
                , saveBookmark = SaveBookmark
                , updateBookmarkName = UpdateBookmarkName
                , updateRenamedBookmarkName = UpdateRenamedBookmarkName
                , switchBookmarkTab = SwitchBookmarksTab

                -- Contribution
                , contribName = model.contributionName
                , contribDescription = model.contributionDescription
                , contribRequestPending = model.contributionRequestPending
                , createExampleContrib = CreateExampleContrib
                , updateContribName = UpdateContributionName
                , updateContribDescription = UpdateContributionDescription
                }
            ]
        ]


durabilityView : Component.Config -> Sector -> Maybe Unit.Ratio -> Html Msg
durabilityView componentConfig sector maybeDurability =
    if componentConfig.durability |> Config.scopeEnabled sector |> not then
        text ""

    else
        -- Note: this is considered a temporary implementation for object and veli simulators,
        -- things might actually want to be factored out and appropriately typed and handled
        -- when ongoing discussions around holostic durability are completed.
        let
            currentDurability =
                maybeDurability
                    |> Maybe.withDefault Component.defaultDurability
        in
        div [ class "card shadow-sm pb-2 mb-3" ]
            [ div [ class "card-header d-flex justify-content-between align-items-center" ]
                [ h2 [ class "h5 mb-1 text-truncate" ] [ text "Durabilité" ]
                , div [ class "d-flex align-items-center gap-2" ]
                    [ case Component.getDocLink componentConfig sector "durability" of
                        Just docUrl ->
                            Button.docsPillLink
                                [ class "bg-secondary"
                                , style "height" "24px"
                                , href docUrl
                                , title "Documentation"
                                , target "_blank"
                                ]
                                [ Icon.question ]

                        Nothing ->
                            text ""
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
                        , onClick (UpdateDurability (Ok Component.defaultDurability))
                        , title "Réinitialiser la durabilité"
                        , disabled (maybeDurability == Nothing || maybeDurability == Just Component.defaultDurability)
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
            , List.head model.modals
                |> Maybe.map (modalView session model)
                |> Maybe.withDefault (text "")
            ]
      ]
    )


modalView : Session -> Model -> Modal -> Html Msg
modalView session ({ modals } as model) modal =
    let
        scopeLabels =
            ComponentView.scopeLabels Context.Generic (Sector.Generic model.genericSector)
    in
    case modal of
        AddProductionItemModal autocompleteState ->
            AutocompleteSelectorView.view
                { autocompleteState = autocompleteState
                , closeModal = SetModals (List.drop 1 modals)
                , footer = []
                , onAutocomplete = OnAutocompleteAddProductionItem
                , onAutocompleteSelect = OnAutocompleteSelectProductionItem
                , placeholderText = scopeLabels.search
                , title = scopeLabels.select
                , toLabel = Component.productionItemToLabel
                , toCategory = always ""
                }

        ComparatorModal ->
            ModalView.view
                { size = ModalView.ExtraLarge
                , close = SetModals (List.drop 1 modals)
                , title = "Comparateur de simulations sauvegardées"
                , subTitle = Just "Coût environnemental, par produit"
                , formAction = Nothing
                , content =
                    [ ComparatorView.view
                        { bookmarkBeingOvered = model.bookmarkBeingOvered
                        , comparisonType = model.comparisonType
                        , impact = model.impact
                        , onDragLeaveBookmark = OnDragLeaveBookmark
                        , onDragOverBookmark = OnDragOverBookmark
                        , onDragStartBookmark = OnDragStartBookmark
                        , onDropBookmark = OnDropBookmark
                        , selectAll = SelectAllBookmarks
                        , selectNone = SelectNoBookmarks
                        , session = session
                        , switchComparisonType = SwitchComparisonType
                        , toggle = ToggleComparedSimulation
                        }
                    ]
                , footer = []
                }

        ItemEditModal targetItem ->
            ModalView.view
                { size = ModalView.Fluid
                , close = SetModals (List.drop 1 modals)
                , title = "Paramètres et composition"
                , subTitle = Nothing
                , formAction = Nothing
                , content =
                    [ targetItem
                        |> ComponentView.itemEditorView (editorConfig session model)
                    ]
                , footer = []
                }

        SelectAssemblyOperationModal autocompleteState ->
            AutocompleteSelectorView.view
                { autocompleteState = autocompleteState
                , closeModal = SetModals (List.drop 1 modals)
                , footer = []
                , onAutocomplete = OnAutocompleteAddAssemblyOperation
                , onAutocompleteSelect = OnAutocompleteSelectAssemblyOperation
                , placeholderText = "tapez ici le nom d'un procédé d'assemblage pour le rechercher"
                , title = "Sélectionnez un procédé d'assemblage"
                , toLabel = Process.getDisplayName
                , toCategory = .unit >> Process.unitToString
                }

        SelectConsumptionModal autocompleteState ->
            AutocompleteSelectorView.view
                { autocompleteState = autocompleteState
                , closeModal = SetModals (List.drop 1 modals)
                , footer = []
                , onAutocomplete = OnAutocompleteAddConsumption
                , onAutocompleteSelect = OnAutocompleteSelectConsumption
                , placeholderText = "tapez ici le nom d'un procédé de consommation pour le rechercher"
                , title = "Sélectionnez une consommation"
                , toLabel = Process.getDisplayName
                , toCategory = .unit >> Process.unitToString
                }

        SelectExampleModal autocompleteState ->
            AutocompleteSelectorView.view
                { autocompleteState = autocompleteState
                , closeModal = SetModals (List.drop 1 modals)
                , footer = []
                , onAutocomplete = OnAutocompleteExample
                , onAutocompleteSelect = OnAutocompleteSelectExample
                , placeholderText = "tapez ici le nom du produit pour le rechercher"
                , title = "Sélectionnez un produit"
                , toLabel = Example.toName model.examples
                , toCategory = Example.toCategory model.examples
                }

        SelectPackagingModal autocompleteState ->
            AutocompleteSelectorView.view
                { autocompleteState = autocompleteState
                , closeModal = SetModals (List.drop 1 modals)
                , footer = []
                , onAutocomplete = OnAutocompletePackaging
                , onAutocompleteSelect = OnAutocompleteSelectPackaging
                , placeholderText = "tapez ici le nom d'un emballage pour le rechercher"
                , title = "Sélectionnez un emballage"
                , toLabel = Process.getDisplayName
                , toCategory = .unit >> Process.unitToString
                }

        SelectProcessModal category targetItem maybeElementIndex autocompleteState ->
            let
                ( placeholderText, title ) =
                    case category of
                        Category.Material ->
                            ( "tapez ici le nom d'une matière première pour la rechercher"
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
                , closeModal = SetModals (List.drop 1 modals)
                , footer = []
                , onAutocomplete = OnAutocompleteAddProcess category targetItem maybeElementIndex
                , onAutocompleteSelect = OnAutocompleteSelectProcess category targetItem maybeElementIndex
                , placeholderText = placeholderText
                , title = title
                , toLabel = Process.getDisplayName
                , toCategory = .unit >> Process.unitToString
                }


subscriptions : Model -> Sub Msg
subscriptions { modals } =
    case modals of
        [] ->
            Sub.none

        _ :: remainingModals ->
            Browser.Events.onKeyDown (Key.escape (SetModals remainingModals))
