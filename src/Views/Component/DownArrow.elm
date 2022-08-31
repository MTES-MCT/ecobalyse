module Views.Component.DownArrow exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg
view =
    div [ class "text-center" ] [ downArrow ]


downArrow : Html msg
downArrow =
    img [ src "img/down-arrow-icon.png", alt "", attribute "aria-hidden" "true" ] []
