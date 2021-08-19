module Page.Simulator exposing (Model, Msg, init, update, view)

import Data.Material as Material exposing (Material)
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
    = UpdateMass Float
    | UpdateMaterial Material
    | UpdateProduct Product


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( session.store.simulator, session, Cmd.none )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
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

        UpdateProduct product ->
            ( { model | product = product }
            , session
            , Cmd.none
            )


massInput : Float -> Html Msg
massInput mass =
    div [ class "mb-3" ]
        [ label [ for "mass", class "form-label" ] [ text "Masse de matière première" ]
        , div
            [ class "input-group" ]
            [ input
                [ type_ "number"
                , class "form-control"
                , id "mass"
                , Attr.min "0.1"
                , step "0.1"
                , value <| String.fromFloat mass
                , onInput (String.toFloat >> Maybe.withDefault mass >> UpdateMass)
                ]
                []
            , span [ class "input-group-text" ] [ text "kg" ]
            ]
        , div [ class "form-text" ] [ text "Masse de matériau brut, en kilogrammes" ]
        ]


materialInput : Material -> Html Msg
materialInput material =
    div [ class "mb-3" ]
        [ div [ class "form-label" ] [ text "Matières premières" ]
        , Material.choices
            |> List.map
                (\m ->
                    button
                        [ type_ "button"
                        , classList
                            [ ( "btn", True )
                            , ( "btn-outline-primary", material.id /= m.id )
                            , ( "btn-primary", material.id == m.id )
                            , ( "text-truncate", True )
                            ]
                        , onClick (UpdateMaterial m)
                        ]
                        [ text m.name ]
                )
            |> div [ class "btn-group w-100" ]
        ]


productSelect : Product -> Html Msg
productSelect product =
    div [ class "mb-3" ]
        [ label [ for "product", class "form-label" ] [ text "Type de produit" ]
        , Product.choices
            |> List.map (\p -> option [ value p.id, selected (product.id == p.id) ] [ text p.name ])
            |> select
                [ id "product"
                , class "form-select"
                , onInput (Product.findById >> Maybe.withDefault Product.tShirt >> UpdateProduct)
                ]
        ]


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Simulateur"
    , [ h1 [] [ text "Simulateur" ]
      , div [ class "row" ]
            [ div [ class "col" ]
                [ productSelect model.product
                , materialInput model.material
                , massInput model.mass
                ]
            , div [ class "col" ]
                [ img [ class "w-100", src "https://via.placeholder.com/400x200?text=Graphic+goes+here" ] [] ]
            ]
      , pre []
            [ Simulator.encode model |> Encode.encode 2 |> text
            ]
      , p [] [ a [ Route.href Route.Home ] [ text "Retour à l'accueil" ] ]
      ]
    )
