module Views.Alert exposing
    ( Level(..)
    , backendError
    , preformatted
    , serverError
    , simple
    )

import Data.Env as Env
import Data.Session exposing (Session)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Request.BackendHttp.Error as BackendError


type alias Config msg =
    { attributes : List (Attribute msg)
    , close : Maybe msg
    , content : List (Html msg)
    , level : Level
    , title : Maybe String
    }


type Level
    = Danger
    | Info
    | Success
    | Warning


backendError : Session -> Maybe msg -> BackendError.Error -> Html msg
backendError session close error =
    let
        { detail, headers, statusCode, title, url } =
            BackendError.mapErrorResponse error

        plainTextError =
            [ ( "Title", title )
            , ( "Message", Just detail )
            , ( "URL"
              , if String.isEmpty url then
                    Nothing

                else
                    Just url
              )
            , ( "Status code"
              , if statusCode == 0 then
                    Nothing

                else
                    Just <| String.fromInt statusCode
              )
            , ( "En-têtes"
              , if Dict.isEmpty headers then
                    Nothing

                else
                    Dict.toList headers
                        |> List.map (\( a, b ) -> "\n- " ++ a ++ ": " ++ b)
                        |> String.concat
                        |> Just
              )
            ]
                |> List.filterMap (\( a, b ) -> b |> Maybe.map (\justB -> a ++ ": " ++ justB))
                |> String.join "\n"
    in
    simple
        { attributes = []
        , close = close
        , content =
            [ div []
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
                    , pre [ class "mt-1 mb-0 ms-3" ] [ text plainTextError ]
                    ]
                , reportErrorLink <| detail ++ " " ++ plainTextError
                ]
            , div [ class "fs-8 text-muted" ]
                [ em [] [ text <| "Backend url: " ++ session.clientUrl ++ "/backend/api" ] ]
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
        { attributes = []
        , close = Nothing
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


{-| A simple DSFR compliant alert view which can be used for both toasts and regular contents.
-}
simple : Config msg -> Html msg
simple { attributes, close, content, level, title } =
    div
        (attributes
            ++ [ class "fr-alert shadow-sm"
               , classList
                    [ ( "fr-alert--success", level == Success )
                    , ( "fr-alert--info", level == Info )
                    , ( "fr-alert--warning", level == Warning )
                    , ( "fr-alert--error", level == Danger )
                    ]
               ]
        )
        [ case title of
            Just title_ ->
                h3 [ class "h5 mb-2" ] [ text title_ ]

            Nothing ->
                text ""
        , div [ class "mb-1" ] content
        , case close of
            Just closeMsg ->
                button
                    [ type_ "button"
                    , class "fr-link fr-link--close"
                    , attribute "aria-label" "Fermer"
                    , onClick closeMsg
                    ]
                    [ text "Masquer le message" ]

            Nothing ->
                text ""
        ]
