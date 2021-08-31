module Page.Simulator exposing (Model, Msg, init, update, view)

import Array exposing (Array)
import Data.Country as Country exposing (Country)
import Data.Material as Material exposing (Material)
import Data.Material.Category as Category exposing (Category)
import Data.Process as Process
import Data.Product as Product exposing (Product)
import Data.Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Data.Step as Step exposing (Step)
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
    | UpdateStepStep String Country
    | UpdateProduct Product


init : Session -> ( Model, Session, Cmd Msg )
init ({ store } as session) =
    let
        { simulator } =
            store

        _ =
            Debug.log "processes" Process.processes
    in
    ( { simulator | transport = simulator.steps |> Step.computeTransportSummary }
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

        UpdateStepStep id country ->
            ( { model
                | transport = model.steps |> Step.computeTransportSummary
                , steps = model.steps |> Step.updateCountryAt id country
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


countrySelect : Step -> Html Msg
countrySelect steps =
    div []
        [ Country.choices
            |> List.map (\c -> option [ selected (steps.country == c) ] [ text (Country.toString c) ])
            |> select
                [ class "form-select"
                , disabled (not steps.editable) -- ADEME enforce Asia as a default for these, prevent update
                , onInput (Country.fromString >> UpdateStepStep steps.id)
                ]
        , if not steps.editable then
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
        , style "font-size" ".85em"
        ]
        [ row "Terrestre" .road
        , row "Aérien" .air
        , row "Maritime" .sea
        ]


downArrow : Html Msg
downArrow =
    img [ src "img/down-arrow-icon.png" ] []


stepView : Int -> Maybe Step -> Step -> Html Msg
stepView index maybeNext current =
    div [ class "card-group" ]
        [ div [ class "card" ]
            [ div [ class "card-header d-flex align-items-center" ]
                [ span [ class "badge rounded-pill bg-primary me-1" ]
                    [ text (String.fromInt (index + 1)) ]
                , text current.name
                ]
            , div [ class "card-body" ]
                [ countrySelect current
                ]
            ]
        , div
            [ class "card text-center" ]
            (case maybeNext of
                Just next ->
                    [ div [ class "card-header text-muted" ]
                        [ span [ class "me-1" ] [ text "Transport" ]
                        , if current.country == next.country then
                            text <| "interne " ++ Country.toString next.country

                          else
                            text
                                (Country.toString next.country
                                    ++ " - "
                                    ++ Country.toString current.country
                                )
                        ]
                    , div [ class "card-body" ]
                        [ current.country
                            |> Transport.getTransportBetween next.country
                            |> transportInfoView
                        ]
                    ]

                Nothing ->
                    -- last step, add internal country circuit
                    -- TODO:
                    -- - move to generic view?
                    -- - compute added step to Step.computeTransport
                    [ div [ class "card-header text-muted" ]
                        [ span [ class "me-1" ] [ text "Transport" ]
                        , text <| "Distribution " ++ Country.toString current.country
                        ]
                    , div [ class "card-body" ]
                        [ current.country
                            |> Transport.getTransportBetween current.country
                            |> transportInfoView
                        ]
                    ]
            )
        ]


stepListView : Array Step -> Html Msg
stepListView steps =
    div []
        [ h2 [ class "mb-3" ] [ text "Étapes" ]
        , steps
            |> Array.indexedMap
                (\index step ->
                    stepView index (Array.get (index + 1) steps) step
                )
            |> Array.toList
            |> List.intersperse (div [ class "text-center" ] [ downArrow ])
            |> div []
        ]


transportSummaryView : Model -> Html Msg
transportSummaryView model =
    let
        summary =
            Step.computeTransportSummary model.steps
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
                , stepListView model.steps
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
