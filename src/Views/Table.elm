module Views.Table exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


responsiveDefault : List (Attribute msg) -> List (Html msg) -> Html msg
responsiveDefault attrs content =
    div [ class "table-responsive" ]
        [ table
            ([ class "table table-striped table-hover table-responsive" ]
                ++ attrs
            )
            content
        ]
