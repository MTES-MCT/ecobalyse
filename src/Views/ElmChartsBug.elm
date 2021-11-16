module Views.ElmChartsBug exposing (..)

import Chart as C
import Chart.Attributes as CA
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


chart : Html msg
chart =
    C.chart
        [ CA.height 500, CA.width 500 ]
        [ C.legendsAt .min .max [] []
        , [ { x = 1, y = 2, z = 3 }
          , { x = 4, y = 5, z = 6 }
          , { x = 7, y = 8, z = 9 }
          ]
            |> C.bars []
                [ C.stacked
                    [ C.bar .x []
                        |> C.named "X"
                    , C.bar .y []
                        |> C.named "Y"
                    , C.bar .z []
                        |> C.named "Z"
                    ]
                ]
        , C.barLabels [ CA.moveDown 16, CA.color "white" ]
        ]
