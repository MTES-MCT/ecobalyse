module Views.Alert exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Icon as Icon


type alias Config msg =
    { level : Level
    , close : Maybe msg
    , title : String
    , content : List (Html msg)
    }


type Level
    = Danger
    | Warning
    | Info
    | Success


icon : Level -> Html msg
icon level =
    case level of
        Danger ->
            span [ class "me-1" ] [ Icon.warning ]

        Warning ->
            span [ class "me-1" ] [ Icon.warning ]

        Info ->
            span [ class "me-1" ] [ Icon.info ]

        _ ->
            text ""


preformatted : Config msg -> Html msg
preformatted config =
    simple { config | content = [ pre [ class "fs-7 mb-0" ] config.content ] }


simple : Config msg -> Html msg
simple { level, content, title, close } =
    div
        [ class <| "alert alert-" ++ levelToClass level
        , classList [ ( "alert-dismissible", close /= Nothing ) ]
        ]
        [ h5 [ class "alert-heading" ] [ icon level, text title ]
        , div [] content
        , case close of
            Just closeMsg ->
                button [ type_ "button", class "btn-close", attribute "aria-label" "Fermer", attribute "data-bs-dismiss" "alert", onClick closeMsg ] []

            Nothing ->
                text ""
        ]


levelToClass : Level -> String
levelToClass level =
    case level of
        Danger ->
            "danger"

        Warning ->
            "warning"

        Info ->
            "info"

        Success ->
            "success"
