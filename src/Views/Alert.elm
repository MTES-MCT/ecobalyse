module Views.Alert exposing
    ( Level(..)
    , httpError
    , preformatted
    , simple
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Request.Common as HttpCommon
import Views.Icon as Icon


type alias Config msg =
    { level : Level
    , close : Maybe msg
    , title : Maybe String
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


httpError : Http.Error -> Html msg
httpError error =
    simple
        { title = Just "Erreur de chargement des données"
        , close = Nothing
        , level = Info
        , content =
            case error |> HttpCommon.errorToString |> String.lines of
                [] ->
                    []

                [ line ] ->
                    [ text line ]

                firstLine :: rest ->
                    [ div []
                        [ p [ class "mb-2" ] [ text "Une erreur serveur a été rencontrée\u{00A0}:" ]
                        , pre [ class "mb-1" ] [ text firstLine ]
                        , details [ class "mb-2" ]
                            [ summary [] [ text "Afficher les détails de l'erreur" ]
                            , pre [ class "mt-1" ]
                                [ rest |> String.join "\n" |> String.trim |> text ]
                            ]
                        , a
                            [ class "btn btn-primary"
                            , HttpCommon.errorToString error
                                |> (++) "mailto:wikicarbone@beta.gouv.fr?Subject=[Wikicarbone]+Erreur+rencontrée&Body="
                                |> href
                            ]
                            [ text "Envoyer un rapport d'incident" ]
                        ]
                    ]
        }


preformatted : Config msg -> Html msg
preformatted config =
    simple { config | content = [ pre [ class "fs-7 mb-0" ] config.content ] }


simple : Config msg -> Html msg
simple { level, content, title, close } =
    div
        [ class <| "alert alert-" ++ levelToClass level
        , classList [ ( "alert-dismissible", close /= Nothing ) ]
        ]
        [ case title of
            Just title_ ->
                h5 [ class "alert-heading d-flex align-items-center" ]
                    [ icon level, text title_ ]

            Nothing ->
                text ""
        , div [] content
        , case close of
            Just closeMsg ->
                button
                    [ type_ "button"
                    , class "btn-close"
                    , attribute "aria-label" "Fermer"
                    , attribute "data-bs-dismiss" "alert"
                    , onClick closeMsg
                    ]
                    []

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
