module Page.Textile.Simulator exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Array
import Autocomplete exposing (Autocomplete)
import Browser.Dom as Dom
import Browser.Events
import Browser.Navigation as Navigation
import Data.AutocompleteSelector as AutocompleteSelector
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Country as Country
import Data.Impact as Impact
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Data.Split exposing (Split)
import Data.Textile.Db as TextileDb
import Data.Textile.DyeingMedium exposing (DyeingMedium)
import Data.Textile.Fabric as Fabric exposing (Fabric)
import Data.Textile.HeatSource exposing (HeatSource)
import Data.Textile.Inputs as Inputs
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Textile.Material.Spinning exposing (Spinning)
import Data.Textile.Printing exposing (Printing)
import Data.Textile.Product as Product
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Data.Textile.Step.Label exposing (Label)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass
import Platform.Cmd as Cmd
import Ports
import Route
import Task
import Time exposing (Posix)
import Views.Alert as Alert
import Views.AutocompleteSelector as AutocompleteSelector
import Views.Bookmark as BookmarkView
import Views.Comparator as ComparatorView
import Views.Component.DownArrow as DownArrow
import Views.Container as Container
import Views.Format as Format
import Views.ImpactTabs as ImpactTabs
import Views.Modal as ModalView
import Views.Sidebar as SidebarView
import Views.Textile.Step as StepView


type alias Model =
    { simulator : Result String Simulator
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonType : ComparatorView.ComparisonType
    , initialQuery : Inputs.Query
    , detailedStep : Maybe Int
    , impact : Definition
    , modal : Modal
    , activeImpactsTab : ImpactTabs.Tab
    }


type Modal
    = NoModal
    | ComparatorModal
    | AddMaterialModal (Maybe Inputs.MaterialInput) (Autocomplete Material)
    | SelectExampleModal (Autocomplete Inputs.Query)
    | SelectProductModal (Autocomplete Product.Id)


type Msg
    = AddMaterial Material
    | CopyToClipBoard String
    | DeleteBookmark Bookmark
    | NoOp
    | OnAutocompleteExample (Autocomplete.Msg Inputs.Query)
    | OnAutocompleteMaterial (Autocomplete.Msg Material)
    | OnAutocompleteProduct (Autocomplete.Msg Product.Id)
    | OnAutocompleteSelect
    | OnStepClick String
    | OpenComparator
    | RemoveMaterial Material.Id
    | Reset
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SetModal Modal
    | SwitchBookmarksTab BookmarkView.ActiveTab
    | SwitchComparisonType ComparatorView.ComparisonType
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactTabs.Tab
    | ToggleComparedSimulation Bookmark Bool
    | ToggleFading Bool
    | ToggleStep Label
    | ToggleStepDetails Int
    | UpdateAirTransportRatio (Maybe Split)
    | UpdateBookmarkName String
    | UpdateDurability Unit.Durability
    | UpdateDyeingMedium DyeingMedium
    | UpdateEnnoblingHeatSource (Maybe HeatSource)
    | UpdateFabricProcess Fabric
    | UpdateMakingComplexity MakingComplexity
    | UpdateMakingWaste (Maybe Split)
    | UpdateMakingDeadStock (Maybe Split)
    | UpdateMassInput String
    | UpdateMaterial Inputs.MaterialQuery Inputs.MaterialQuery
    | UpdateMaterialSpinning Material Spinning
    | UpdatePrinting (Maybe Printing)
    | UpdateStepCountry Label Country.Code
    | UpdateSurfaceMass (Maybe Unit.SurfaceMass)
    | UpdateYarnSize (Maybe Unit.YarnSize)


init :
    Definition.Trigram
    -> Maybe Inputs.Query
    -> Session
    -> ( Model, Session, Cmd Msg )
