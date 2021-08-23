module Page.Simulator exposing (Model, Msg, init, update, view)

import Data.Country as Country exposing (Country)
import Data.Material as Material exposing (Material)
import Data.Material.Category as Category exposing (Category)
import Data.Process exposing (Process)
import Data.Product as Product exposing (Product)
import Data.Session as Product exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as Encode
import Route


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
init session =
    ( session.store.simulator, session, Cmd.none )


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
                | process =
                    model.process
                        |> List.map
                            (\p ->
                                if p.id == id then
                                    { p | country = country }

                                else
                                    p
                            )
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
        [ label [ for "mass", class "form-label fw-bold" ] [ text "Masse de matière première" ]
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
    Country.choices
        |> List.map (\c -> option [ selected (process.country == c) ] [ text (Country.toString c) ])
        |> select
            [ class "form-select"
            , onInput (Country.fromString >> UpdateProcessStep process.id)
            ]


processView : Int -> Process -> Html Msg
processView index process =
    div [ class "card mb-3" ]
        [ div [ class "card-header d-flex align-items-center" ]
            [ span [ class "badge rounded-pill bg-primary me-1" ]
                [ text (String.fromInt (index + 1)) ]
            , text process.name
            ]
        , div [ class "card-body" ]
            [ countrySelect process
            ]
        ]


processListView : List Process -> Html Msg
processListView processList =
    div []
        [ h2 [ class "mb-3" ] [ text "Étapes" ]
        , processList
            |> List.indexedMap processView
            |> List.map (List.singleton >> div [ class "col" ])
            |> div [ class "row row-cols-1 row-cols-md-2 g-4" ]
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
                , processListView model.process
                , div [ class "d-flex align-items-center justify-content-between" ]
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
                [ img [ class "w-100", src "https://via.placeholder.com/400x200?text=Graphic+goes+here" ] []
                , pre [ class "mt-3" ]
                    [ Simulator.encode model |> Encode.encode 2 |> text
                    ]
                ]
            ]
      ]
    )
