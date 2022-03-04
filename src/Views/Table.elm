module Views.Table exposing (responsiveDefault)

import Html exposing (..)
import Html.Attributes exposing (..)


responsiveDefault : List (Attribute msg) -> List (Html msg) -> Html msg
responsiveDefault attrs content =
    div [ class "DatasetTable table-responsive" ]
        [ table
            (class "table table-striped table-hover table-responsive mb-0"
                :: attrs
            )
            content
        ]