init trigram maybeUrlQuery ({ textileDb } as session) =
    let
        initialQuery =
            -- If we received a serialized query from the URL, use it
            -- Otherwise, fallback to use session query
            maybeUrlQuery
                |> Maybe.withDefault session.queries.textile

        simulator =
            initialQuery
                |> Simulator.compute textileDb
    in
    ( { simulator = simulator
      , bookmarkName = initialQuery |> findExistingBookmarkName session
      , bookmarkTab = BookmarkView.SaveTab
      , comparisonType = ComparatorView.Subscores
      , initialQuery = initialQuery
      , detailedStep = Nothing
      , impact = Definition.get trigram textileDb.impactDefinitions
      , modal = NoModal
      , activeImpactsTab = ImpactTabs.StepImpactsTab
      }
    , session
        |> Session.updateTextileQuery initialQuery
        |> (case simulator of
                Err error ->
                    Session.notifyError "Erreur de récupération des paramètres d'entrée" error

                Ok _ ->
                    identity
           )
    , case maybeUrlQuery of
        -- If we don't have an URL query, we may be coming from another app page, so we should
        -- reposition the viewport at the top.
        Nothing ->
            Ports.scrollTo { x = 0, y = 0 }

        -- If we do have an URL query, we either come from a bookmark, a saved simulation click or
        -- we're tweaking params for the current simulation: we shouldn't reposition the viewport.
        Just _ ->
            Cmd.none
    )


findExistingBookmarkName : Session -> Inputs.Query -> String
findExistingBookmarkName { textileDb, store } query =
    store.bookmarks
        |> Bookmark.findByTextileQuery query
        |> Maybe.map .name
        |> Maybe.withDefault
            (query
                |> Inputs.fromQuery textileDb
                |> Result.map Inputs.toString
                |> Result.withDefault ""
            )


