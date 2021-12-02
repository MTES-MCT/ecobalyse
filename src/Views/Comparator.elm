module Views.Comparator exposing (..)

import Chart as C
import Chart.Attributes as CA
import Data.Country as Country
import Data.Db exposing (Db)
import Data.Inputs as Inputs exposing (Inputs)
import Data.LifeCycle as LifeCycle
import Data.Session exposing (Session)
import Data.Simulator as Simulator exposing (Simulator)
import Data.Step as Step
import Data.Unit as Unit
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as LE
import Page.Simulator.Impact as Impact exposing (Impact)
import Quantity
import Result.Extra as RE
import Svg as S
import Svg.Attributes as SA
import Views.Alert as Alert
import Views.Format as Format


type alias Config =
    { session : Session
    , impact : Impact
    , simulator : Simulator
    }


type alias Entry =
    { label : String
    , highlight : Bool
    , knitted : Bool
    , score : Float
    , materialAndSpinning : Float
    , weavingKnitting : Float
    , dyeing : Float
    , making : Float
    , transport : Float
    }


toRecycledFrance : Inputs.Query -> ( String, Inputs.Query )
toRecycledFrance query =
    ( "France 100% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 0
        , airTransportRatio = Just 0
        , recycledRatio = Just 1
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toNonRecycledFrance : Inputs.Query -> ( String, Inputs.Query )
toNonRecycledFrance query =
    ( "France 0% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 0
        , airTransportRatio = Just 0
        , recycledRatio = Just 0
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toPartiallyRecycledIndiaTurkey : Inputs.Query -> ( String, Inputs.Query )
toPartiallyRecycledIndiaTurkey query =
    ( "Inde-Turquie 20% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "IN"
            , Country.Code "TR"
            , Country.Code "TR"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 0.5
        , airTransportRatio = Just 0
        , recycledRatio = Just 0.2
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toNonRecycledIndiaTurkey : Inputs.Query -> ( String, Inputs.Query )
toNonRecycledIndiaTurkey query =
    ( "Inde-Turquie 0% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "IN"
            , Country.Code "TR"
            , Country.Code "TR"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 0.5
        , airTransportRatio = Just 0
        , recycledRatio = Just 0
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toRecycledIndia : Inputs.Query -> ( String, Inputs.Query )
toRecycledIndia query =
    ( "Inde 100% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 1
        , airTransportRatio = Just 1
        , recycledRatio = Just 1
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


toNonRecycledIndia : Inputs.Query -> ( String, Inputs.Query )
toNonRecycledIndia query =
    ( "Inde 0% recyclé"
    , { query
        | countries =
            [ Country.Code "CN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "IN"
            , Country.Code "FR"
            ]
        , dyeingWeighting = Just 1
        , airTransportRatio = Just 1
        , recycledRatio = Just 0
        , customCountryMixes = Inputs.defaultCustomCountryMixes
      }
    )


createEntry : Db -> Impact -> Bool -> ( String, Inputs.Query ) -> Result String Entry
createEntry db impact highlight ( label, query ) =
    let
        stepScore stepLabel lifeCycle =
            case impact of
                Impact.ClimateChange ->
                    lifeCycle
                        |> LifeCycle.getStepProp stepLabel .co2 Quantity.zero
                        |> Unit.inKgCo2e

                Impact.FreshwaterEutrophication ->
                    lifeCycle
                        |> LifeCycle.getStepProp stepLabel .fwe Quantity.zero
                        |> Unit.inKgPe
    in
    query
        |> Simulator.compute db
        |> Result.map
            (\({ lifeCycle, inputs, transport } as simulator) ->
                { label = label
                , highlight = highlight
                , knitted = inputs.product.knitted
                , score = Impact.toFloat impact simulator
                , materialAndSpinning = lifeCycle |> stepScore Step.MaterialAndSpinning
                , weavingKnitting = lifeCycle |> stepScore Step.WeavingKnitting
                , dyeing = lifeCycle |> stepScore Step.Ennoblement
                , making = lifeCycle |> stepScore Step.Making
                , transport = Impact.toFloat impact transport
                }
            )


getEntries : Db -> Impact -> Inputs -> Result String (List Entry)
getEntries db impact ({ material } as inputs) =
    let
        query =
            Inputs.toQuery inputs

        entries =
            if material.recycledProcess /= Nothing then
                [ ( "Votre simulation", query ) |> createEntry db impact True -- user simulation
                , query |> toRecycledFrance |> createEntry db impact False
                , query |> toNonRecycledFrance |> createEntry db impact False
                , query |> toPartiallyRecycledIndiaTurkey |> createEntry db impact False
                , query |> toRecycledIndia |> createEntry db impact False
                , query |> toNonRecycledIndia |> createEntry db impact False
                ]

            else
                [ ( "Votre simulation", query ) |> createEntry db impact True -- user simulation
                , query |> toNonRecycledFrance |> createEntry db impact False
                , query |> toNonRecycledIndiaTurkey |> createEntry db impact False
                , query |> toNonRecycledIndia |> createEntry db impact False
                ]
    in
    entries
        |> RE.combine
        |> Result.map (List.sortBy .score)


view : Config -> Html msg
view { session, impact, simulator } =
    case simulator.inputs |> getEntries session.db impact of
        Ok entries ->
            chart impact entries

        Err error ->
            Alert.simple
                { level = Alert.Danger
                , close = Nothing
                , title = "Erreur"
                , content = [ text error ]
                }


chartTextColor : String
chartTextColor =
    "#5d5b7e"


{-| Create vertical labels from percentages on the x-axis.
-}
fillLabels : List Entry -> List (C.Element data msg)
fillLabels entries =
    let
        ( baseWidth, leftPadding ) =
            ( 100 / toFloat (clamp 1 100 (List.length entries))
            , 3.8
            )

        createLabel ( { label, highlight }, xPosition ) =
            C.labelAt
                (CA.percent xPosition)
                (CA.percent 0)
                [ CA.rotate 90
                , CA.color chartTextColor
                , CA.attrs
                    [ SA.fontSize "14"
                    , SA.style "text-anchor: start"
                    , if highlight then
                        SA.fontWeight "bold"

                      else
                        SA.fontWeight "normal"
                    ]
                ]
                [ S.text label ]
    in
    entries
        |> List.indexedMap (\i entry -> ( entry, toFloat i * baseWidth + leftPadding ))
        |> List.map createLabel


chart : Impact -> List Entry -> Html msg
chart impact entries =
    let
        knitted =
            entries |> List.head |> Maybe.map .knitted |> Maybe.withDefault False

        barStyleVariation _ { highlight } =
            if not highlight then
                [ CA.opacity 0.35 ]

            else
                []

        barsData =
            -- There's an unfortunate bug in elm-charts where legend colors are inverted
            -- see https://github.com/terezka/elm-charts/issues/101
            -- FIXME: once an official fix is released, the expected implementation is:
            -- [ ( "Matière", .materialAndSpinning )
            -- , ( if knitted then
            --       "Tricotage"
            --     else
            --       "Tissage"
            --   , .weavingKnitting
            --   )
            -- , ( "Teinture", .dyeing )
            -- , ( "Confection", .making )
            -- , ( "Transport", .transport )
            -- ]
            [ "Matière"
            , if knitted then
                "Tricotage"

              else
                "Tissage"
            , "Teinture"
            , "Confection"
            , "Transport"
            ]
                |> LE.zip
                    (List.reverse
                        [ .materialAndSpinning
                        , .weavingKnitting
                        , .dyeing
                        , .making
                        , .transport
                        ]
                    )

        bars =
            [ entries
                |> C.bars [ CA.margin 0.28 ]
                    [ barsData
                        |> List.map
                            (\( getter, label ) ->
                                C.bar getter []
                                    |> C.named label
                                    |> C.variation barStyleVariation
                            )
                        |> C.stacked
                    ]
            ]

        unit =
            case impact of
                Impact.ClimateChange ->
                    "kgCO₂e"

                Impact.FreshwaterEutrophication ->
                    "kPe"

        xLabels =
            [ C.binLabels (\{ score } -> Format.formatFloat 2 score ++ "\u{202F}" ++ unit)
                [ CA.moveDown 23, CA.color chartTextColor, CA.attrs [ SA.fontSize "12" ] ]
            ]

        yLabels =
            [ C.yLabels [ CA.withGrid, CA.fontSize 13, CA.color chartTextColor ] ]

        legends =
            [ C.legendsAt
                (\{ max } -> max / 2)
                (\{ max } -> max * 1.15)
                [ CA.alignMiddle ]
                [ CA.spacing 2, CA.fontSize 11 ]
            ]

        verticalLabels =
            fillLabels entries
    in
    [ xLabels, yLabels, bars, legends, verticalLabels ]
        |> List.concat
        |> C.chart
            [ CA.height 250
            , CA.width 550
            , CA.margin { top = 22, bottom = 10, left = 22, right = -10 }
            ]
