module Views.Button exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


smallPill : List (Attribute msg) -> List (Html msg) -> Html msg
smallPill attrs =
    button ([ class "btn btn-sm text-secondary text-decoration-none btn-link p-0 ms-1" ] ++ attrs)
