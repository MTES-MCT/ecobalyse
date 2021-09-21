module Views.Container exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


centered : List (Attribute msg) -> List (Html msg) -> Html msg
centered attrs content =
    div ([ class "container" ] ++ attrs) content


fluid : List (Attribute msg) -> List (Html msg) -> Html msg
fluid attrs content =
    div ([ class "container-fluid" ] ++ attrs) content


full : List (Attribute msg) -> List (Html msg) -> Html msg
full attrs content =
    div attrs content
