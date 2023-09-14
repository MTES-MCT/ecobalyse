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
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Country as Country
import Data.Impact.Definition as Definition exposing (Definition)
import Data.Key as Key
import Data.Scope as Scope
import Data.Session as Session exposing (Session)
import Data.Split exposing (Split)
import Data.Textile.Db as TextileDb
import Data.Textile.DyeingMedium exposing (DyeingMedium)
import Data.Textile.HeatSource exposing (HeatSource)
import Data.Textile.Inputs as Inputs
import Data.Textile.Knitting as Knitting exposing (Knitting)
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.MakingComplexity exposing (MakingComplexity)
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Material.Origin as Origin
import Data.Textile.Material.Spinning exposing (Spinning)
import Data.Textile.Printing exposing (Printing)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Data.Textile.Step.Label exposing (Label)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass
import Page.Textile.Simulator.ViewMode as ViewMode exposing (ViewMode)
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
import Views.Textile.Material as MaterialView
import Views.Textile.Step as StepView


type alias Model =
    { simulator : Result String Simulator
    , bookmarkName : String
    , bookmarkTab : BookmarkView.ActiveTab
    , comparisonType : ComparatorView.ComparisonType
    , massInput : String
    , initialQuery : Inputs.Query
    , viewMode : ViewMode
    , impact : Definition
    , modal : Modal
    , activeImpactsTab : ImpactTabs.Tab
    }


type Modal
    = NoModal
    | ComparatorModal
    | AddMaterialModal (Maybe Inputs.MaterialInput) (Autocomplete Material)


