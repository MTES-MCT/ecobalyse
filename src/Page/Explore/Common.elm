module Page.Explore.Common exposing
    ( boolText
    , impactBarGraph
    , scopesView
    )

import Data.Scope as Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Format as Format


boolText : Bool -> String
boolText bool =
    if bool then
        "oui"

    else
        "non"


scopesView : { a | scopes : List Scope } -> Html msg
scopesView =
    .scopes
        >> List.map
            (\scope ->
                span [ class "badge badge-success" ]
                    [ text <| Scope.toLabel scope ]
            )
        >> div [ class "d-flex gap-1" ]


impactBarGraph : Bool -> Float -> Float -> Html msg
impactBarGraph detailed max score =
    let
        percent =
            score / max * 100
    in
    div
        [ class "d-flex justify-content-center align-items-center gap-2"
        , style "min-width" "16vw"
        ]
        [ div
            [ classList [ ( "text-end", not detailed ) ]
            , style "min-width" "76px"
            ]
            [ Format.formatRichFloat 2 "Pts" score
            ]
        , div [ class "progress", style "min-width" "calc(100% - 86px)" ]
            [ div
                [ class "progress-bar bg-secondary"
                , style "width" <| String.fromFloat percent ++ "%"
                ]
                []
            ]
        ]
