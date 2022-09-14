module Views.Component.DownArrow exposing (large, standard)

import Html exposing (..)
import Html.Attributes exposing (..)


img : String -> Html msg
img path =
    div [ class "text-center" ]
        [ Html.img
            [ src path
            , alt ""
            , attribute "aria-hidden" "true"
            ]
            []
        ]


standard : Html msg
standard =
    img "img/down-arrow-icon.png"


large : Html msg
large =
    img "img/down-arrow-lg-icon.png"
