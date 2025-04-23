module Views.Button exposing
    ( docsPill
    , docsPillLink
    , pillClasses
    , smallPill
    , smallPillLink
    )

import Html exposing (..)
import Html.Attributes exposing (..)


pillClasses : String
pillClasses =
    "d-inline-flex align-items-center btn btn-sm gap-1 rounded-pill"


smallPillClasses : String
smallPillClasses =
    pillClasses ++ " text-secondary text-decoration-none btn-link p-0 ms-1"


smallPill : List (Attribute msg) -> List (Html msg) -> Html msg
smallPill attrs =
    button (type_ "button" :: class smallPillClasses :: attrs)


smallPillLink : List (Attribute msg) -> List (Html msg) -> Html msg
smallPillLink attrs =
    a (class smallPillClasses :: attrs)


docsPillClasses : String
docsPillClasses =
    pillClasses ++ " btn-primary fs-7 py-0"


docsPill : List (Attribute msg) -> List (Html msg) -> Html msg
docsPill attrs =
    button (class docsPillClasses :: attrs)


docsPillLink : List (Attribute msg) -> List (Html msg) -> Html msg
docsPillLink attrs =
    a (class docsPillClasses :: attrs)
