module Page.Textile.Simulator exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Array
import Browser.Events
import Browser.Navigation as Navigation
import Data.Bookmark as Bookmark exposing (Bookmark)
import Data.Country as Country
import Data.Impact as Impact
import Data.Key as Key
import Data.Session as Session exposing (Session)
import Data.Textile.Db exposing (Db)
import Data.Textile.DyeingMedium exposing (DyeingMedium)
import Data.Textile.HeatSource exposing (HeatSource)
import Data.Textile.Inputs as Inputs
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.Material as Material
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
import Time exposing (Posix)
import Views.Alert as Alert
import Views.Bookmark as BookmarkView
import Views.Comparator as ComparativeChartView
import Views.Component.DownArrow as DownArrow
import Views.Container as Container
import Views.Dataviz as Dataviz
import Views.Icon as Icon
import Views.Impact as ImpactView
import Views.Modal as ModalView
import Views.Textile.Material as MaterialView
import Views.Textile.Step as StepView
import Views.Textile.Summary as SummaryView


type alias Model =
    { currentTime : Posix
    , simulator : Result String Simulator
    , bookmarkTab : BookmarkView.ActiveTab
    , simulationName : String
    , massInput : String
    , initialQuery : Inputs.Query
    , viewMode : ViewMode
    , impact : Impact.Definition
    , funit : Unit.Functional
    , modal : Modal
    }


type Modal
    = NoModal
    | SavedSimulationsModal


type Msg
    = AddMaterial
    | CopyToClipBoard String
    | DeleteBookmark Bookmark
    | NewTime Posix
    | NoOp
    | OpenComparator
    | RemoveMaterial Int
    | Reset
    | SaveBookmark
    | SelectInputText String
    | SetModal Modal
    | SwitchFunctionalUnit Unit.Functional
    | SwitchImpact Impact.Trigram
    | SwitchLinksTab BookmarkView.ActiveTab
    | ToggleComparedSimulation String Bool
    | ToggleDisabledFading Bool
    | ToggleStep Label
    | ToggleStepViewMode Int
    | UpdateAirTransportRatio (Maybe Unit.Ratio)
    | UpdateBookmarkName String
    | UpdateDyeingMedium DyeingMedium
    | UpdateEnnoblingHeatSource (Maybe HeatSource)
    | UpdateMakingWaste (Maybe Unit.Ratio)
    | UpdateMassInput String
    | UpdateMaterial Int Material.Id
    | UpdateMaterialShare Int Unit.Ratio
    | UpdatePicking (Maybe Unit.PickPerMeter)
    | UpdatePrinting (Maybe Printing)
    | UpdateProduct Product.Id
    | UpdateQuality (Maybe Unit.Quality)
    | UpdateReparability (Maybe Unit.Reparability)
    | UpdateStepCountry Label Country.Code
    | UpdateSurfaceMass (Maybe Unit.SurfaceMass)


init :
    Impact.Trigram
    -> Unit.Functional
    -> ViewMode
    -> Maybe Inputs.Query
    -> Session
    -> ( Model, Session, Cmd Msg )
