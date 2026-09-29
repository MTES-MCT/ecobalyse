module Views.Component.ItemRow exposing
    ( Cells
    , emptyItemRow
    , view
    )

import Html exposing (..)
import Html.Attributes exposing (..)


type alias Cells msg =
    { actions : Html msg
    , expander : Html msg
    , impacts : Html msg
    , label : Html msg
    , quantity : Html msg
    , totalMass : Html msg
    , unitMass : Html msg
    }


emptyItemRow : Cells msg
emptyItemRow =
    { actions = text ""
    , expander = text ""
    , impacts = text ""
    , label = text ""
    , quantity = text ""
    , totalMass = text ""
    , unitMass = text ""
    }


view : List (Attribute msg) -> Cells msg -> Html msg
view attributes cells =
    tr attributes
        [ td [ class "ps-2 py-2 align-middle" ]
            [ cells.expander ]
        , td [ class "py-2 text-end align-middle text-nowrap" ]
            [ cells.unitMass ]
        , td [ class "py-2 align-middle text-truncate w-100", style "max-width" "0" ]
            [ cells.label ]
        , td [ class "py-2 align-middle text-center" ]
            [ cells.quantity ]
        , td [ class "py-2 text-end align-middle text-nowrap" ]
            [ cells.totalMass ]
        , td [ class "py-2 text-end align-middle text-nowrap", style "min-width" "80px" ]
            [ cells.impacts ]
        , td [ class "py-2 pe-3 text-end align-middle text-nowrap" ]
            [ cells.actions ]
        ]
