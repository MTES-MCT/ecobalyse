module Page.Simulator exposing (Model, Msg, init, update, view)

import Array
import Data.Country exposing (Country)
import Data.Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle
import Data.Material as Material exposing (Material)
import Data.Material.Category as Category exposing (Category)
import Data.Product as Product exposing (Product)
import Data.Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Data.Step as Step
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as Encode
import Mass
import Ports
import Route exposing (Route(..))
import Views.Icon as Icon
import Views.Step as StepView
import Views.Summary as SummaryView


type alias Model =
    { simulator : Simulator
    , massInput : String
    , displayMode : DisplayMode
    }


type DisplayMode
    = DetailedMode
    | SimpleMode


type Msg
    = CopyToClipBoard String
    | Reset
    | SwitchMode DisplayMode
    | UpdateMassInput String
    | UpdateMaterial Material
    | UpdateMaterialCategory Category
    | UpdateStepCountry Step.Label Country
    | UpdateProduct Product


init : Maybe Inputs -> Session -> ( Model, Session, Cmd Msg )
init maybeInputs ({ store } as session) =
    let
        simulator =
            case maybeInputs of
                Just inputs ->
                    Simulator.fromInputs inputs

                Nothing ->
                    -- TODO: is using store.simulator necessary? why should it be serialized in a first step?
                    Simulator.compute store.simulator
    in
    ( { simulator = simulator
      , massInput = simulator.mass |> Mass.inKilograms |> String.fromFloat
      , displayMode = SimpleMode
      }
    , session
    , Cmd.none
    )


updateSimulator : Simulator -> ( Model, Session, Cmd Msg ) -> ( Model, Session, Cmd Msg )
updateSimulator simulator ( model, session, msg ) =
    ( { model | simulator = Simulator.compute simulator }, session, msg )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg ({ simulator } as model) =
    case msg of
        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        Reset ->
            ( model, session, Cmd.none )
                |> updateSimulator Simulator.default

        SwitchMode displayMode ->
            ( { model | displayMode = displayMode }, session, Cmd.none )

        UpdateMassInput massInput ->
            case massInput |> String.toFloat |> Maybe.map Mass.kilograms of
                Just mass ->
                    ( { model | massInput = massInput }, session, Cmd.none )
                        |> updateSimulator { simulator | mass = mass }

                Nothing ->
                    ( { model | massInput = massInput }, session, Cmd.none )

        UpdateMaterial material ->
            ( model, session, Cmd.none )
                |> updateSimulator { simulator | material = material }

        UpdateMaterialCategory category ->
            ( model, session, Cmd.none )
                |> updateSimulator
                    { simulator
                        | material =
                            Material.choices
                                |> List.filter (.category >> (==) category)
                                |> List.head
                                |> Maybe.withDefault Material.cotton
                    }

        UpdateStepCountry label country ->
            ( model, session, Cmd.none )
                |> updateSimulator { simulator | lifeCycle = simulator.lifeCycle |> LifeCycle.updateStepCountry label country }

        UpdateProduct product ->
            ( { model | massInput = product.mass |> Mass.inKilograms |> String.fromFloat }, session, Cmd.none )
                |> updateSimulator { simulator | product = product, mass = product.mass }


massField : String -> Html Msg
massField massInput =
    div [ class "mb-3" ]
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


materialCategoryField : Material -> Html Msg
materialCategoryField material =
    div [ class "mb-2" ]
        [ div [ class "form-label fw-bold" ] [ text "Matières premières" ]
        , [ ( Category.Natural, "leaf" )
          , ( Category.Synthetic, "lab" )
          , ( Category.Recycled, "recycle" )
          ]
            |> List.map
                (\( m, icon ) ->
                    button
                        [ type_ "button"
                        , classList
                            [ ( "btn", True )
                            , ( "btn-outline-primary", material.category /= m )
                            , ( "btn-primary", material.category == m )
                            , ( "text-truncate", True )
                            ]
                        , onClick (UpdateMaterialCategory m)
                        ]
                        [ span [ class "me-1" ] [ Icon.icon icon ]
                        , m |> Category.toString |> text
                        ]
                )
            |> div [ class "btn-group w-100" ]
        ]


