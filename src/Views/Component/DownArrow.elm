module Views.Component.DownArrow exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : List (Html msg) -> List (Html msg) -> Html msg
view leftChildren rightChildren =
    div [ class "d-flex justify-content-between text-muted" ]
        [ span
            [ class "w-50 fs-7 py-4 text-end"
            , style "padding" ".5rem 1rem"
            ]
            leftChildren
        , div [ class "DownArrow" ] []
        , div
            [ class "w-50 fs-7 py-4"
            , style "padding" ".5rem 1rem"
            ]
            rightChildren
        ]