updateQuery : Inputs.Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, commands ) =
    ( { model
        | simulator = query |> Simulator.compute session.textileDb
        , bookmarkName = query |> findExistingBookmarkName session
      }
    , session |> Session.updateTextileQuery query
    , commands
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ queries, navKey } as session) msg model =
    let
        query =
            queries.textile
    in
    case msg of
        AddMaterial material ->
            update session (SetModal NoModal) model
                |> updateQuery (Inputs.addMaterial material query)

        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        DeleteBookmark bookmark ->
            ( model
            , session |> Session.deleteBookmark bookmark
            , Cmd.none
            )

        NoOp ->
            ( model, session, Cmd.none )

        OpenComparator ->
            ( { model | modal = ComparatorModal }
            , session |> Session.checkComparedSimulations
            , Cmd.none
            )

        OnAutocompleteExample autocompleteMsg ->
            case model.modal of
                SelectExampleModal autocompleteState ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    ( { model | modal = SelectExampleModal newAutocompleteState }
                    , session
                    , Cmd.map OnAutocompleteExample autoCompleteCmd
                    )

                _ ->
                    ( model, session, Cmd.none )

        OnAutocompleteProduct autocompleteMsg ->
            case model.modal of
                SelectProductModal autocompleteState ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    ( { model | modal = SelectProductModal newAutocompleteState }
                    , session
                    , Cmd.map OnAutocompleteProduct autoCompleteCmd
                    )

                _ ->
                    ( model, session, Cmd.none )

        OnAutocompleteMaterial autocompleteMsg ->
            case model.modal of
                AddMaterialModal maybeOldMaterial autocompleteState ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    ( { model | modal = AddMaterialModal maybeOldMaterial newAutocompleteState }
                    , session
                    , Cmd.map OnAutocompleteMaterial autoCompleteCmd
                    )

                _ ->
                    ( model, session, Cmd.none )

        OnAutocompleteSelect ->
            case model.modal of
                AddMaterialModal maybeOldMaterial autocompleteState ->
                    updateMaterial query model session maybeOldMaterial autocompleteState

                SelectExampleModal autocompleteState ->
                    ( model, session, Cmd.none )
                        |> selectExample autocompleteState

                SelectProductModal autocompleteState ->
                    ( model, session, Cmd.none )
                        |> selectProduct autocompleteState

                _ ->
                    ( model, session, Cmd.none )

        OnStepClick stepId ->
            ( model
            , session
            , Ports.scrollIntoView stepId
            )

        RemoveMaterial materialId ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.removeMaterial materialId query)

        Reset ->
            ( model, session, Cmd.none )
                |> updateQuery model.initialQuery

        SaveBookmark ->
            ( model
            , session
            , Time.now
                |> Task.perform
                    (SaveBookmarkWithTime model.bookmarkName
                        (Bookmark.Textile query)
                    )
            )

        SaveBookmarkWithTime name foodQuery now ->
            ( model
            , session
                |> Session.saveBookmark
                    { name = String.trim name
                    , query = foodQuery
                    , created = now
                    }
            , Cmd.none
            )

        SetModal NoModal ->
            ( { model | modal = NoModal }
            , session
            , commandsForNoModal model.modal
            )

        SetModal ComparatorModal ->
            ( { model | modal = ComparatorModal }
            , session
            , Ports.addBodyClass "prevent-scrolling"
            )

        SetModal (AddMaterialModal maybeOldMaterial autocomplete) ->
            ( { model | modal = AddMaterialModal maybeOldMaterial autocomplete }
            , session
            , Cmd.batch
                [ Ports.addBodyClass "prevent-scrolling"
                , Dom.focus "element-search"
                    |> Task.attempt (always NoOp)
                ]
            )

        SetModal (SelectExampleModal autocomplete) ->
            ( { model | modal = SelectExampleModal autocomplete }
            , session
            , Cmd.batch
                [ Ports.addBodyClass "prevent-scrolling"
                , Dom.focus "element-search"
                    |> Task.attempt (always NoOp)
                ]
            )

        SetModal (SelectProductModal autocomplete) ->
            ( { model | modal = SelectProductModal autocomplete }
            , session
            , Cmd.batch
                [ Ports.addBodyClass "prevent-scrolling"
                , Dom.focus "element-search"
                    |> Task.attempt (always NoOp)
                ]
            )

        SwitchBookmarksTab bookmarkTab ->
            ( { model | bookmarkTab = bookmarkTab }
            , session
            , Cmd.none
            )

        SwitchComparisonType displayChoice ->
            ( { model | comparisonType = displayChoice }, session, Cmd.none )

        SwitchImpact (Ok trigram) ->
            ( model
            , session
            , Just query
                |> Route.TextileSimulator trigram
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

        SwitchImpact (Err error) ->
            ( model
            , session |> Session.notifyError "Erreur de sélection d'impact: " error
            , Cmd.none
            )

        SwitchImpactsTab impactsTab ->
            ( { model | activeImpactsTab = impactsTab }
            , session
            , Cmd.none
            )

        ToggleComparedSimulation bookmark checked ->
            ( model
            , session |> Session.toggleComparedSimulation bookmark checked
            , Cmd.none
            )

        ToggleFading fading ->
            ( model, session, Cmd.none )
                |> updateQuery { query | fading = Just fading }

        ToggleStep label ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.toggleStep label query)

        ToggleStepDetails index ->
            ( { model
                | detailedStep = toggleStepDetails index model.detailedStep
              }
            , session
            , Cmd.none
            )

        UpdateAirTransportRatio airTransportRatio ->
            ( model, session, Cmd.none )
                |> updateQuery { query | airTransportRatio = airTransportRatio }

        UpdateBookmarkName newName ->
            ( { model | bookmarkName = newName }, session, Cmd.none )

        UpdateDurability durability ->
            ( model, session, Cmd.none )
                |> updateQuery { query | durability = durability }

        UpdateDyeingMedium dyeingMedium ->
            ( model, session, Cmd.none )
                |> updateQuery { query | dyeingMedium = Just dyeingMedium }

        UpdateEnnoblingHeatSource maybeEnnoblingHeatSource ->
            ( model, session, Cmd.none )
                |> updateQuery { query | ennoblingHeatSource = maybeEnnoblingHeatSource }

        UpdateFabricProcess fabricProcess ->
            ( model, session, Cmd.none )
                |> updateQuery
                    { query
                        | fabricProcess = fabricProcess
                        , makingWaste =
                            model.simulator
                                |> Result.map
                                    (\simulator ->
                                        Fabric.getMakingWaste simulator.inputs.product.making.pcrWaste fabricProcess
                                    )
                                |> Result.toMaybe
                        , makingComplexity =
                            model.simulator
                                |> Result.map
                                    (\simulator ->
                                        Fabric.getMakingComplexity simulator.inputs.product.making.complexity fabricProcess
                                    )
                                |> Result.toMaybe
                    }

        UpdateMakingComplexity makingComplexity ->
            ( model, session, Cmd.none )
                |> updateQuery { query | makingComplexity = Just makingComplexity }

        UpdateMakingWaste makingWaste ->
            ( model, session, Cmd.none )
                |> updateQuery { query | makingWaste = makingWaste }

        UpdateMakingDeadStock makingDeadStock ->
            ( model, session, Cmd.none )
                |> updateQuery { query | makingDeadStock = makingDeadStock }

        UpdateMassInput massInput ->
            case massInput |> String.toFloat |> Maybe.map Mass.kilograms of
                Just mass ->
                    ( model, session, Cmd.none )
                        |> updateQuery { query | mass = mass }

                Nothing ->
                    ( model, session, Cmd.none )

        UpdateMaterial oldMaterial newMaterial ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateMaterial oldMaterial.id newMaterial query)

        UpdateMaterialSpinning material spinning ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateMaterialSpinning material spinning query)

        UpdatePrinting printing ->
            ( model, session, Cmd.none )
                |> updateQuery { query | printing = printing }

        UpdateStepCountry label code ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateStepCountry label code query)

        UpdateSurfaceMass surfaceMass ->
            ( model, session, Cmd.none )
                |> updateQuery { query | surfaceMass = surfaceMass }

        UpdateYarnSize yarnSize ->
            ( model, session, Cmd.none )
                |> updateQuery { query | yarnSize = yarnSize }


