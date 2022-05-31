module Page.Simulator exposing
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
import Data.Country as Country
import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Key as Key
import Data.Material as Material
import Data.Product as Product exposing (Product)
import Data.Session as Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Data.Step.Label exposing (Label)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Mass
import Page.Simulator.ViewMode as ViewMode exposing (ViewMode)
import Ports
import Route
import Views.Alert as Alert
import Views.Container as Container
import Views.Dataviz as Dataviz
import Views.Icon as Icon
import Views.Impact as ImpactView
import Views.Material as MaterialView
import Views.Modal as ModalView
import Views.SavedSimulation as SavedSimulationView
import Views.Step as StepView
import Views.Summary as SummaryView


type alias Model =
    { simulator : Result String Simulator
    , linksTab : LinksTab
    , simulationName : String
    , massInput : String
    , initialQuery : Inputs.Query
    , viewMode : ViewMode
    , impact : Impact.Definition
    , funit : Unit.Functional
    , modal : Modal
    }


type LinksTab
    = ShareLink
    | SaveLink


type Modal
    = NoModal
    | SavedSimulationsModal


type Msg
    = AddMaterial
    | CopyToClipBoard String
    | DeleteSavedSimulation Session.SavedSimulation
    | NoOp
    | OpenComparator
    | RemoveMaterial Int
    | Reset
    | SaveSimulation
    | SelectInputText String
    | SetModal Modal
    | SwitchFunctionalUnit Unit.Functional
    | SwitchImpact Impact.Trigram
    | SwitchLinksTab LinksTab
    | ToggleComparedSimulation String Bool
    | ToggleStepViewMode Int
    | UpdateAirTransportRatio (Maybe Unit.Ratio)
    | UpdateDyeingWeighting (Maybe Unit.Ratio)
    | UpdateMakingWaste (Maybe Unit.Ratio)
    | UpdateMassInput String
    | UpdateMaterial Int Material.Id
    | UpdateMaterialShare Int Unit.Ratio
    | UpdatePicking (Maybe Unit.PickPerMeter)
    | UpdateProduct Product.Id
    | UpdateQuality (Maybe Unit.Quality)
    | UpdateReparability (Maybe Unit.Reparability)
    | UpdateSimulationName String
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
                |> Maybe.withDefault session.query

        simulator =
            initialQuery
                |> Simulator.compute db
    in
    ( { simulator = simulator
      , linksTab = SaveLink
      , simulationName =
            simulator
                |> findSimulationName store.savedSimulations
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
    , case simulator of
        Err error ->
            { session | query = initialQuery }
                |> Session.notifyError "Erreur de récupération des paramètres d'entrée" error

        Ok _ ->
            { session | query = initialQuery }
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


findSimulationName : List Session.SavedSimulation -> Result String Simulator -> String
findSimulationName savedSimulations simulator =
    case simulator of
        Ok { inputs } ->
            savedSimulations
                |> List.filter (\{ query } -> Inputs.toQuery inputs == query)
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
                |> findSimulationName session.store.savedSimulations
      }
    , { session | query = query }
    , msg
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update ({ db, query, navKey } as session) msg model =
    case msg of
        AddMaterial ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.addMaterial db query)

        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        DeleteSavedSimulation savedSimulation ->
            ( model
            , session |> Session.deleteSimulation savedSimulation
            , Cmd.none
            )

        RemoveMaterial index ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.removeMaterial index query)

        NoOp ->
            ( model, session, Cmd.none )

        OpenComparator ->
            ( { model | modal = SavedSimulationsModal }
            , session |> Session.checkComparedSimulations
            , Cmd.none
            )

        Reset ->
            ( model, session, Cmd.none )
                |> updateQuery Inputs.defaultQuery

        SaveSimulation ->
            ( model
            , session
                |> Session.saveSimulation
                    { name = String.trim model.simulationName
                    , query = query
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
                |> Route.Simulator model.impact.trigram funit model.viewMode
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

        SwitchImpact trigram ->
            ( model
            , session
            , Just query
                |> Route.Simulator trigram model.funit model.viewMode
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

        SwitchLinksTab linksTab ->
            ( { model | linksTab = linksTab }
            , session
            , Cmd.none
            )

        ToggleComparedSimulation name checked ->
            ( model
            , session |> Session.toggleComparedSimulation name checked
            , Cmd.none
            )

        ToggleStepViewMode index ->
            ( { model | viewMode = model.viewMode |> ViewMode.toggle index }
            , session
            , Cmd.none
            )

        UpdateAirTransportRatio airTransportRatio ->
            ( model, session, Cmd.none )
                |> updateQuery { query | airTransportRatio = airTransportRatio }

        UpdateDyeingWeighting dyeingWeighting ->
            ( model, session, Cmd.none )
                |> updateQuery { query | dyeingWeighting = dyeingWeighting }

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

        UpdateSimulationName newName ->
            ( { model | simulationName = newName }, session, Cmd.none )

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


downArrow : Html Msg
downArrow =
    img [ src "img/down-arrow-icon.png", alt "", attribute "aria-hidden" "true" ] []


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
                    , next = Array.get (index + 1) simulator.lifeCycle
                    , toggleStepViewMode = ToggleStepViewMode
                    , updateCountry = UpdateStepCountry
                    , updateAirTransportRatio = UpdateAirTransportRatio
                    , updateDyeingWeighting = UpdateDyeingWeighting
                    , updateQuality = UpdateQuality
                    , updateReparability = UpdateReparability
                    , updateMakingWaste = UpdateMakingWaste
                    , updatePicking = UpdatePicking
                    , updateSurfaceMass = UpdateSurfaceMass
                    }
            )
        |> Array.toList
        |> List.intersperse (div [ class "text-center" ] [ downArrow ])
        |> div [ class "pt-1" ]


linksView : Session -> Model -> Html Msg
linksView session ({ linksTab } as model) =
    div [ class "card shadow-sm" ]
        [ div [ class "card-header" ]
            [ ul [ class "nav nav-tabs justify-content-end card-header-tabs" ]
                [ li [ class "nav-item" ]
                    [ button
                        [ class "btn btn-text nav-link rounded-0 rounded-top no-outline"
                        , classList [ ( "active", linksTab == SaveLink ) ]
                        , onClick <| SwitchLinksTab SaveLink
                        ]
                        [ text "Sauvegarder" ]
                    ]
                , li [ class "nav-item" ]
                    [ button
                        [ class "btn btn-text nav-link rounded-0 rounded-top no-outline"
                        , classList [ ( "active", linksTab == ShareLink ) ]
                        , onClick <| SwitchLinksTab ShareLink
                        ]
                        [ text "Partager" ]
                    ]
                ]
            ]
        , case linksTab of
            ShareLink ->
                shareLinkView session model

            SaveLink ->
                SavedSimulationView.manager
                    { session = session
                    , simulationName = model.simulationName
                    , impact = model.impact
                    , funit = model.funit
                    , viewMode = model.viewMode
                    , compare = OpenComparator
                    , delete = DeleteSavedSimulation
                    , save = SaveSimulation
                    , update = UpdateSimulationName
                    }
        ]


shareLinkView : Session -> Model -> Html Msg
shareLinkView session { impact, funit } =
    let
        shareableLink =
            Just session.query
                |> Route.Simulator impact.trigram funit ViewMode.Simple
                |> Route.toString
                |> (++) session.clientUrl
    in
    div [ class "card-body" ]
        [ div
            [ class "input-group" ]
            [ input
                [ type_ "url"
                , class "form-control"
                , value shareableLink
                ]
                []
            , button
                [ class "input-group-text"
                , title "Copier l'adresse"
                , onClick (CopyToClipBoard shareableLink)
                ]
                [ Icon.clipboard
                ]
            ]
        , div [ class "form-text fs-7" ]
            [ text "Copiez cette adresse pour partager ou sauvegarder votre simulation" ]
        ]


displayModeView : Impact.Trigram -> Unit.Functional -> ViewMode -> Inputs.Query -> Html Msg
displayModeView trigram funit viewMode query =
    let
        link mode icon label =
            a
                [ classList [ ( "nav-link", True ), ( "active", ViewMode.isActive viewMode mode ) ]
                , Just query
                    |> Route.Simulator trigram funit mode
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
            , session.query
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
                            , disabled (session.query == model.initialQuery)
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
                , linksView session model
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
                                    [ SavedSimulationView.comparator
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
    case modal of
        NoModal ->
            Sub.none

        SavedSimulationsModal ->
            Browser.Events.onKeyDown (Key.escape (SetModal NoModal))
