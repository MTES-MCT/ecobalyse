module Page.Simulator exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Array
import Browser.Navigation as Navigation
import Data.Country as Country
import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Material as Material
import Data.Product as Product exposing (Product)
import Data.Session as Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
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
import Views.Icon as Icon
import Views.Impact as ImpactView
import Views.Material as MaterialView
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
    }


type LinksTab
    = ShareLink
    | SaveLink


type Msg
    = AddMaterial
    | CopyToClipBoard String
    | DeleteSavedSimulation Session.SavedSimulation
    | RemoveMaterial Int
    | Reset
    | SaveSimulation
    | SelectInputText String
    | SwitchFunctionalUnit Unit.Functional
    | SwitchImpact Impact.Trigram
    | SwitchLinksTab LinksTab
    | ToggleStepViewMode Int
    | UpdateAirTransportRatio (Maybe Unit.Ratio)
    | UpdateDyeingWeighting (Maybe Unit.Ratio)
    | UpdateMassInput String
    | UpdateMaterial Int Material.Id
    | UpdateMaterialRecycledRatio Int Unit.Ratio
    | UpdateMaterialShare Int Unit.Ratio
    | UpdateProduct Product.Id
    | UpdateQuality (Maybe Unit.Quality)
    | UpdateSimulationName String
    | UpdateStepCountry Int Country.Code


init :
    Impact.Trigram
    -> Unit.Functional
    -> ViewMode
    -> Maybe Inputs.Query
    -> Session
    -> ( Model, Session, Cmd Msg )
init trigram funit viewMode maybeQuery ({ db, query } as session) =
    let
        initialQuery =
            maybeQuery
                |> Maybe.withDefault Inputs.defaultQuery

        simulator =
            Simulator.compute db query
    in
    ( { simulator = simulator
      , linksTab = SaveLink
      , simulationName =
            simulator
                |> Result.map (.inputs >> Inputs.toString)
                |> Result.withDefault ""
      , massInput = query.mass |> Mass.inKilograms |> String.fromFloat
      , initialQuery = initialQuery
      , viewMode = viewMode
      , impact = db.impacts |> Impact.getDefinition trigram |> Result.withDefault Impact.default
      , funit = funit
      }
    , case simulator of
        Err error ->
            session |> Session.notifyError "Erreur de récupération des paramètres d'entrée" error

        Ok _ ->
            session
    , case maybeQuery of
        Nothing ->
            Ports.scrollTo { x = 0, y = 0 }

        Just _ ->
            Cmd.none
    )


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
                |> Result.map (.inputs >> Inputs.toString)
                |> Result.withDefault ""
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

        Reset ->
            ( model, session, Cmd.none )
                |> updateQuery Inputs.defaultQuery

        SaveSimulation ->
            ( model
            , session
                |> Session.saveSimulation
                    { name = model.simulationName
                    , query = query
                    }
            , Cmd.none
            )

        SelectInputText index ->
            ( model, session, Ports.selectInputText index )

        SwitchFunctionalUnit funit ->
            ( model
            , session
            , Route.Simulator model.impact.trigram funit model.viewMode (Just query)
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

        SwitchImpact trigram ->
            ( model
            , session
            , Route.Simulator trigram model.funit model.viewMode (Just query)
                |> Route.toString
                |> Navigation.pushUrl navKey
            )

        SwitchLinksTab linksTab ->
            ( { model | linksTab = linksTab }
            , session
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

        UpdateMaterialRecycledRatio index recycledRatio ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateMaterialRecycledRatio index recycledRatio query)

        UpdateMaterialShare index share ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateMaterialShare index share query)

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

        UpdateSimulationName newName ->
            ( { model | simulationName = newName }, session, Cmd.none )

        UpdateStepCountry index code ->
            ( model, session, Cmd.none )
                |> updateQuery (Inputs.updateStepCountry index code query)


massField : String -> Html Msg
massField massInput =
    div []
        [ label [ for "mass", class "form-label fw-bold" ] [ text "Masse du produit fini" ]
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
    img [ src "img/down-arrow-icon.png" ] []


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
                    }
            )
        |> Array.toList
        |> List.intersperse (div [ class "text-center" ] [ downArrow ])
        |> div [ class "pt-1" ]


linksView : Session -> Model -> Simulator -> Html Msg
linksView session ({ linksTab } as model) simulator =
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
                shareLinkView session model simulator

            SaveLink ->
                saveLinkView session model
        ]


shareLinkView : Session -> Model -> Simulator -> Html Msg
shareLinkView session { impact, funit } simulator =
    let
        shareableLink =
            simulator.inputs
                |> (Inputs.toQuery >> Just)
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


