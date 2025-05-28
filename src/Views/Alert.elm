module Views.Alert exposing
    ( Level(..)
    , backendError
    , preformatted
    , serverError
    , simple
    )

import Data.Env as Env
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Request.BackendHttp.Error as BackendError
import Views.Icon as Icon


type alias Config msg =
    { close : Maybe msg
    , content : List (Html msg)
    , level : Level
    , title : Maybe String
    }


type Level
    = Danger
    | Info
    | Success
    | Warning


icon : Level -> Html msg
icon level =
    span [ class "me-1" ]
        [ case level of
            Danger ->
                Icon.warning

            Info ->
                Icon.info

            Success ->
                Icon.checkCircle

            Warning ->
                Icon.warning
        ]


backendError : Maybe msg -> BackendError.Error -> Html msg
backendError close error =
    simple
        { close = close
        , content =
            [ case BackendError.mapErrorResponse error of
                Just { detail, headers, statusCode, title, url } ->
                    let
                        errorText =
                            [ ( "Message", detail )
                            , ( "URL", url )
                            , ( "Status code", String.fromInt statusCode )
                            , ( "En-têtes"
                              , Dict.toList headers
                                    |> List.map (\( a, b ) -> "\n- " ++ a ++ ": " ++ b)
                                    |> String.concat
                              )
                            ]
                                |> List.map (\( a, b ) -> a ++ ": " ++ b)
                                |> String.join "\n"
                    in
                    div []
                        [ p [ class "mb-2 text-truncate" ]
                            [ case title of
                                Just title_ ->
                                    if title_ == detail || String.isEmpty title_ then
                                        text detail

                                    else
                                        span []
                                            [ strong [] [ text <| title_ ++ "\u{00A0}: " ]
                                            , text detail
                                            ]

                                Nothing ->
                                    text detail
                            ]
                        , Html.details []
                            [ summary [] [ text "Détails de l'erreur" ]
                            , text errorText
                                |> List.singleton
                                |> pre [ class "mt-1 mb-0 ms-3" ]
                            ]
                        , reportErrorLink <| detail ++ " " ++ errorText
                        ]

                Nothing ->
                    div [] [ text "Le serveur est probablement indisponible", reportErrorLink "test" ]
            ]
        , level = Danger
        , title = Just "Une erreur serveur a été rencontrée"
        }


reportErrorLink : String -> Html msg
reportErrorLink error =
    p [ class "fs-7 mt-1 mb-0" ]
        [ a
            [ "mailto:"
                ++ Env.contactEmail
                ++ "?Subject="
                ++ escapeUrl "[Ecobalyse] Erreur rencontrée"
                ++ "&Body="
                ++ escapeUrl "Bonjour, j'ai rencontré une erreur sur le site Ecobalyse. En voici les détails:\n\n"
                ++ escapeUrl error
                |> href
            ]
            [ text "Envoyer un rapport d'incident par email" ]
        ]


escapeUrl : String -> String
escapeUrl =
    String.replace " " "%20"
        >> String.replace "\n" "%0A"
        >> String.replace "\u{000D}" "%0D"
        >> String.replace "\t" "%09"
        >> String.replace "\"" "%22"
        >> String.replace "'" "%27"
        >> String.replace "<" "%3C"
        >> String.replace ">" "%3E"
        >> String.replace "&" "%26"


serverError : String -> Html msg
serverError error =
    simple
        { close = Nothing
        , content =
            case String.lines error of
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
                        , reportErrorLink error
                        ]
                    ]
        , level = Info
        , title = Just "Le serveur a retourné une erreur"
        }


preformatted : Config msg -> Html msg
preformatted config =
    simple { config | content = [ pre [ class "fs-7 mb-0" ] config.content ] }


simple : Config msg -> Html msg
simple { close, content, level, title } =
    div
        [ class <| "alert alert-" ++ levelToClass level
        , classList [ ( "alert-dismissible", close /= Nothing ) ]
        ]
        [ case title of
            Just title_ ->
                h5 [ class "alert-heading d-flex align-items-center mb-0" ]
                    [ icon level, text title_ ]

            Nothing ->
                text ""
        , div [ class "mt-1" ] content
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

        Info ->
            "info"

        Success ->
            "success"

        Warning ->
            "warning"
