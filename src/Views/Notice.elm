module Views.Notice exposing (info, warn)

import Html exposing (..)
import Html.Attributes exposing (..)


info : List (Html msg) -> Html msg
info =
    element [ class "page-notice-info" ]


warn : List (Html msg) -> Html msg
warn =
    element [ class "page-notice-warning" ]


element : List (Attribute msg) -> List (Html msg) -> Html msg
element attrs content =
    div
        (class "page-notice shadow-inner-top"
            :: attribute "role" "notice"
            :: attrs
        )
        [ div [ class "container px-4" ] content
        ]
