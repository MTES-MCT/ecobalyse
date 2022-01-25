module Views.Button exposing
    ( docsPill
    , pillClasses
    , smallPill
    )

import Html exposing (..)
import Html.Attributes exposing (..)


pillClasses : String
pillClasses =
    "d-inline-flex align-items-center btn btn-sm gap-1 rounded-pill"


smallPill : List (Attribute msg) -> List (Html msg) -> Html msg
smallPill attrs =
    button
        ([ class <| pillClasses ++ " text-secondary text-decoration-none btn-link p-0 ms-1" ] ++ attrs)


docsPill : List (Attribute msg) -> List (Html msg) -> Html msg
docsPill attrs =
    button
        ([ class <| pillClasses ++ " btn-primary fs-7 py-0" ] ++ attrs)
