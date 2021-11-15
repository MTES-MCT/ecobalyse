module Views.Comparator.Chart exposing (..)

import Chart as C
import Chart.Attributes as CA
import Chart.Events as CE
import Chart.Item as CI
import Data.Co2 as Co2 exposing (Co2e)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import List.Extra as LE
import Svg as S
import Svg.Attributes as SA
import Svg.Events as SE


{-| Create vertical labels from percentages on the x-axis.
-}
fillLabels : List String -> List (C.Element data msg)
fillLabels labels =
    let
        baseWidth =
            100 / toFloat (clamp 1 100 (List.length labels))

        padding =
            7
    in
    labels
        |> List.indexedMap (\i _ -> toFloat i * baseWidth + padding)
        |> LE.zip labels
        |> List.map
            (\( label, x ) ->
                C.labelAt (CA.percent x)
                    (CA.percent 0)
                    [ CA.rotate 90, CA.attrs [ SA.style "text-anchor: start" ] ]
                    [ S.text label ]
            )


view : Co2e -> ( Co2e, Co2e, Co2e ) -> Html msg
view current ( good, middle, bad ) =
    let
        data =
            [ { label = "Circuit France", highlight = False, val = Co2.inKgCo2e good }
            , { label = "Circuit Turquie moyen", highlight = False, val = Co2.inKgCo2e middle }
            , { label = "Circuit Inde majorant", highlight = False, val = Co2.inKgCo2e bad }
            ]
                |> (::) { label = "Votre simulation", highlight = True, val = Co2.inKgCo2e current }
                |> List.sortBy .val

        verticalLabels =
            data |> List.map .label |> fillLabels

        barStyleVariation _ { highlight } =
            if highlight then
                [ CA.striped [] ]

            else
                []

        bars =
            [ C.yLabels [ CA.withGrid ]
            , data
                |> C.bars [ CA.margin 0.35 ]
                    [ C.bar .val [ CA.color "#075ea2" ]
                        |> C.variation barStyleVariation
                    ]
            ]

        xValues =
            []
    in
    (verticalLabels ++ xValues ++ bars)
        |> C.chart [ CA.height 220, CA.width 550 ]