toggleStepDetails : Int -> Maybe Int -> Maybe Int
toggleStepDetails index detailedStep =
    detailedStep
        |> Maybe.map
            (\current ->
                if index == current then
                    Nothing

                else
                    Just index
            )
        |> Maybe.withDefault (Just index)


commandsForNoModal : Modal -> Cmd Msg
commandsForNoModal modal =
    case modal of
        AddMaterialModal maybeOldMaterial _ ->
            Cmd.batch
                [ Ports.removeBodyClass "prevent-scrolling"
                , Dom.focus
                    -- This whole "node to focus" management is happening as a fallback
                    -- if the modal was closed without choosing anything.
                    -- If anything has been chosen, then the focus will be done in `OnAutocompleteSelect`
                    -- and overload any focus being done here.
                    (maybeOldMaterial
                        |> Maybe.map (.material >> .id >> Material.idToString >> (++) "selector-")
                        |> Maybe.withDefault "add-new-element"
                    )
                    |> Task.attempt (always NoOp)
                ]

        SelectExampleModal _ ->
            Cmd.batch
                [ Ports.removeBodyClass "prevent-scrolling"
                , Dom.focus "selector-example"
                    |> Task.attempt (always NoOp)
                ]

        SelectProductModal _ ->
            Cmd.batch
                [ Ports.removeBodyClass "prevent-scrolling"
                , Dom.focus "selector-product"
                    |> Task.attempt (always NoOp)
                ]

        _ ->
            Ports.removeBodyClass "prevent-scrolling"


updateExistingMaterial : Inputs.Query -> Model -> Session -> Inputs.MaterialInput -> Material -> ( Model, Session, Cmd Msg )
updateExistingMaterial query model session oldMaterial newMaterial =
    let
        materialQuery : Inputs.MaterialQuery
        materialQuery =
            { id = newMaterial.id
            , share = oldMaterial.share
            , spinning = Nothing
            , country = Nothing
            }
    in
    model
        |> update session (SetModal NoModal)
        |> updateQuery (Inputs.updateMaterial oldMaterial.material.id materialQuery query)
        |> focusNode ("selector-" ++ Material.idToString newMaterial.id)


updateMaterial : Inputs.Query -> Model -> Session -> Maybe Inputs.MaterialInput -> Autocomplete Material -> ( Model, Session, Cmd Msg )
updateMaterial query model session maybeOldMaterial autocompleteState =
    let
        maybeSelectedValue =
            Autocomplete.selectedValue autocompleteState
    in
    Maybe.map2
        (updateExistingMaterial query model session)
        maybeOldMaterial
        maybeSelectedValue
        |> Maybe.withDefault
            -- Add a new Material
            (model
                |> update session (SetModal NoModal)
                |> selectMaterial autocompleteState
                |> focusNode
                    (maybeSelectedValue
                        |> Maybe.map (\selectedValue -> "selector-" ++ Material.idToString selectedValue.id)
                        |> Maybe.withDefault "add-new-element"
                    )
            )


focusNode : String -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
focusNode node ( model, session, commands ) =
    ( model
    , session
    , Cmd.batch
        [ commands
        , Dom.focus node
            |> Task.attempt (always NoOp)
        ]
    )


selectExample : Autocomplete Inputs.Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
selectExample autocompleteState ( model, session, _ ) =
    let
        example =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.withDefault Inputs.defaultQuery
    in
    update session (SetModal NoModal) { model | initialQuery = example }
        |> updateQuery example


selectProduct : Autocomplete Product.Id -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
selectProduct autocompleteState ( model, session, _ ) =
    let
        product =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.withDefault Inputs.defaultQuery.product

        currentQuery =
            session.queries.textile

        updatedQuery =
            { currentQuery | product = product }
    in
    update session (SetModal NoModal) model
        |> updateQuery updatedQuery


