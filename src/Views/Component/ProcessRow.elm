module Views.Component.ProcessRow exposing
    ( Cells
    , columnHeaders
    , emptyProcessRow
    , view
    )

import Html exposing (..)
import Html.Attributes exposing (..)


type alias Cells msg =
    { actions : Html msg
    , amount : Html msg
    , country : Html msg
    , impact : Html msg
    , label : Html msg
    , waste : Html msg
    }


columnHeaders : { amount : String, country : String, label : String, waste : String } -> Html msg
columnHeaders headers =
    view [ class "fs-8 fw-normal text-muted" ]
        { emptyProcessRow
            | amount = text headers.amount
            , country = text headers.country
            , impact = text "Impact"
            , label = text headers.label
            , waste = text headers.waste
        }


emptyProcessRow : Cells msg
emptyProcessRow =
    { actions = text ""
    , amount = text ""
    , country = text ""
    , impact = text ""
    , label = text ""
    , waste = text ""
    }


{-| Renders an item element process row in the production item editor modal table.
-}
view : List (Attribute msg) -> Cells msg -> Html msg
view attributes cells =
    tr attributes
        [ td
            [ class "text-end align-middle text-nowrap ps-3 py-2"
            , style "min-width" "130px"
            , style "max-width" "150px"
            ]
            [ cells.amount ]
        , td [ class "align-middle", style "min-width" "16rem" ]
            [ cells.label ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ cells.waste ]
        , td [ class "align-middle", style "min-width" "12rem" ]
            [ cells.country ]
        , td [ class "text-end align-middle text-nowrap" ]
            [ cells.impact ]
        , td [ class "pe-3 text-end align-middle text-nowrap" ]
            [ cells.actions ]
        ]
