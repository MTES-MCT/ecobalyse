module Page.Auth exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import Views.Alert as Alert
import Views.Container as Container
import Views.Markdown as Markdown


type alias Model =
    ()


type Msg
    = Login
    | Logout
    | LoggedIn (Result String Session.FullImpacts)


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( ()
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg _ =
    case msg of
        LoggedIn (Ok newProcessesJson) ->
            let
                newSession =
                    Session.loggedIn session newProcessesJson
                        |> Session.notifyInfo "Vous avez maintenant accès au détail des impacts, à utiliser conformément aux conditions" ""
            in
            ( ()
            , newSession
            , newSession.store |> Session.serializeStore |> Ports.saveStore
            )

        LoggedIn (Err error) ->
            let
                newSession =
                    session
                        |> Session.notifyError "Impossible de charger les impacts lors de la connexion" error
            in
            ( ()
            , newSession
            , Cmd.none
            )

        Login ->
            ( ()
            , session
            , Session.login LoggedIn
            )

        Logout ->
            let
                newSession =
                    Session.logout session
                        |> Session.notifyInfo "Vous n'avez plus accès au détail des impacts" ""
            in
            ( ()
            , newSession
            , newSession.store |> Session.serializeStore |> Ports.saveStore
            )


view : Session -> Model -> ( String, List (Html Msg) )
view session _ =
    ( "API"
    , [ Container.centered [ class "pb-5" ]
            [ h1 [ class "mb-3" ] [ text "Connexion / Inscription" ]
            , div [ class "row" ]
                [ div [ class "col-xl-12" ]
                    [ Alert.simple
                        { level = Alert.Info
                        , close = Nothing
                        , title = Nothing
                        , content =
                            [ div [ class "fs-7" ]
                                [ """Pour avoir accès au détail des impacts, il est nécessaire de s'enregistrer et
                                valider que vous êtes Français, et que vous n'utiliserez pas ces données à des fins
                                commerciales."""
                                    |> Markdown.simple []
                                ]
                            ]
                        }
                    ]
                ]
            , if Session.isAuthenticated session then
                button [ onClick Logout ] [ text "Déconnexion" ]

              else
                button [ onClick Login ] [ text "Connexion" ]
            ]
      ]
    )