materialField : Material -> Html Msg
materialField material =
    Material.choices
        |> List.filter (.category >> (==) material.category)
        |> List.map
            (\m ->
                option
                    [ value m.materialProcessUuid
                    , selected (material.materialProcessUuid == m.materialProcessUuid)
                    , title m.name
                    ]
                    [ text m.name ]
            )
        |> select
            [ id "material"
            , class "form-select"
            , onInput (Material.findByProcessUuid >> Maybe.withDefault Material.cotton >> UpdateMaterial)
            ]


productField : Product -> Html Msg
productField product =
    div [ class "mb-3" ]
        [ label [ for "product", class "form-label fw-bold" ] [ text "Type de produit" ]
        , Product.choices
            |> List.map (\p -> option [ value p.id, selected (product.id == p.id) ] [ text p.name ])
            |> select
                [ id "product"
                , class "form-select"
                , onInput (Product.findById >> Maybe.withDefault Product.tShirt >> UpdateProduct)
                ]
        ]


downArrow : Html Msg
downArrow =
    img [ src "img/down-arrow-icon.png" ] []


lifeCycleStepsView : Model -> Html Msg
lifeCycleStepsView { displayMode, simulator } =
    simulator.lifeCycle
        |> Array.indexedMap
            (\index current ->
                StepView.view
                    { detailed = displayMode == DetailedMode
                    , index = index
                    , product = simulator.product
                    , current = current
                    , next = Array.get (index + 1) simulator.lifeCycle
                    , updateCountry = UpdateStepCountry
                    }
            )
        |> Array.toList
        |> List.intersperse (div [ class "text-center" ] [ downArrow ])
        |> div [ class "pt-1" ]


shareLinkView : Session -> Model -> Html Msg
shareLinkView session model =
    let
        shareableLink =
            model.simulator
                |> Simulator.toInputs
                |> Just
                |> Route.Simulator
                |> Route.toString
                |> (++) session.clientUrl
    in
    div [ class "card shadow-sm mb-3" ]
        [ div [ class "card-header" ] [ text "Partager cette simulation" ]
        , div [ class "card-body" ]
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
                [ text "Copiez cette adresse pour partager votre simulation" ]
            ]
        ]


displayModeView : DisplayMode -> Html Msg
displayModeView displayMode =
    ul [ class "nav nav-pills nav-fill py-2 bg-light sticky-md-top" ]
        [ li [ class "nav-item" ]
            [ button
                [ classList [ ( "nav-link", True ), ( "active", displayMode == SimpleMode ) ]
                , onClick (SwitchMode SimpleMode)
                ]
                [ span [ class "me-2" ] [ Icon.zoomout ], text "Affichage simple" ]
            ]
        , li [ class "nav-item" ]
            [ button
                [ classList [ ( "nav-link", True ), ( "active", displayMode == DetailedMode ) ]
                , onClick (SwitchMode DetailedMode)
                ]
                [ span [ class "me-2" ] [ Icon.zoomin ], text "Affichage détaillé" ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view session ({ displayMode, simulator } as model) =
    ( "Simulateur"
    , [ h1 [ class "mb-3" ] [ text "Simulateur" ]
      , div [ class "row" ]
            [ div [ class "col-lg-7 col-xl-6" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-6" ]
                        [ productField simulator.product
                        ]
                    , div [ class "col-md-6" ]
                        [ massField model.massInput
                        ]
                    ]
                , materialCategoryField simulator.material
                , div [ class "mb-1" ] [ materialField simulator.material ]
                , displayModeView displayMode
                , lifeCycleStepsView model
                , div [ class "d-flex align-items-center justify-content-between my-3" ]
                    [ a [ Route.href Route.Home ] [ text "« Retour à l'accueil" ]
                    , button
                        [ class "btn btn-secondary"
                        , onClick Reset
                        , disabled (Simulator.default == simulator)
                        ]
                        [ text "Réinitialiser le simulateur" ]
                    ]
                ]
            , div [ class "col-lg-5 col-xl-6" ]
                [ div [ class "sticky-md-top" ]
                    [ SummaryView.view False simulator
                    , shareLinkView session model
                    , details []
                        [ summary [] [ text "Debug" ]
                        , pre [ class "mt-3" ]
                            [ Simulator.encode simulator |> Encode.encode 2 |> text
                            ]
                        ]
                    ]
                ]
            ]
      ]
    )
