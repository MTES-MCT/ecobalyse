module Views.Spinner exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Maybe { loaded : Int, total : Int } -> Html msg
view progress =
    div
        [ class "d-flex flex-column gap-3 justify-content-center align-items-center"
        , style "min-height" "25vh"
        ]
        [ div [ class "spinner-border text-primary", attribute "role" "status" ] []
        , div [ class "text-muted" ]
            [ case progress of
                Just { loaded, total } ->
                    if total > 0 then
                        div [ class "d-flex flex-column gap-1" ]
                            [ text <| "Récupération des données\u{00A0}: " ++ String.fromInt loaded ++ "/" ++ String.fromInt total
                            , div
                                [ class "progress w-100"
                                , attribute "role" "progressbar"
                                , attribute "aria-label" "Progression du chargement des données"
                                , attribute "aria-valuenow" (String.fromInt loaded)
                                , attribute "aria-valuemin" "0"
                                , attribute "aria-valuemax" (String.fromInt total)
                                ]
                                [ div
                                    [ class "progress-bar"
                                    , style "width" (String.fromFloat (toFloat loaded * 100 / toFloat total) ++ "%")
                                    ]
                                    []
                                ]
                            ]

                    else
                        defaultText

                Nothing ->
                    defaultText
            ]
        ]


defaultText : Html msg
defaultText =
    text "Chargement…"
