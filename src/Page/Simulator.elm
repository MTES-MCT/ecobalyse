module Page.Simulator exposing (Model, Msg, init, update, view)

import Array exposing (Array)
import Data.Country as Country exposing (Country)
import Data.Material as Material exposing (Material)
import Data.Material.Category as Category exposing (Category)
import Data.Process as Process exposing (Process)
import Data.Product as Product exposing (Product)
import Data.Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Data.Transport as Transport exposing (Transport)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as Encode
import Route
import Views.Format as Format


type alias Model =
    Simulator


type Msg
    = Reset
    | UpdateMass Float
    | UpdateMaterial Material
    | UpdateMaterialCategory Category
    | UpdateProcessStep String Country
    | UpdateProduct Product


init : Session -> ( Model, Session, Cmd Msg )
init ({ store } as session) =
    let
        { simulator } =
            store
    in
    ( { simulator | transport = simulator.process |> Process.computeTransportSummary }
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        Reset ->
            ( Simulator.default, session, Cmd.none )

        UpdateMass mass ->
            ( { model | mass = mass }
            , session
            , Cmd.none
            )

        UpdateMaterial material ->
            ( { model | material = material }
            , session
            , Cmd.none
            )

        UpdateMaterialCategory category ->
            ( { model
                | material =
                    Material.choices
                        |> List.filter (.category >> (==) category)
                        |> List.head
                        |> Maybe.withDefault Material.cotton
              }
            , session
            , Cmd.none
            )

        UpdateProcessStep id country ->
            ( { model
                | transport = model.process |> Process.computeTransportSummary
                , process = model.process |> Process.updateCountryAt id country
              }
            , session
            , Cmd.none
            )

        UpdateProduct product ->
            ( { model | product = product, mass = product.defaultMass }
            , session
            , Cmd.none
            )


massInput : Float -> Html Msg
massInput mass =
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
                , onInput (String.toFloat >> Maybe.withDefault mass >> UpdateMass)
                ]
                []
            , span [ class "input-group-text" ] [ text "kg" ]
            ]
        ]


materialCategorySelect : Material -> Html Msg
materialCategorySelect material =
    div [ class "mb-2" ]
        [ div [ class "form-label fw-bold" ] [ text "Matières premières" ]
        , [ Category.Natural, Category.Synthetic, Category.Recycled ]
            |> List.map
                (\m ->
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
                        [ m |> Category.toString |> text ]
                )
            |> div [ class "btn-group w-100" ]
        ]


