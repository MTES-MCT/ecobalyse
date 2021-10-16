module Views.Spinner exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg
view =
    div
        [ class "d-flex flex-column gap-3 justify-content-center align-items-center"
        , style "min-height" "25vh"
        ]
        [ div [ class "spinner-border text-primary", attribute "role" "status" ] []
        , p [ class "text-muted" ]
            [ text "Chargement…" ]
        ]
