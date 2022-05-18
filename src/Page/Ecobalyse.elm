module Page.Ecobalyse exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Chart.Attributes exposing (amount)
import Data.Ecobalyse.Db as Db exposing (Product, ProductName)
import Data.Ecobalyse.Process exposing (Amount, Process, ProcessName)
import Data.Session as Session exposing (Session)
import Data.Unit as Unit
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Ports
import RemoteData exposing (WebData)
import Request.Ecobalyse.Db as RequestDb
import Views.BarChart exposing (Bar)
import Views.Container as Container
import Views.Format as Format
import Views.PieChart as PieChart
import Views.RangeSlider as RangeSlider


type alias Model =
    { maybeProduct : Maybe Product }


type Msg
    = NoOp Never
    | IngredientSliderChanged ProductName (Maybe Amount)
    | DbLoaded (WebData Db.Db)


tunaPizza =
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


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { maybeProduct = Nothing }
    , session
    , Cmd.batch
        [ Ports.scrollTo { x = 0, y = 0 }
        , RequestDb.loadDb session DbLoaded
        ]
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg ({ maybeProduct } as model) =
    case ( msg, maybeProduct ) of
        ( IngredientSliderChanged name (Just newAmount), Just product ) ->
            let
                updatedProduct =
                    { product | plant = Db.updateAmount name newAmount product.plant }
            in
            ( { model | maybeProduct = Just updatedProduct }, session, Cmd.none )

        ( DbLoaded (RemoteData.Success db), _ ) ->
            ( model
            , { session | ecobalyseDb = db }
            , Cmd.none
            )

        ( DbLoaded (RemoteData.Failure httpError), _ ) ->
            ( model
            , session |> Session.notifyHttpError httpError
            , Cmd.none
            )

        _ ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Simulateur de recettes"
    , [ Container.centered []
            (case model.maybeProduct of
                Just product ->
                    [ h1 [ class "mb-3" ] [ text product.title ]
                    , h2 [ class "h3" ] [ text "Ingrédients" ]
                    , ul []
                        ((product.plant
                            |> Dict.filter isIngredient
                         )
                            |> Dict.map viewIngredient
                            |> Dict.values
                        )
                    ]

                _ ->
                    [ text "Loading" ]
            )
      ]
    )


isIngredient : ProcessName -> Process -> Bool
isIngredient name _ =
    String.contains "/ FR U" name
        |> not


viewIngredient : ProcessName -> Process -> Html Msg
viewIngredient name ({ amount, impacts } as ingredient) =
    li []
        [ text name
        , text " : "
        , div [ class "row" ]
            [ div [ class "col-lg-6" ]
                [ RangeSlider.ratio
                    { id = "slider-" ++ name
                    , update = IngredientSliderChanged name
                    , value = amount
                    , toString = Unit.ratioToFloat >> String.fromFloat
                    , disabled = False
                    , min = 0
                    , max = 100
                    }
                ]
            , div [ class "col-lg-6" ]
                [ ingredient
                    |> makeBar name 1
                    |> barView
                ]
            ]
        ]


makeBar : ProcessName -> Float -> Process -> Bar msg
makeBar name maxScore { amount, impacts } =
    let
        ratio =
            Unit.ratioToFloat amount

        percent =
            ratio / maxScore * toFloat 100
    in
    { label =
        span [] [ text name ]
    , score = ratio
    , width = clamp 0 100 percent
    , percent = percent
    }


barView : Bar msg -> Html msg
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
