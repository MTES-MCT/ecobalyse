module Views.Link exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


external : List (Attribute msg) -> List (Html msg) -> Html msg
external attrs =
    a (attrs ++ [ target "_blank", class "link-external", rel "noopener noreferrer" ])


internal : List (Attribute msg) -> List (Html msg) -> Html msg
internal attrs =
    a attrs