saveLinkView : Session -> Model -> Html Msg
saveLinkView ({ query, store } as session) ({ simulationName } as model) =
    div []
        [ div [ class "card-body" ]
            [ Html.form [ onSubmit SaveSimulation ]
                [ div [ class "input-group" ]
                    [ input
                        [ type_ "text"
                        , class "form-control"
                        , onInput UpdateSimulationName
                        , placeholder "Nom de la simulation"
                        , value simulationName
                        ]
                        []
                    , button
                        [ class "btn btn-primary"
                        , classList [ ( "disabled", List.member (Session.SavedSimulation simulationName query) store.savedSimulations ) ]
                        , disabled <| List.member (Session.SavedSimulation simulationName query) store.savedSimulations
                        , title "Sauvegarder la simulation dans le stockage local au navigateur"
                        , type_ "submit"
                        ]
                        [ Icon.plus
                        ]
                    ]
                ]
            , div [ class "form-text fs-7 pb-0" ]
                [ text "Nommez cette simulation pour vous aider à la retrouver dans la liste" ]
            ]
        , savedSimulationsView session model store.savedSimulations
        ]


savedSimulationsView : Session -> Model -> List Session.SavedSimulation -> Html Msg
savedSimulationsView session model savedSimulations =
    div []
        [ div [ class "card-header border-top" ] [ text "Simulations sauvegardées" ]
        , if List.length savedSimulations == 0 then
            div [ class "card-body form-text fs-7 pt-2" ]
                [ text "Pas de simulations sauvegardées sur cet ordinateur" ]

          else
            ul [ class "list-group list-group-flush overflow-scroll", style "max-height" "50vh" ]
                (List.map (savedSimulationView session model) savedSimulations)
        ]


savedSimulationView : Session -> Model -> Session.SavedSimulation -> Html Msg
savedSimulationView { clientUrl } { impact, funit } ({ name, query } as savedSimulation) =
    let
        simulationLink =
            Just query
                |> Route.Simulator impact.trigram funit ViewMode.Simple
                |> Route.toString
                |> (++) clientUrl
    in
    li [ class "list-group-item d-flex justify-content-between align-items-center" ]
        [ a
            [ href simulationLink
            , title name
            , class "text-truncate"
            ]
            [ text name
            ]
        , button
            [ type_ "button"
            , class "btn btn-sm btn-danger"
            , onClick <| DeleteSavedSimulation savedSimulation
            ]
            [ text "Supprimer" ]
        ]


displayModeView : Impact.Trigram -> Unit.Functional -> ViewMode -> Inputs.Query -> Html Msg
displayModeView trigram funit viewMode query =
    nav
        [ class "nav nav-pills nav-fill py-2 bg-white sticky-md-top justify-content-between"
        , class "justify-content-sm-end align-items-center gap-0 gap-sm-2"
        ]
        [ a
            [ classList [ ( "nav-link", True ), ( "active", not (ViewMode.isDetailed viewMode) ) ]
            , Just query
                |> Route.Simulator trigram funit ViewMode.Simple
                |> Route.href
            ]
            [ span [ class "me-1" ] [ Icon.zoomout ], text "Affichage simple" ]
        , a
            [ classList [ ( "nav-link", True ), ( "active", ViewMode.isDetailed viewMode ) ]
            , Just query
                |> Route.Simulator trigram funit ViewMode.DetailedAll
                |> Route.href
            ]
            [ span [ class "me-1" ] [ Icon.zoomin ], text "Affichage détaillé" ]
        ]


simulatorView : Session -> Model -> Simulator -> Html Msg
simulatorView ({ db, query } as session) ({ impact, funit, viewMode } as model) ({ inputs } as simulator) =
    div [ class "row" ]
        [ div [ class "col-lg-7" ]
            [ h1 [] [ text "Simulateur " ]
            , ImpactView.viewDefinition model.impact
            , div [ class "row" ]
                [ div [ class "col-6 col-md-7 mb-2" ]
                    [ productField db inputs.product
                    ]
                , div [ class "col-6 col-md-5 mb-2" ]
                    [ massField model.massInput
                    ]
                ]
            , MaterialView.formSet
                { materials = db.materials
                , inputs = inputs.materials
                , add = AddMaterial
                , remove = RemoveMaterial
                , update = UpdateMaterial
                , updateRecycledRatio = UpdateMaterialRecycledRatio
                , updateShare = UpdateMaterialShare
                , selectInputText = SelectInputText
                }
            , query
                |> displayModeView impact.trigram funit viewMode
            , lifeCycleStepsView db model simulator
            , div [ class "d-flex align-items-center justify-content-between mt-3 mb-5" ]
                [ a [ Route.href Route.Home ]
                    [ text "« Retour à l'accueil" ]
                , button
                    [ class "btn btn-secondary"
                    , onClick Reset
                    , disabled (query == model.initialQuery)
                    ]
                    [ text "Réinitialiser le simulateur" ]
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
                , linksView session model simulator
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Simulateur"
    , [ Container.centered [ class "Simulator pb-3" ]
            [ case model.simulator of
                Ok simulator ->
                    simulatorView session model simulator

                Err error ->
                    Alert.simple
                        { level = Alert.Danger
                        , close = Nothing
                        , title = Just "Erreur"
                        , content = [ text error ]
                        }
            ]
      ]
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
