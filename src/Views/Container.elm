module Views.Container exposing
    ( centered
    , full
    )

import Html exposing (..)
import Html.Attributes exposing (..)


centered : List (Attribute msg) -> List (Html msg) -> Html msg
centered attrs =
    div (class "container" :: attrs)


full : List (Attribute msg) -> List (Html msg) -> Html msg
full attrs =
    div attrs
