module Views.Spinner exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Maybe ( Int, Int ) -> Html msg
view progress =
    div
        [ class "d-flex flex-column gap-3 justify-content-center align-items-center"
        , style "min-height" "25vh"
        ]
        [ div [ class "spinner-border text-primary", attribute "role" "status" ] []
        , p [ class "text-muted" ]
            [ case progress of
                Just ( loaded, total ) ->
                    text <| "Chargement\u{00A0}: " ++ String.fromInt loaded ++ "/" ++ String.fromInt total

                Nothing ->
                    text "Chargement…"
            ]
        ]
