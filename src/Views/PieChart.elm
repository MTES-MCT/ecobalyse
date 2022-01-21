module Views.PieChart exposing (view)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)


view : Float -> Html msg
view percentage =
    let
        circumference =
            31.4

        strokeDash =
            round (percentage * circumference / 100)

        strokeDashArrayValue =
            String.fromInt strokeDash ++ " " ++ String.fromFloat circumference
    in
    svg
        [ viewBox "0 0 20 20"
        , width "20"
        , height "20"
        ]
        [ circle
            [ cx "10"
            , cy "10"
            , r "10"
            , fill "#eee"
            ]
            []
        , circle
            [ cx "10"
            , cy "10"
            , r "5"
            , fill "transparent"
            , stroke "#075ea2"
            , strokeWidth "10"
            , transform "rotate(-90) translate(-20)"
            , strokeDasharray strokeDashArrayValue
            ]
            []
        ]
