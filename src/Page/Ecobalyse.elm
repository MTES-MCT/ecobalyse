module Page.Ecobalyse exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Chart.Attributes exposing (amount)
import Data.Session exposing (Session)
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import Views.Container as Container
import Views.RangeSlider as RangeSlider


type alias Amount =
    Unit.Ratio


type alias IngredientName =
    String


type alias Ingredient =
    ( IngredientName, Amount )


type alias Step =
    List Ingredient


type alias Product =
    { title : String
    , consumer : Step
    , supermarket : Step
    , distribution : Step
    , packaging : Step
    , plant : Step
    }


type alias Model =
    { product : Product
    }

type alias Config =
    { session : Session
    , impact : Impact.Definition
    , funit : Unit.Functional
    }


type Msg
    = NoOp Never
    | IngredientSliderChanged IngredientName (Maybe Amount)


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { product =
            { title = "Pizza, tuna, processed in FR | Chilled | Cardboard | Oven | at consumer/FR [Ciqual code: 26270]"
            , consumer =
                [ ( "Pizza, tuna, processed in FR | Chilled | Cardboard | at supermarket/FR", Unit.Ratio 1.0 )
                , ( "Electricity, low voltage {FR}| market for | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 1.0 )
                , ( "Transport, freight, lorry 16-32 metric ton, EURO5 {RER}| transport, freight, lorry 16-32 metric ton, EURO5 | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.0018000000000000002 )
                , ( "Paper (waste treatment) {GLO}| recycling of paper | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.065 )
                , ( "Waste paperboard {CH}| treatment of, inert material landfill | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.01575 )
                , ( "Waste paperboard {CH}| treatment of, municipal incineration with fly ash extraction | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.01925 )
                ]
            , supermarket =
                [ ( "Pizza, tuna, processed in FR | Chilled | Cardboard | at distribution/FR", Unit.Ratio 1.05263157894737 )
                , ( "Electricity, low voltage {FR}| market for | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.21923 )
                , ( "Tap water {Europe without Switzerland}| market for | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.2106 )
                , ( "Transport, freight, lorry with refrigeration machine, 7.5-16 ton, EURO5, R134a refrigerant, cooling {GLO}| transport, freight, lorry with refrigeration machine, 7.5-16 ton, EURO5, R134a refrigerant, cooling | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.165 )
                , ( "Biowaste {GLO}| treatment of biowaste, municipal incineration | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.0157894736842105 )
                , ( "Biowaste {RoW}| treatment of biowaste, industrial composting | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.00178947368421052 )
                , ( "Biowaste {RoW}| treatment of biowaste by anaerobic digestion | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.00873684210526315 )
                ]
            , distribution =
                [ ( "Pizza, tuna, processed in FR | Chilled | Cardboard | at packaging/FR", Unit.Ratio 1.05263157894737 )
                , ( "Electricity, low voltage {FR}| market for | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.00242947368421053 )
                , ( "Heat, central or small-scale, natural gas {Europe without Switzerland}| market for heat, central or small-scale, natural gas | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.010931578947368436 )
                , ( "Tap water {Europe without Switzerland}| market for | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.0003694736842105269 )
                , ( "Transport, freight, lorry with refrigeration machine, 7.5-16 ton, EURO5, R134a refrigerant, cooling {GLO}| transport, freight, lorry with refrigeration machine, 7.5-16 ton, EURO5, R134a refrigerant, cooling | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.5210526315789481 )
                ]
            , packaging =
                [ ( "Pizza, tuna, at plant", Unit.Ratio 1.05263157894737 )
                , ( "Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.105263157894737 )
                , ( "Transport, freight, lorry 16-32 metric ton, euro6 {RER}| market for transport, freight, lorry 16-32 metric ton, EURO6 | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.02421052631578951 )
                , ( "Transport, freight train {RER}| market group for transport, freight train | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.029473684210526357 )
                , ( "Transport, freight, inland waterways, barge {RER}| processing | Cut-off, S - Copied from Ecoinvent", Unit.Ratio 0.03789473684210532 )
                ]
            , plant =
                [ ( "Mozzarella cheese, from cow's milk, at plant", Unit.Ratio 0.26842105263157934 )
                , ( "Olive oil, at plant", Unit.Ratio 0.029789473684210567 )
                , ( "Tuna, fillet, raw, at processing", Unit.Ratio 0.1494736842105265 )
                , ( "Water, municipal", Unit.Ratio 0.09978947368421066 )
                , ( "Wheat flour, at industrial mill", Unit.Ratio 0.1684210526315792 )
                , ( "Cooking, industrial, 1kg of cooked product/ FR U", Unit.Ratio 1.05263157894737 )
                , ( "Tomato, for processing, peeled, at plant", Unit.Ratio 0.42526315789473745 )
                ]
            }
      }
    , session
    , Ports.scrollTo { x = 0, y = 0 }
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg ({product} as model) =
    case msg of
        IngredientSliderChanged name (Just newAmount) ->
            let
                updatedIngredients =
                    product.plant
                        |> List.map
                            (\(( ingredientName, _ ) as ingredient) ->
                                if ingredientName == name then
                                    ( ingredientName, newAmount )

                                else
                                    ingredient
                            )

                updatedProduct =
                    { product | plant = updatedIngredients }
            in
            ( { model | product = updatedProduct }, session, Cmd.none )

        _ ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Simulateur de recettes"
    , [ div [class "row"]
        [div [class "col-lg-7"]
        [Container.centered []
            [ h1 [ class "mb-3" ] [ text model.product.title ]
            , h2 [ class "h3" ] [ text "Ingrédients" ]
            , ul []
                (( model.product.plant
                     |> List.filter isIngredient
                 )
                    |> List.map viewIngredient
                )
            ]
        ]
        , div [class "col-lg-5"]
        [ text "graph"
        ]
        ]
      ]
    )

isIngredient: Ingredient -> Bool
isIngredient (name, _) =
    String.contains "/ FR U" name
    |> not


viewIngredient : Ingredient -> Html Msg
viewIngredient ( name, amount ) =
    li []
        [ text name
        , text " : "
        , RangeSlider.ratio
            { id = "slider-" ++ name
            , update = IngredientSliderChanged name
            , value = amount
            , toString = Unit.ratioToFloat >> String.fromFloat
            , disabled = False
            , min = 0
            , max = 100
            }
        ]

makeBars : Config -> List (Bar msg)
makeBars { impact, funit } =
    let
        grabImpact =
            Impact.grabImpactFloat funit simulator.daysOfWear impact.trigram

        maxScore =
            simulator.lifeCycle
                |> Array.map grabImpact
                |> Array.push (grabImpact simulator.transport)
                |> Array.toList
                |> List.maximum
                |> Maybe.withDefault 0

        stepBars =
            simulator.lifeCycle
                |> Array.toList
                |> List.filter (\{ label } -> label /= Step.Distribution)
                |> List.map
                    (\step ->
                        { label =
                            span []
                                [ case ( step.label, simulator.inputs.product.knitted ) of
                                    ( Step.Fabric, True ) ->
                                        text "Tricotage"

                                    ( Step.Fabric, False ) ->
                                        text "Tissage"

                                    ( Step.Dyeing, _ ) ->
                                        span [ class "fw-normal", title <| Step.dyeingWeightingToString step.dyeingWeighting ]
                                            [ strong [] [ text "Teinture" ]
                                            , text " ("
                                            , abbr [ class "Abbr" ]
                                                [ text <| Format.formatInt "%" (round (Unit.ratioToFloat step.dyeingWeighting * 100)) ]
                                            , text ")"
                                            ]

                                    _ ->
                                        text (Step.labelToString step.label)
                                ]
                        , score = grabImpact step
                        , width = clamp 0 100 (grabImpact step / maxScore * toFloat 100)
                        , percent = grabImpact step / grabImpact simulator * toFloat 100
                        }
                    )

        transportBar =
            { label = text "Transport total"
            , score = grabImpact simulator.transport
            , width = clamp 0 100 (grabImpact simulator.transport / maxScore * toFloat 100)
            , percent = grabImpact simulator.transport / grabImpact simulator * toFloat 100
            }
    in
    stepBars