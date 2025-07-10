module Page.Explore.Common exposing (impactBarGraph)

import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Format as Format


impactBarGraph : Bool -> Float -> Float -> Html msg
impactBarGraph detailed max score =
    let
        percent =
            score / max * 100
    in
    div
        [ class "d-flex justify-content-center align-items-center gap-2"
        , style "min-width" "calc(100% - 76px)"
        ]
        [ div
            [ classList [ ( "text-end", not detailed ) ]
            , style "min-width" "76px"
            ]
            [ Format.formatRichFloat 2 "Pts" score
            ]
        , div [ class "progress", style "min-width" "calc(100% - 76px)" ]
            [ div
                [ class "progress-bar bg-secondary"
                , style "width" <| String.fromFloat percent ++ "%"
                ]
                []
            ]
        ]