type Msg
    = AddMaterial Material
    | CopyToClipBoard String
    | DeleteBookmark Bookmark
    | NoOp
    | OnAutocomplete (Autocomplete.Msg Material)
    | OnAutocompleteSelect
    | OpenComparator
    | RemoveMaterial Int
    | Reset
    | SaveBookmark
    | SaveBookmarkWithTime String Bookmark.Query Posix
    | SelectInputText String
    | SetModal Modal
    | SwitchBookmarksTab BookmarkView.ActiveTab
    | SwitchComparisonType ComparatorView.ComparisonType
    | SwitchImpact (Result String Definition.Trigram)
    | SwitchImpactsTab ImpactTabs.Tab
    | ToggleComparedSimulation Bookmark Bool
    | ToggleDisabledFading Bool
    | ToggleStep Label
    | ToggleStepViewMode Int
    | UpdateAirTransportRatio (Maybe Split)
    | UpdateBookmarkName String
    | UpdateDyeingMedium DyeingMedium
    | UpdateEnnoblingHeatSource (Maybe HeatSource)
    | UpdateKnittingProcess Knitting
    | UpdateMakingComplexity MakingComplexity
    | UpdateMakingWaste (Maybe Split)
    | UpdateMassInput String
    | UpdateMaterial Int Material.Id
    | UpdateMaterialShare Int Split
    | UpdateMaterialSpinning Material Spinning
    | UpdatePrinting (Maybe Printing)
    | UpdateProduct Product.Id
    | UpdateQuality (Maybe Unit.Quality)
    | UpdateReparability (Maybe Unit.Reparability)
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
      , massInput =
            initialQuery.mass
                |> Mass.inKilograms
                |> String.fromFloat
      , initialQuery = initialQuery
      , viewMode = ViewMode.Simple
      , impact = Definition.get trigram textileDb.impactDefinitions
      , modal = NoModal
      , activeImpactsTab =
            if trigram == Definition.Ecs then
                ImpactTabs.SubscoresTab

            else
                ImpactTabs.StepImpactsTab
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
updateQuery query ( model, session, msg ) =
    ( { model
        | simulator = query |> Simulator.compute session.textileDb
        , bookmarkName = query |> findExistingBookmarkName session
      }
    , session |> Session.updateTextileQuery query
    , msg
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ textileDb, queries, navKey } as session) msg model =
    let
        query =
            queries.textile
    in
    case msg of
        AddMaterial material ->
            ( model, session, Cmd.none )
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

        OnAutocomplete autocompleteMsg ->
            case model.modal of
                AddMaterialModal maybeOldMaterial autocompleteState ->
                    let
                        ( newAutocompleteState, autoCompleteCmd ) =
                            Autocomplete.update autocompleteMsg autocompleteState
                    in
                    ( { model | modal = AddMaterialModal maybeOldMaterial newAutocompleteState }
                    , session
                    , Cmd.map OnAutocomplete autoCompleteCmd
                    )

                _ ->
                    ( model, session, Cmd.none )

        OnAutocompleteSelect ->
            case model.modal of
                AddMaterialModal maybeOldMaterial autocompleteState ->
                    Maybe.map2
                        (\oldMaterial newMaterial ->
                            -- Update an existing Material
                            let
                                materialQuery : Inputs.MaterialQuery
                                materialQuery =
                                    { id = newMaterial.id
                                    , share = oldMaterial.share
                                    , spinning = Nothing
                                    }
                            in
                            model
                                |> update session (SetModal NoModal)
                                |> updateQuery (Inputs.updateMaterial oldMaterial.material.id materialQuery query)
                        )
                        maybeOldMaterial
                        (Autocomplete.selectedValue autocompleteState)
                        |> Maybe.withDefault
                            -- Add a new Material
                            (model
                                |> update session (SetModal NoModal)
                                |> selectMaterial autocompleteState
                            )

                _ ->
                    ( model, session, Cmd.none )

        RemoveMaterial index ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.removeMaterial index query)

        Reset ->
            ( model, session, Cmd.none )
                |> updateQuery Inputs.defaultQuery

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

        SelectInputText index ->
            ( model, session, Ports.selectInputText index )

        SetModal modal ->
            ( { model | modal = modal }
            , session
            , case modal of
                NoModal ->
                    Ports.removeBodyClass "prevent-scrolling"

                ComparatorModal ->
                    Ports.addBodyClass "prevent-scrolling"

                AddMaterialModal _ _ ->
                    Cmd.batch
                        [ Ports.addBodyClass "prevent-scrolling"
                        , Dom.focus "ingredient-search"
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

        ToggleDisabledFading disabledFading ->
            ( model, session, Cmd.none )
                |> updateQuery { query | disabledFading = Just disabledFading }

        ToggleStep label ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.toggleStep label query)

        ToggleStepViewMode index ->
            ( { model | viewMode = ViewMode.toggle index model.viewMode }
            , session
            , Cmd.none
            )

        UpdateAirTransportRatio airTransportRatio ->
            ( model, session, Cmd.none )
                |> updateQuery { query | airTransportRatio = airTransportRatio }

        UpdateBookmarkName newName ->
            ( { model | bookmarkName = newName }, session, Cmd.none )

        UpdateDyeingMedium dyeingMedium ->
            ( model, session, Cmd.none )
                |> updateQuery { query | dyeingMedium = Just dyeingMedium }

        UpdateEnnoblingHeatSource maybeEnnoblingHeatSource ->
            ( model, session, Cmd.none )
                |> updateQuery { query | ennoblingHeatSource = maybeEnnoblingHeatSource }

        UpdateKnittingProcess knittingProcess ->
            ( model, session, Cmd.none )
                |> updateQuery
                    { query
                        | knittingProcess = Just knittingProcess
                        , makingWaste =
                            model.simulator
                                |> Result.map
                                    (\simulator ->
                                        Knitting.getMakingWaste simulator.inputs.product.making.pcrWaste knittingProcess
                                    )
                                |> Result.toMaybe
                        , makingComplexity =
                            model.simulator
                                |> Result.map
                                    (\simulator ->
                                        Knitting.getMakingComplexity simulator.inputs.product.making.complexity knittingProcess
                                    )
                                |> Result.toMaybe
                    }

        UpdateMakingComplexity makingComplexity ->
            ( model, session, Cmd.none )
                |> updateQuery { query | makingComplexity = Just makingComplexity }

        UpdateMakingWaste makingWaste ->
            ( model, session, Cmd.none )
                |> updateQuery { query | makingWaste = makingWaste }

        UpdateMassInput massInput ->
            case massInput |> String.toFloat |> Maybe.map Mass.kilograms of
                Just mass ->
                    ( { model | massInput = massInput }, session, Cmd.none )
                        |> updateQuery { query | mass = mass }

                Nothing ->
                    ( { model | massInput = massInput }, session, Cmd.none )

        UpdateMaterial index materialId ->
            case Material.findById materialId textileDb.materials of
                Ok material ->
                    ( model, session, Cmd.none )
                        |> updateQuery (Inputs.updateMaterialAt index (\({ share } as m) -> { m | id = material.id, share = share, spinning = Nothing }) query)

                Err error ->
                    ( model, session |> Session.notifyError "Erreur de matière première" error, Cmd.none )

        UpdateMaterialShare index share ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateMaterialShare index share query)

        UpdateMaterialSpinning material spinning ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateMaterialSpinning material spinning query)

        UpdatePrinting printing ->
            ( model, session, Cmd.none )
                |> updateQuery { query | printing = printing }

        UpdateProduct productId ->
            case Product.findById productId textileDb.products of
                Ok product ->
                    ( { model | massInput = product.mass |> Mass.inKilograms |> String.fromFloat }, session, Cmd.none )
                        |> updateQuery (Inputs.updateProduct product query)

                Err error ->
                    ( model, session |> Session.notifyError "Erreur de produit" error, Cmd.none )

        UpdateQuality quality ->
            ( model, session, Cmd.none )
                |> updateQuery { query | quality = quality }

        UpdateReparability reparability ->
            ( model, session, Cmd.none )
                |> updateQuery { query | reparability = reparability }

        UpdateStepCountry label code ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateStepCountry label code query)

        UpdateSurfaceMass surfaceMass ->
            ( model, session, Cmd.none )
                |> updateQuery { query | surfaceMass = surfaceMass }

        UpdateYarnSize yarnSize ->
            ( model, session, Cmd.none )
                |> updateQuery { query | yarnSize = yarnSize }


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