selectMaterial : Autocomplete Material -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
selectMaterial autocompleteState ( model, session, _ ) =
    let
        material =
            Autocomplete.selectedValue autocompleteState
                |> Maybe.map Just
                |> Maybe.withDefault (List.head (Autocomplete.choices autocompleteState))

        msg =
            material
                |> Maybe.map AddMaterial
                |> Maybe.withDefault NoOp
    in
    update session msg model


exampleProductField : Inputs.Query -> Html Msg
exampleProductField query =
    let
        autocompleteState =
            AutocompleteSelector.init Inputs.exampleProductToString Inputs.exampleProducts
    in
    div []
        [ label [ for "selector-example", class "form-label fw-bold text-truncate" ]
            [ text "Produit" ]
        , button
            [ class "form-select ElementSelector text-start"
            , id "selector-example"
            , onClick (SetModal (SelectExampleModal autocompleteState))
            ]
            [ text <| Inputs.exampleProductToString query ]
        ]


productField : TextileDb.Db -> Inputs.Query -> Html Msg
productField { products } query =
    let
        nameFromProductId =
            \productId ->
                Product.findById productId products
                    |> Result.map .name
                    |> Result.withDefault ""

        autocompleteState =
            AutocompleteSelector.init nameFromProductId (List.map .id products)
    in
    div []
        [ label [ for "selector-product", class "form-label fw-bold text-truncate" ]
            [ text "Utilisation et entretien" ]
        , button
            [ class "form-select ElementSelector text-start"
            , id "selector-product"
            , onClick (SetModal (SelectProductModal autocompleteState))
            ]
            [ query.product
                |> (\productId -> Product.findById productId products)
                |> Result.map .name
                |> Result.withDefault (Product.idToString query.product)
                |> text
            ]
        ]


massField : String -> Html Msg
massField massInput =
    div []
        [ label [ for "mass", class "form-label fw-bold text-truncate" ]
            [ text "Masse du produit fini" ]
        , div
            [ class "input-group" ]
            [ input
                [ type_ "number"
                , class "form-control"
                , id "mass"
                , Attr.min "0.05"
                , step "0.05"
                , value massInput
                , onInput UpdateMassInput
                ]
                []
            , span [ class "input-group-text" ] [ text "kg" ]
            ]
        ]


durabilityField : (Unit.Durability -> Msg) -> Unit.Durability -> Html Msg
durabilityField updateDurability durability =
    let
        fromFloat =
            Unit.durabilityToFloat >> String.fromFloat
    in
    div [ class "d-block" ]
        [ label [ for "durability-field", class "form-label fw-bold text-truncate" ]
            [ text "Durabilité" ]
        , div [ class "d-flex justify-content-between gap-3 mt-2" ]
            [ input
                [ type_ "range"
                , id "durability-field"
                , class "d-block form-range"
                , title "Un double-clic réinitialise la valeur"
                , onInput
                    (String.toFloat
                        >> Maybe.map Unit.durability
                        >> Maybe.withDefault Unit.standardDurability
                        >> updateDurability
                    )
                , onDoubleClick (updateDurability Unit.standardDurability)
                , Attr.min (fromFloat Unit.minDurability)
                , Attr.max (fromFloat Unit.maxDurability)

                -- WARNING: be careful when reordering attributes: for obscure reasons,
                -- the `value` one MUST be set AFTER the `step` one.
                , step "0.01"
                , value (fromFloat durability)
                ]
                []
            , span [ class "fs-7 text-muted font-monospace" ]
                [ durability
                    |> Unit.durabilityToFloat
                    |> Format.formatFloat 2
                    |> text
                ]
            ]
        ]


