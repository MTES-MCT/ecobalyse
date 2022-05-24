module Page.Ecobalyse exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Ecobalyse.Db as Db
import Data.Ecobalyse.Process exposing (Amount, Process, ProcessName)
import Data.Ecobalyse.Product as Product exposing (Product, ProductName)
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Decimal
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import RemoteData exposing (WebData)
import Request.Ecobalyse.Db as RequestDb
import Views.Container as Container
import Views.Format as Format
import Views.PieChart as PieChart
import Views.RangeSlider as RangeSlider


type alias SelectedProduct =
    { product : Product
    , original : Product
    }


type alias Model =
    { selectedProduct : Maybe SelectedProduct }


type Msg
    = IngredientSliderChanged ProductName (Maybe Amount)
    | DbLoaded (WebData Db.Db)
    | Reset


tunaPizza : ProductName
tunaPizza =
    "Pizza, tuna, processed in FR | Chilled | Cardboard | Oven | at consumer/FR [Ciqual code: 26270]"


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { selectedProduct = Nothing }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , RequestDb.loadDb session DbLoaded
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg ({ selectedProduct } as model) =
    case ( msg, selectedProduct ) of
        ( IngredientSliderChanged name (Just newAmount), Just selected ) ->
            let
                { product } =
                    selected

                updatedProduct =
                    { product | plant = Product.updateAmount name newAmount product.plant }
            in
            ( { model | selectedProduct = Just { selected | product = updatedProduct } }, session, Cmd.none )

        ( DbLoaded (RemoteData.Success db), _ ) ->
            let
                productResult =
                    Product.findByName tunaPizza db.products
            in
            case productResult of
                Ok product ->
                    ( { model | selectedProduct = Just { product = product, original = product } }
                    , { session | ecobalyseDb = db }
                    , Cmd.none
                    )

                Err error ->
                    ( model
                    , session |> Session.notifyError "Erreur lors du chargement du produit" error
                    , Cmd.none
                    )

        ( DbLoaded (RemoteData.Failure httpError), _ ) ->
            ( model
            , session |> Session.notifyHttpError httpError
            , Cmd.none
            )

        ( Reset, Just selected ) ->
            ( { model | selectedProduct = Just { selected | product = selected.original } }
            , session
            , Cmd.none
            )

        _ ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Simulateur de recettes"
    , [ Container.centered []
            (case model.selectedProduct of
                Just { product, original } ->
                    let
                        -- We want the impact "per kg", but the original weight isn't 1kg,
                        -- so we need to keep it in store to adapt the final total per kg
                        originalTotalWeight =
                            Product.getTotalWeight original.plant

                        totalImpact =
                            Product.getTotalImpact product.plant

                        totalWeight =
                            Product.getTotalWeight product.plant

                        impactPerKg =
                            totalImpact * originalTotalWeight / totalWeight
                    in
                    [ h1 [ class "mb-3" ]
                        [ text "pizza au thon"
                        , text " : "
                        , impactPerKg
                            |> floatToRoundedString -2
                            |> text
                        , text " kg CO2 eq par kg de produit"
                        ]
                    , div [ class "row" ]
                        [ div [ class "col-lg-6" ]
                            [ h3 [] [ text "Quantité de l'ingrédient" ]
                            ]
                        , div [ class "col-lg-6 px-5" ]
                            [ h3 [] [ text "Pourcentage de l'impact total" ] ]
                        ]
                    , ul []
                        (product.plant
                            |> Dict.map (makeBar impactPerKg)
                            |> Dict.values
                            -- |> List.sortBy .impact
                            -- |> List.reverse
                            |> List.map viewIngredient
                        )
                    , div []
                        [ strong []
                            [ text "poids total avant cuisson : "
                            , totalWeight
                                |> floatToRoundedString -3
                                |> text
                            , text "kg"
                            ]
                        ]
                    , button
                        [ class "btn btn-primary"
                        , onClick Reset
                        ]
                        [ text "Réinitialiser" ]
                    ]

                _ ->
                    [ text "Loading" ]
            )
      ]
    )


viewIngredient : Bar -> Html Msg
viewIngredient bar =
    li []
        [ text bar.name
        , text " : "
        , div [ class "row" ]
            [ div [ class "col-lg-6" ]
                [ RangeSlider.ratio
                    { id = "slider-" ++ bar.name
                    , update = IngredientSliderChanged bar.name
                    , value = bar.amount
                    , toString =
                        Unit.ratioToFloat
                            >> floatToRoundedString -3
                            >> (\mass -> mass ++ "kg")
                    , disabled = Product.isUnit bar.name
                    , min = 0
                    , max = 100
                    }
                ]
            , div [ class "col-lg-6 px-5" ]
                [ barView bar ]
            ]
        ]


type alias Bar =
    { name : ProcessName
    , amount : Unit.Ratio
    , impact : Float
    , width : Float
    , percent : Float
    }


makeBar : Float -> ProcessName -> Process -> Bar
makeBar totalImpact name { amount, impacts } =
    let
        impact =
            impacts.cch * Unit.ratioToFloat amount

        percent =
            impact * toFloat 100 / totalImpact
    in
    { name = name
    , amount = amount
    , impact = impact
    , width = clamp 0 100 percent
    , percent = percent
    }


barView : Bar -> Html msg
barView bar =
    div [ class "fs-7 row" ]
        [ div [ class "col-lg-8 py-1" ]
            [ div
                [ class "bg-primary"
                , style "height" "1rem"
                , style "line-height" "1rem"
                , style "width" (String.fromFloat bar.width ++ "%")
                ]
                []
            ]
        , div [ class "col-lg-2 d-none d-sm-block text-end py-1 ps-2 text-truncate" ]
            [ Format.percent bar.percent ]
        , div [ class "col-lg-1 ps-2" ] [ PieChart.view bar.percent ]
        ]


floatToRoundedString : Int -> Float -> String
floatToRoundedString exponent float =
    float
        |> Decimal.fromFloat
        |> Decimal.roundTo exponent
        |> Decimal.toStringIn Decimal.Dec
