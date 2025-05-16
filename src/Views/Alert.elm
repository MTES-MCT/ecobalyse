module Views.Alert exposing
    ( Level(..)
    , preformatted
    , serverError
    , simple
    )

import Data.Env as Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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
    case level of
        Danger ->
            span [ class "me-1" ] [ Icon.warning ]

        Info ->
            span [ class "me-1" ] [ Icon.info ]

        Success ->
            span [ class "me-1" ] [ Icon.checkCircle ]

        Warning ->
            span [ class "me-1" ] [ Icon.warning ]


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
                        , a
                            [ class "btn btn-primary"
                            , href
                                ("mailto:"
                                    ++ Env.contactEmail
                                    ++ "?Subject=[Ecobalyse]+Erreur+rencontrée&Body="
                                    ++ error
                                )
                            ]
                            [ text "Envoyer un rapport d'incident" ]
                        ]
                    ]
        , level = Info
        , title = Just "Erreur de chargement des données"
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

        Info ->
            "info"

        Success ->
            "success"

        Warning ->
            "warning"
