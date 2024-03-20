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
    { email : String
    , firstname : String
    , lastname : String
    , cgu : Bool
    , action : Action
    }


emptyModel : Model
emptyModel =
    { email = ""
    , firstname = ""
    , lastname = ""
    , cgu = False
    , action = Register
    }


type Action
    = Register
    | Authenticate


type Msg
    = ChangeAction Action
    | Login
    | Logout
    | LoggedIn (Result String Session.FullImpacts)
    | UpdateForm Model


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( emptyModel
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        ChangeAction action ->
            ( { model | action = action }
            , session
            , Cmd.none
            )

        LoggedIn (Ok newProcessesJson) ->
            let
                newSession =
                    Session.loggedIn session newProcessesJson
                        |> Session.notifyInfo "Vous avez maintenant accès au détail des impacts, à utiliser conformément aux conditions" ""
            in
            ( model
            , newSession
            , newSession.store |> Session.serializeStore |> Ports.saveStore
            )

        LoggedIn (Err error) ->
            let
                newSession =
                    session
                        |> Session.notifyError "Impossible de charger les impacts lors de la connexion" error
            in
            ( model
            , newSession
            , Cmd.none
            )

        Login ->
            ( model
            , session
            , Session.login LoggedIn
            )

        Logout ->
            let
                newSession =
                    Session.logout session
                        |> Session.notifyInfo "Vous n'avez plus accès au détail des impacts" ""
            in
            ( model
            , newSession
            , newSession.store |> Session.serializeStore |> Ports.saveStore
            )

        UpdateForm newModel ->
            ( newModel
            , session
            , Cmd.none
            )


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
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
            , div [ class "row d-flex justify-content-center" ]
                [ if Session.isAuthenticated session then
                    button [ onClick Logout ] [ text "Déconnexion" ]

                  else
                    viewLoginRegisterForm model
                ]
            ]
      ]
    )


viewLoginRegisterForm : Model -> Html Msg
viewLoginRegisterForm model =
    div [ class "card shadow-sm col-sm-6" ]
        [ div [ class "card-header px-0 pb-0 border-bottom-0" ]
            [ ul [ class "Tabs nav nav-tabs nav-fill justify-content-end gap-2 px-2" ]
                ([ ( "Inscription", Register )
                 , ( "Connexion", Authenticate )
                 ]
                    |> List.map
                        (\( label, action ) ->
                            li
                                [ class "TabsTab nav-item"
                                , classList [ ( "active", model.action == action ) ]
                                ]
                                [ button
                                    [ class "nav-link no-outline border-top-0 active"
                                    , onClick (ChangeAction action)
                                    ]
                                    [ text label ]
                                ]
                        )
                )
            ]
        , div [ class "card-body" ]
            [ case model.action of
                Register ->
                    text "inscription"

                Authenticate ->
                    viewLoginForm model
            ]
        ]


viewLoginForm : Model -> Html Msg
viewLoginForm model =
    div []
        [ div [ class "mb-3" ]
            [ label
                [ for "emailInput"
                , class "form-label"
                ]
                [ text "Adresse e-mail" ]
            , input
                [ type_ "email"
                , class "form-control"
                , id "emailInput"
                , placeholder "nom@example.com"
                , value model.email
                , onInput (\email -> UpdateForm { model | email = email })
                ]
                []
            ]
        , button
            [ type_ "submit"
            , class "btn btn-primary mb-3"
            , onClick Login
            ]
            [ text "Connexion" ]
        ]
