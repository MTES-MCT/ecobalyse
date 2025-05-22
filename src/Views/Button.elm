module Views.Button exposing
    ( copyButton
    , docsPill
    , docsPillLink
    , pillClasses
    , smallPill
    , smallPillLink
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Icon as Icon


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


copyButton : (String -> msg) -> String -> Html msg
copyButton copy textToCopy =
    button
        [ class "CopyButton d-inline-flex justify-content-start align-items-center gap-1"
        , class "btn btn-sm text-decoration-none text-muted text-start p-0 w-100"
        , title "Copier"
        , onClick <| copy textToCopy
        ]
        [ text textToCopy, Icon.copy ]


docsPillClasses : String
docsPillClasses =
    pillClasses ++ " btn-primary fs-7 py-0"


docsPill : List (Attribute msg) -> List (Html msg) -> Html msg
docsPill attrs =
    button (class docsPillClasses :: attrs)


docsPillLink : List (Attribute msg) -> List (Html msg) -> Html msg
docsPillLink attrs =
    a (class docsPillClasses :: attrs)