init trigram funit viewMode maybeUrlQuery ({ db, store } as session) =
    let
        initialQuery =
            -- If we received a serialized query from the URL, use it
            -- Otherwise, fallback to use session query
            maybeUrlQuery
                |> Maybe.withDefault session.queries.textile

        simulator =
            initialQuery
                |> Simulator.compute db
    in
    ( { currentTime = Time.millisToPosix 0
      , simulator = simulator
      , bookmarkTab = BookmarkView.SaveTab
      , simulationName =
            simulator
                |> findSimulationName store.bookmarks
      , massInput =
            initialQuery.mass
                |> Mass.inKilograms
                |> String.fromFloat
      , initialQuery = initialQuery
      , viewMode = viewMode
      , impact =
            db.impacts
                |> Impact.getDefinition trigram
                |> Result.withDefault Impact.invalid
      , funit = funit
      , modal = NoModal
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


findSimulationName : List Bookmark -> Result String Simulator -> String
findSimulationName bookmarks simulator =
    case simulator of
        Ok { inputs } ->
            bookmarks
                |> List.filter
                    (\bookmark ->
                        case bookmark.query of
                            Bookmark.Food _ ->
                                -- FIXME: handle comparison of food recipes
                                False

                            Bookmark.Textile query ->
                                Inputs.toQuery inputs == query
                    )
                |> List.head
                |> Maybe.map .name
                |> Maybe.withDefault (Inputs.toString inputs)

        Err _ ->
            ""


updateQuery : Inputs.Query -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateQuery query ( model, session, msg ) =
    let
        updatedSimulator =
            Simulator.compute session.db query
    in
    ( { model
        | simulator = updatedSimulator
        , simulationName =
            updatedSimulator
                |> findSimulationName session.store.bookmarks
      }
    , session |> Session.updateTextileQuery query
    , msg
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ db, queries, navKey } as session) msg model =
    let
        query =
            queries.textile
    in
    case msg of
        AddMaterial ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.addMaterial db query)

        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        DeleteBookmark bookmark ->
            ( model
            , session |> Session.deleteBookmark bookmark
            , Cmd.none
            )

        NewTime currentTime ->
            ( { model | currentTime = currentTime }, session, Cmd.none )

        NoOp ->
            ( model, session, Cmd.none )

        OpenComparator ->
            ( { model | modal = SavedSimulationsModal }
            , session |> Session.checkComparedSimulations
            , Cmd.none
            )

        RemoveMaterial index ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.removeMaterial index query)

        Reset ->
            ( model, session, Cmd.none )
                |> updateQuery Inputs.defaultQuery

        SaveBookmark ->
            ( model
            , session
                |> Session.saveBookmark
                    { name = String.trim model.simulationName
                    , query = Bookmark.Textile query
                    , created = model.currentTime
                    }
            , Cmd.none
            )

        SelectInputText index ->
            ( model, session, Ports.selectInputText index )

        SetModal modal ->
            ( { model | modal = modal }, session, Cmd.none )

        SwitchFunctionalUnit funit ->
            ( model
            , session
            , Just query
                |> Route.TextileSimulator model.impact.trigram funit model.viewMode
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

        SwitchImpact trigram ->
            ( model
            , session
            , Just query
                |> Route.TextileSimulator trigram model.funit model.viewMode
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

        SwitchLinksTab bookmarkTab ->
            ( { model | bookmarkTab = bookmarkTab }
            , session
            , Cmd.none
            )

        ToggleComparedSimulation name checked ->
            ( model
            , session |> Session.toggleComparedSimulation name checked
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
            ( { model | simulationName = newName }, session, Cmd.none )

        UpdateDyeingMedium dyeingMedium ->
            ( model, session, Cmd.none )
                |> updateQuery { query | dyeingMedium = Just dyeingMedium }

        UpdateEnnoblingHeatSource maybeEnnoblingHeatSource ->
            ( model, session, Cmd.none )
                |> updateQuery { query | ennoblingHeatSource = maybeEnnoblingHeatSource }

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
            case Material.findById materialId db.materials of
                Ok material ->
                    ( model, session, Cmd.none )
                        |> updateQuery (Inputs.updateMaterial index material query)

                Err error ->
                    ( model, session |> Session.notifyError "Erreur de matière première" error, Cmd.none )

        UpdateMaterialShare index share ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateMaterialShare index share query)

        UpdatePicking picking ->
            ( model, session, Cmd.none )
                |> updateQuery { query | picking = picking }

        UpdatePrinting printing ->
            ( model, session, Cmd.none )
                |> updateQuery { query | printing = printing }

        UpdateProduct productId ->
            case Product.findById productId db.products of
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


productField : Db -> Product -> Html Msg
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


lifeCycleStepsView : Db -> Model -> Simulator -> Html Msg
lifeCycleStepsView db { viewMode, funit, impact } simulator =
    simulator.lifeCycle
        |> Array.indexedMap
            (\index current ->
                StepView.view
                    { db = db
                    , inputs = simulator.inputs
                    , viewMode = viewMode
                    , impact = impact
                    , funit = funit
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
                    , updatePrinting = UpdatePrinting
                    , updateQuality = UpdateQuality
                    , updateReparability = UpdateReparability
                    , updateMakingWaste = UpdateMakingWaste
                    , updatePicking = UpdatePicking
                    , updateSurfaceMass = UpdateSurfaceMass
                    }
            )
        |> Array.toList
        |> List.intersperse DownArrow.standard
        |> div [ class "pt-1" ]


displayModeView : Impact.Trigram -> Unit.Functional -> ViewMode -> Inputs.Query -> Html Msg
displayModeView trigram funit viewMode query =
    let
        link mode icon label =
            a
                [ classList [ ( "nav-link", True ), ( "active", ViewMode.isActive viewMode mode ) ]
                , Just query
                    |> Route.TextileSimulator trigram funit mode
                    |> Route.href
                ]
                [ span [ class "me-1" ] [ icon ], text label ]
    in
    nav
        [ class "nav nav-pills nav-fill py-2 bg-white sticky-md-top justify-content-between"
        , class "justify-content-sm-end align-items-center gap-0 gap-sm-2"
        ]
        [ link ViewMode.Simple Icon.zoomout "Affichage simple"
        , link ViewMode.DetailedAll Icon.zoomin "Affichage détaillé"
        , link ViewMode.Dataviz Icon.stats "Visualisations"
        ]


simulatorView : Session -> Model -> Simulator -> Html Msg
simulatorView ({ db } as session) ({ impact, funit, viewMode } as model) ({ inputs } as simulator) =
    div [ class "row" ]
        [ div [ class "col-lg-7" ]
            [ h1 [] [ text "Simulateur " ]
            , ImpactView.viewDefinition model.impact
            , div [ class "row" ]
                [ div [ class "col-sm-6 mb-2" ]
                    [ productField db inputs.product
                    ]
                , div [ class "col-sm-6 mb-2" ]
                    [ massField model.massInput
                    ]
                ]
            , MaterialView.formSet
                { materials = db.materials
                , inputs = inputs.materials
                , add = AddMaterial
                , remove = RemoveMaterial
                , update = UpdateMaterial
                , updateShare = UpdateMaterialShare
                , selectInputText = SelectInputText
                }
            , session.queries.textile
                |> displayModeView impact.trigram funit viewMode
            , if viewMode == ViewMode.Dataviz then
                Dataviz.view db simulator

              else
                div []
                    [ lifeCycleStepsView db model simulator
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
        , div [ class "col-lg-5 bg-white" ]
            [ div [ class "d-flex flex-column gap-3 mb-3 sticky-md-top", style "top" "7px" ]
                [ ImpactView.selector
                    { impacts = session.db.impacts
                    , selectedImpact = model.impact.trigram
                    , switchImpact = SwitchImpact
                    , selectedFunctionalUnit = model.funit
                    , switchFunctionalUnit = SwitchFunctionalUnit
                    , scope = Impact.Textile
                    }
                , div [ class "Summary" ]
                    [ model.simulator
                        |> SummaryView.view
                            { session = session
                            , impact = model.impact
                            , funit = model.funit
                            , reusable = False
                            }
                    ]
                , BookmarkView.view
                    { session = session
                    , activeTab = model.bookmarkTab
                    , bookmarkName = model.simulationName
                    , impact = model.impact
                    , funit = model.funit
                    , scope = BookmarkView.Textile
                    , viewMode = model.viewMode
                    , copyToClipBoard = CopyToClipBoard
                    , compare = OpenComparator
                    , delete = DeleteBookmark
                    , save = SaveBookmark
                    , update = UpdateBookmarkName
                    , switchTab = SwitchLinksTab
                    }
                ]
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

                        SavedSimulationsModal ->
                            ModalView.view
                                { size = ModalView.ExtraLarge
                                , close = SetModal NoModal
                                , noOp = NoOp
                                , title =
                                    "Comparateur de simulations sauvegardées\u{00A0}: "
                                        ++ model.impact.label
                                        ++ ", "
                                        ++ Unit.functionalToString model.funit
                                , formAction = Nothing
                                , content =
                                    [ ComparativeChartView.comparator
                                        { session = session
                                        , impact = model.impact
                                        , funit = model.funit
                                        , daysOfWear = simulator.daysOfWear
                                        , toggle = ToggleComparedSimulation
                                        }
                                    ]
                                , footer = []
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
    Sub.batch
        [ Time.every 1000 NewTime
        , case modal of
            NoModal ->
                Sub.none

            SavedSimulationsModal ->
                Browser.Events.onKeyDown (Key.escape (SetModal NoModal))
        ]
