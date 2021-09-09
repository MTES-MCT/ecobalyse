module Page.Simulator exposing (Model, Msg, init, update, view)

import Array
import Data.Country as Country exposing (Country)
import Data.Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle exposing (LifeCycle)
import Data.Material as Material exposing (Material)
import Data.Material.Category as Category exposing (Category)
import Data.Product as Product exposing (Product)
import Data.Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Data.Step as Step exposing (Step)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as Encode
import Ports
import Route exposing (Route(..))
import Views.Format as Format
import Views.Icon as Icon
import Views.Summary as SummaryView
import Views.Transport as TransportView


type alias Model =
    Simulator


type Msg
    = CopyToClipBoard String
    | Reset
    | UpdateMass Unit.Kg
    | UpdateMaterial Material
    | UpdateMaterialCategory Category
    | UpdateStepCountry Step.Label Country
    | UpdateProduct Product


init : Maybe Inputs -> Session -> ( Model, Session, Cmd Msg )
init maybeInputs ({ store } as session) =
    ( case maybeInputs of
        Just inputs ->
            Simulator.fromInputs inputs

        Nothing ->
            -- TODO: is using store.simulator necessary? why should it be serialized in a first step?
            Simulator.compute store.simulator
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        CopyToClipBoard shareableLink ->
            ( model, session, Ports.copyToClipboard shareableLink )

        Reset ->
            ( Simulator.compute Simulator.default, session, Cmd.none )

        UpdateMass mass ->
            ( Simulator.compute { model | mass = mass }
            , session
            , Cmd.none
            )

        UpdateMaterial material ->
            ( Simulator.compute { model | material = material }
            , session
            , Cmd.none
            )

        UpdateMaterialCategory category ->
            ( Simulator.compute
                { model
                    | material =
                        Material.choices
                            |> List.filter (.category >> (==) category)
                            |> List.head
                            |> Maybe.withDefault Material.cotton
                }
            , session
            , Cmd.none
            )

        UpdateStepCountry label country ->
            ( Simulator.compute { model | lifeCycle = model.lifeCycle |> LifeCycle.updateStepCountry label country }
            , session
            , Cmd.none
            )

        UpdateProduct product ->
            ( Simulator.compute { model | product = product, mass = product.mass }
            , session
            , Cmd.none
            )


massInput : Unit.Kg -> Html Msg
massInput (Unit.Kg mass) =
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
                , value <| String.fromFloat mass
                , onInput (String.toFloat >> Maybe.withDefault mass >> Unit.Kg >> UpdateMass)
                ]
                []
            , span [ class "input-group-text" ] [ text "kg" ]
            ]
        ]


materialCategorySelect : Material -> Html Msg
materialCategorySelect material =
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


materialInput : Material -> Html Msg
materialInput material =
    div [ class "mb-3" ]
        [ Material.choices
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
        ]


productSelect : Product -> Html Msg
productSelect product =
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


countrySelect : Step -> Html Msg
countrySelect step =
    div []
        [ Country.choices
            |> List.map (\c -> option [ selected (step.country == c) ] [ text (Step.countryLabel { step | country = c }) ])
            |> select
                [ class "form-select"
                , disabled (not step.editable) -- ADEME enforce Asia as a default for these, prevent update
                , onInput (Country.fromString >> UpdateStepCountry step.label)
                ]
        , case step.label of
            Step.MaterialAndSpinning ->
                div [ class "form-text fs-7" ]
                    [ Icon.info
                    , text " Ce champ sera bientôt paramétrable"
                    ]

            Step.Distribution ->
                div [ class "form-text fs-7" ]
                    [ Icon.exclamation
                    , text " Champ non paramétrable"
                    ]

            _ ->
                text ""
        ]


downArrow : Html Msg
downArrow =
    img [ src "img/down-arrow-icon.png" ] []


stepView : Int -> Step -> Html Msg
stepView index current =
    div [ class "card-group" ]
        [ div [ class "card" ]
            [ div [ class "card-header d-flex align-items-center" ]
                [ span [ class "badge rounded-pill bg-primary me-1" ]
                    [ text (String.fromInt (index + 1)) ]
                , text <| Step.labelToString current.label
                ]
            , div [ class "card-body" ]
                [ countrySelect current
                ]
            ]
        , div
            [ class "card text-center" ]
            [ div [ class "card-header text-muted" ]
                [ span [ class "fw-bold" ]
                    [ Format.kgCo2 (current.co2 + current.transport.co2)
                    ]
                ]

            -- <ul class="">
            --     <li class="list-group-item">An item</li>
            --     <li class="list-group-item">A second item</li>
            --     <li class="list-group-item">A third item</li>
            -- </ul>
            , ul [ class "list-group list-group-flush fs-7" ]
                [ li [ class "list-group-item text-muted d-flex justify-content-around" ]
                    [ span [] [ text "Masse\u{00A0}: ", Format.kg current.mass ]
                    , span [] [ text "Perte\u{00A0}: ", Format.kg current.waste ]
                    ]
                , li [ class "list-group-item text-muted" ]
                    [ TransportView.view True current.transport ]
                , li [ class "list-group-item text-muted" ]
                    [ strong [] [ text "Transport\u{00A0}:\u{00A0}" ]
                    , Format.kgCo2 current.transport.co2
                    ]
                ]
            ]
        ]


lifeCycleStepsView : LifeCycle -> Html Msg
lifeCycleStepsView lifeCycle =
    div []
        [ h2 [ class "mb-3" ] [ text "Étapes" ]
        , lifeCycle
            |> Array.indexedMap (\index -> stepView index)
            |> Array.toList
            |> List.intersperse (div [ class "text-center" ] [ downArrow ])
            |> div []
        ]


shareLinkView : Session -> Model -> Html Msg
shareLinkView session model =
    let
        shareableLink =
            model |> Simulator.toInputs |> Just |> Route.Simulator |> Route.toString |> (++) session.clientUrl
    in
    div [ class "card mb-3" ]
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


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Simulateur"
    , [ h1 [ class "mb-3" ] [ text "Simulateur" ]
      , div [ class "row" ]
            [ div [ class "col-lg-7 col-xl-6" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-6" ]
                        [ productSelect model.product
                        ]
                    , div [ class "col-md-6" ]
                        [ massInput model.mass
                        ]
                    ]
                , materialCategorySelect model.material
                , materialInput model.material
                , lifeCycleStepsView model.lifeCycle
                , div [ class "d-flex align-items-center justify-content-between my-3" ]
                    [ a [ Route.href Route.Home ] [ text "« Retour à l'accueil" ]
                    , button
                        [ class "btn btn-secondary"
                        , onClick Reset
                        , disabled (Simulator.default == model)
                        ]
                        [ text "Réinitialiser le simulateur" ]
                    ]
                ]
            , div [ class "col-lg-5 col-xl-6" ]
                [ div [ class "sticky-md-top" ]
                    [ SummaryView.view False model
                    , shareLinkView session model
                    , details []
                        [ summary [] [ text "Debug" ]
                        , pre [ class "mt-3" ]
                            [ Simulator.encode model |> Encode.encode 2 |> text
                            ]
                        ]
                    ]
                ]
            ]
      ]
    )