lifeCycleStepsView : TextileDb.Db -> Model -> Simulator -> Html Msg
lifeCycleStepsView db { detailedStep, impact } simulator =
    simulator.lifeCycle
        |> Array.indexedMap
            (\index current ->
                StepView.view
                    { current = current
                    , db = db
                    , detailedStep = detailedStep
                    , index = index
                    , inputs = simulator.inputs
                    , next = LifeCycle.getNextEnabledStep current.label simulator.lifeCycle
                    , selectedImpact = impact

                    -- Events
                    , addMaterialModal = AddMaterialModal
                    , deleteMaterial = .id >> RemoveMaterial
                    , setModal = SetModal
                    , toggleFading = ToggleFading
                    , toggleStep = ToggleStep
                    , toggleStepDetails = ToggleStepDetails
                    , updateCountry = UpdateStepCountry
                    , updateAirTransportRatio = UpdateAirTransportRatio
                    , updateDyeingMedium = UpdateDyeingMedium
                    , updateDurability = UpdateDurability
                    , updateEnnoblingHeatSource = UpdateEnnoblingHeatSource
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
        |> (List.reverse >> List.drop 1 >> List.reverse)
        |> div [ class "pt-1" ]


simulatorView : Session -> Model -> Simulator -> Html Msg
simulatorView ({ textileDb } as session) model ({ inputs, impacts } as simulator) =
    div [ class "row" ]
        [ div [ class "col-lg-8" ]
            [ h1 [ class "visually-hidden" ] [ text "Simulateur " ]
            , div [ class "row align-items-start flex-md-columns mb-3" ]
                [ div [ class "col-md-6" ] [ exampleProductField (Inputs.toQuery inputs) ]
                , div [ class "col-md-3" ] [ massField (String.fromFloat (Mass.inKilograms inputs.mass)) ]
                , div [ class "col-md-3" ] [ durabilityField UpdateDurability inputs.durability ]
                ]
            , div [ class "row align-items-start flex-md-columns mb-3" ]
                [ div [ class "col-md-6" ] [ productField textileDb (Inputs.toQuery inputs) ]
                ]
            , div []
                [ lifeCycleStepsView textileDb model simulator
                , div [ class "d-flex align-items-center justify-content-between mt-3 mb-5" ]
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
                        (small []
                            [ text "Hors modulation durabilité\u{00A0}: "
                            , impacts
                                |> Impact.multiplyBy (Unit.durabilityToFloat inputs.durability)
                                |> Format.formatImpact model.impact
                            ]
                        )
                , productMass = inputs.mass
                , totalImpacts = impacts

                -- Impacts tabs
                , impactTabsConfig =
                    SwitchImpactsTab
                        |> ImpactTabs.createConfig model.impact model.activeImpactsTab OnStepClick
                        |> ImpactTabs.forTextile session.textileDb.impactDefinitions simulator

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
                Ok simulator ->
                    [ simulatorView session model simulator
                    , case model.modal of
                        NoModal ->
                            text ""

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
                                        , switchComparisonType = SwitchComparisonType
                                        , toggle = ToggleComparedSimulation
                                        }
                                    ]
                                , footer = []
                                }

                        AddMaterialModal _ autocompleteState ->
                            AutocompleteSelector.view
                                { autocompleteState = autocompleteState
                                , closeModal = SetModal NoModal
                                , noOp = NoOp
                                , onAutocomplete = OnAutocompleteMaterial
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici le nom de la matière première pour la rechercher"
                                , title = "Sélectionnez une matière première"
                                , toLabel = .shortName
                                , toCategory = .origin >> Origin.toLabel
                                }

                        SelectExampleModal autocompleteState ->
                            AutocompleteSelector.view
                                { autocompleteState = autocompleteState
                                , closeModal = SetModal NoModal
                                , noOp = NoOp
                                , onAutocomplete = OnAutocompleteExample
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici le nom du produit pour le rechercher"
                                , title = "Sélectionnez un produit"
                                , toLabel = Inputs.exampleProductToString
                                , toCategory = Inputs.exampleProductToCategory
                                }

                        SelectProductModal autocompleteState ->
                            AutocompleteSelector.view
                                { autocompleteState = autocompleteState
                                , closeModal = SetModal NoModal
                                , noOp = NoOp
                                , onAutocomplete = OnAutocompleteProduct
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici l'utilisation du produit pour le rechercher"
                                , title = "Sélectionnez une utilisation de produit"
                                , toLabel =
                                    \productId ->
                                        Product.findById productId session.textileDb.products
                                            |> Result.map .name
                                            |> Result.withDefault (Product.idToString productId)
                                , toCategory = always ""
                                }
                    ]

                Err error ->
                    [ Alert.simple
                        { level = Alert.Danger
                        , close = Nothing
                        , title = Just "Erreur"
                        , content = [ text error ]
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

        ComparatorModal ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))

        AddMaterialModal _ _ ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))

        SelectExampleModal _ ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))

        SelectProductModal _ ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))