materialInput : Material -> Html Msg
materialInput material =
    div [ class "mb-3" ]
        [ Material.choices
            |> List.filter (.category >> (==) material.category)
            |> List.map (\m -> option [ value m.id, selected (material.id == m.id), title m.name ] [ text m.name ])
            |> select
                [ id "material"
                , class "form-select"
                , onInput (Material.findById >> Maybe.withDefault Material.cotton >> UpdateMaterial)
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


countrySelect : Process -> Html Msg
countrySelect process =
    div []
        [ Country.choices
            |> List.map (\c -> option [ selected (process.country == c) ] [ text (Country.toString c) ])
            |> select
                [ class "form-select"
                , disabled (not process.editable) -- ADEME enforce Asia as a default for these, prevent update
                , onInput (Country.fromString >> UpdateProcessStep process.id)
                ]
        , if not process.editable then
            div [ class "form-text" ]
                [ text "Champ non paramétrable"
                ]

          else
            text ""
        ]


transportInfoView : Transport -> Html Msg
transportInfoView transport =
    let
        row label getter =
            let
                ( km, ratio ) =
                    getter transport
            in
            tr []
                [ th [ class "text-start" ] [ text label ]
                , td [ class "text-end" ] [ km |> Format.formatInt "km" |> text ]
                , td [ class "text-end" ] [ ratio |> Format.formatInt "%" |> text ]
                , td [ class "text-end" ]
                    [ strong []
                        [ Transport.calcInfo ( km, ratio ) |> Format.formatInt "km" |> text
                        ]
                    ]
                ]
    in
    table
        [ class "table text-muted mb-0"
        ]
        [ row "Terrestre" .road
        , row "Aérien" .air
        , row "Maritime" .sea
        ]


downArrow : Html Msg
downArrow =
    img [ src "img/down-arrow-icon.png" ] []


processView : Int -> Maybe Process -> Process -> Html Msg
processView index maybePrevious current =
    div []
        [ case maybePrevious of
            Just previous ->
                div [ class "text-center" ]
                    [ downArrow
                    , div
                        [ class "card"
                        , style "max-width" "320px"
                        , style "margin" "0 auto"
                        , style "font-size" ".85em"
                        ]
                        [ div [ class "card-header fw-bold text-muted" ]
                            [ span [ class "me-1" ] [ text "Transport" ]
                            , if current.country == previous.country then
                                text <| "interne " ++ Country.toString previous.country

                              else
                                text
                                    (Country.toString previous.country
                                        ++ " - "
                                        ++ Country.toString current.country
                                    )
                            ]
                        , div [ class "card-body" ]
                            [ current.country
                                |> Transport.getTransportBetween previous.country
                                |> transportInfoView
                            ]
                        ]
                    , downArrow
                    ]

            Nothing ->
                text ""
        , div [ class "card" ]
            [ div [ class "card-header d-flex align-items-center" ]
                [ span [ class "badge rounded-pill bg-primary me-1" ]
                    [ text (String.fromInt (index + 1)) ]
                , text current.name
                ]
            , div [ class "card-body" ]
                [ countrySelect current
                ]
            ]
        ]


processesView : Array Process -> Html Msg
processesView processes =
    div []
        [ h2 [ class "mb-3" ] [ text "Étapes" ]
        , processes
            |> Array.indexedMap
                (\index process ->
                    processView index (Array.get (index - 1) processes) process
                )
            |> Array.toList
            |> div []
        ]


transportSummaryView : Model -> Html Msg
transportSummaryView model =
    let
        summary =
            Process.computeTransportSummary model.process
    in
    div [ class "card mb-3" ]
        [ div [ class "card-header" ]
            [ text "Synthèse transport" ]
        , div [ class "card-body" ]
            [ div []
                [ strong [] [ text "Terrestre: " ]
                , summary.road |> Format.formatInt "km" |> text
                ]
            , div []
                [ strong [] [ text "Maritime: " ]
                , summary.sea |> Format.formatInt "km" |> text
                ]
            , div []
                [ strong [] [ text "Aérien: " ]
                , summary.air |> Format.formatInt "km" |> text
                ]
            ]
        ]


summaryView : Model -> Html Msg
summaryView model =
    div [ class "mb-3" ]
        [ div [ class "card text-white bg-primary mb-3" ]
            [ div [ class "card-header" ]
                [ em [] [ text model.product.name ]
                , text " en "
                , em [] [ text model.material.name ]
                , text " de "
                , em [] [ text (String.fromFloat model.mass ++ "kg") ]
                ]
            , div [ class "card-body" ]
                [ p [ class "display-5 text-center" ]
                    [ text (String.fromFloat model.score ++ "kg eq, CO₂") ]
                ]
            ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Simulateur"
    , [ h1 [ class "mb-3" ] [ text "Simulateur" ]
      , div [ class "row" ]
            [ div [ class "col-lg-6" ]
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
                , processesView model.process
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
            , div [ class "col-lg-6" ]
                [ summaryView model
                , img [ class "w-100 mb-3", src "https://via.placeholder.com/400x200?text=Graphic+goes+here" ] []
                , transportSummaryView model
                , details []
                    [ summary [] [ text "Debug" ]
                    , pre [ class "mt-3" ]
                        [ Simulator.encode model |> Encode.encode 2 |> text
                        ]
                    ]
                ]
            ]
      ]
    )