massField : String -> Html Msg
massField massInput =
    div []
        [ label [ for "mass", class "form-label fw-bold" ]
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


productField : TextileDb.Db -> Product -> Html Msg
productField db product =
    div []
        [ label [ for "product", class "form-label fw-bold" ]
            [ text "Type de produit" ]
        , db.products
            |> List.map
                (\p ->
                    option
                        [ value (Product.idToString p.id)
                        , selected (product.id == p.id)
                        ]
                        [ text p.name ]
                )
            |> select
                [ id "product"
                , class "form-select"
                , onInput (Product.Id >> UpdateProduct)
                ]
        ]


lifeCycleStepsView : TextileDb.Db -> Model -> Simulator -> Html Msg
lifeCycleStepsView db { viewMode, impact } simulator =
    simulator.lifeCycle
        |> Array.indexedMap
            (\index current ->
                StepView.view
                    { db = db
                    , inputs = simulator.inputs
                    , viewMode = viewMode
                    , impact = impact
                    , daysOfWear = simulator.daysOfWear
                    , index = index
                    , current = current
                    , next = LifeCycle.getNextEnabledStep current.label simulator.lifeCycle
                    , toggleDisabledFading = ToggleDisabledFading
                    , toggleStep = ToggleStep
                    , toggleStepViewMode = ToggleStepViewMode
                    , updateCountry = UpdateStepCountry
                    , updateAirTransportRatio = UpdateAirTransportRatio
                    , updateDyeingMedium = UpdateDyeingMedium
                    , updateEnnoblingHeatSource = UpdateEnnoblingHeatSource
                    , updateMaterialSpinning = UpdateMaterialSpinning
                    , updateKnittingProcess = UpdateKnittingProcess
                    , updatePrinting = UpdatePrinting
                    , updateQuality = UpdateQuality
                    , updateReparability = UpdateReparability
                    , updateMakingComplexity = UpdateMakingComplexity
                    , updateMakingWaste = UpdateMakingWaste
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
        |> (\nodes ->
                -- Display the first input mass before the first step
                DownArrow.view []
                    [ span []
                        [ text "Masse\u{00A0}: "
                        , simulator.lifeCycle
                            |> Array.get 0
                            |> Maybe.map .inputMass
                            |> Maybe.map Format.kg
                            |> Maybe.withDefault (text "")
                        ]
                    ]
                    :: nodes
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
            , div [ class "row" ]
                [ div [ class "col-sm-6 mb-3" ]
                    [ productField textileDb inputs.product
                    ]
                , div [ class "col-sm-6 mb-3" ]
                    [ massField model.massInput
                    ]
                ]
            , MaterialView.formSet
                { materials = textileDb.materials
                , inputs = inputs.materials
                , remove = RemoveMaterial
                , update = UpdateMaterial
                , updateShare = UpdateMaterialShare
                , selectInputText = SelectInputText
                , selectMaterial = \maybeMaterial autocompleteState -> SetModal (AddMaterialModal maybeMaterial autocompleteState)
                }
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
                        [ text "Réinitialiser le simulateur" ]
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
                , productMass = inputs.mass
                , totalImpacts = impacts

                -- Impacts tabs
                , impactTabsConfig =
                    SwitchImpactsTab
                        |> ImpactTabs.createConfig model.impact model.activeImpactsTab
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
                                , onAutocomplete = OnAutocomplete
                                , onAutocompleteSelect = OnAutocompleteSelect
                                , placeholderText = "tapez ici le nom de la matière première pour la rechercher"
                                , title = "Sélectionnez une matière première"
                                , toCategory = .origin >> Origin.toString >> (++) "Matières "
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
