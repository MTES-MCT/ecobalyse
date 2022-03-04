module Views.Link exposing (external, internal, smallPillExternal)

import Html exposing (..)
import Html.Attributes exposing (..)


external : List (Attribute msg) -> List (Html msg) -> Html msg
external attrs =
    a (attrs ++ [ target "_blank", class "link-external", rel "noopener noreferrer" ])


internal : List (Attribute msg) -> List (Html msg) -> Html msg
internal attrs =
    a attrs


smallPillExternal : List (Attribute msg) -> List (Html msg) -> Html msg
smallPillExternal attrs =
    a
        (target "_blank"
            :: rel "noopener noreferrer"
            :: class "btn btn-sm text-secondary text-decoration-none btn-link p-0 ms-1"
            :: attrs
        )
