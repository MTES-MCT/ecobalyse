module Views.Dataviz exposing
    ( stepsLegendData
    , view
    )

import Chart as C
import Chart.Attributes as CA
import Data.Impact as Impact
import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as Encode
import List.Extra as LE
import Svg as S
import Svg.Attributes as SA


view : Definitions -> Simulator -> Html msg
view definitions simulator =
    div [ class "pt-2" ]
        [ h2 [ class "h4 text-center pt-3" ]
            [ text "Composition du score PEF" ]
        , node "chart-pefpie"
            [ simulator.impacts
                |> Impact.getAggregatedScoreData definitions .pefData
                |> List.sortBy .value
                |> List.reverse
                |> Encode.list Impact.encodeAggregatedScoreChartEntry
                |> Encode.encode 0
                |> attribute "data"
            ]
            []
        , h2 [ class "h4 text-center pt-5 pb-1" ]
            [ text "Poids des étapes pour chaque impact" ]
        , simulator
            |> Simulator.lifeCycleImpacts definitions
            |> chart
        ]


chart : List ( String, List ( String, Float ) ) -> Html msg
chart data =
    let
        legends =
            [ C.legendsAt
                .min
                .max
                [ CA.alignMiddle
                , CA.htmlAttrs [ class "ComparatorChartLegends" ]
                , CA.moveDown 20
                ]
                [ CA.spacing 3
                , CA.fontSize 12
                , CA.htmlAttrs [ class "ComparatorChartLegend" ]
                ]
            ]

        bars =
            [ data
                |> List.map
                    (\( _, steps ) ->
                        let
                            getStepShare name =
                                steps
                                    |> List.filter (Tuple.first >> (==) name)
                                    |> List.head
                                    |> Maybe.map Tuple.second
                                    |> Maybe.withDefault 0
                        in
                        { knitted = False
                        , score = 0
                        , material = getStepShare "Matière"
                        , spinning = getStepShare "Filature"
                        , weavingKnitting = getStepShare "Tissage & Tricotage"
                        , ennobling = getStepShare "Ennoblissement"
                        , making = getStepShare "Confection"
                        , transport = getStepShare "Transports"
                        , use = getStepShare "Utilisation"
                        , endOfLife = getStepShare "Fin de vie"
                        }
                    )
                |> C.bars [ CA.margin 0.29 ]
                    [ stepsLegendData { knitted = False }
                        |> List.map
                            (\( getter, label ) ->
                                C.bar getter []
                                    |> C.named label
                            )
                        |> C.stacked
                    ]
            ]

        verticalLabels =
            fillLabels data

        xLabels =
            []

        yLabels =
            [ C.yLabels
                [ CA.withGrid
                , CA.fontSize 12
                , CA.color chartTextColor
                , CA.format (\v -> String.fromFloat v ++ "%")
                ]
            ]
    in
    [ xLabels
    , yLabels
    , bars
    , legends
    , verticalLabels
    ]
        |> List.concat
        |> C.chart
            [ CA.htmlAttrs [ class "ComparatorChart" ]
            , CA.width 800
            , CA.height 400
            , CA.margin { top = 20, bottom = 10, left = 38, right = -10 }
            ]


chartTextColor : String
chartTextColor =
    "#5d5b7e"


fillLabels : List ( String, List ( String, Float ) ) -> List (C.Element data msg)
fillLabels data =
    let
        baseWidth =
            100 / toFloat (clamp 1 100 (List.length data))

        leftPadding =
            baseWidth / 5

        createLabel ( ( label, _ ), xPosition ) =
            C.labelAt
                (CA.percent xPosition)
                (CA.percent 0)
                [ CA.rotate 90
                , CA.color chartTextColor
                , CA.attrs
                    [ SA.fontSize "14"
                    , SA.style "text-anchor: start"
                    ]
                ]
                [ S.text label ]
    in
    data
        |> List.indexedMap (\i entry -> ( entry, toFloat i * baseWidth + leftPadding ))
        |> List.map createLabel


stepsLegendData :
    { knitted : Bool }
    ->
        List
            ( { a
                | material : Float
                , spinning : Float
                , weavingKnitting : Float
                , ennobling : Float
                , making : Float
                , transport : Float
                , use : Float
                , endOfLife : Float
              }
              -> Float
            , String
            )
stepsLegendData { knitted } =
    -- There's an unfortunate bug in elm-charts where legend colors are inverted
    -- see https://github.com/terezka/elm-charts/issues/101
    -- FIXME: once an official fix is released, the expected implementation is:
    -- [ ( .material, "Matière" )
    -- [ ( .spinning, "Filature" )
    -- , ( .weavingKnitting
    --   , if knitted then
    --       "Tricotage"
    --     else
    --       "Tissage"
    --
    --   )
    -- , ( .ennobling, "Ennoblissement" )
    -- , ( .making, "Confection" )
    -- , ( .transport, "Transport" )
    -- , ( .use, "Utilisation" )
    -- ]
    [ "Matière"
    , "Filature"
    , if knitted then
        "Tricotage"

      else
        "Tissage"
    , "Ennoblissement"
    , "Confection"
    , "Transport"
    , "Utilisation"
    , "Fin de vie"
    ]
        |> LE.zip
            (List.reverse
                [ .material
                , .spinning
                , .weavingKnitting
                , .ennobling
                , .making
                , .transport
                , .use
                , .endOfLife
                ]
            )
