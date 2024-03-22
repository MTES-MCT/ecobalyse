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
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Ports
import Views.Alert as Alert
import Views.Container as Container
import Views.Markdown as Markdown



-- Auth flow:
-- 1/ ask for login:
--    - ask for a connection link via email: should receive an email with a login link
--    - once the link in the email received is clicked, the backend will redirect to /#/auth/loggedIn
--      - GET the user info (to make sure the user is connected)
--      - load the full processes with impacts
-- 2/ register:
--    - ask for registration with email, firstname, lastname, cgu (company): should receive en email with a validation link
--    - once the link in the email received is clicked, may not go through the login flow


login_url : String
login_url =
    "/accounts/login/"


profile_url : String
profile_url =
    "/accounts/profile.json/"


type alias Model =
    { user : User
    , action : Action
    , loggedIn : Bool
    }


type alias User =
    { email : String
    , firstname : String
    , lastname : String
    , cgu : Bool
    }


emptyModel : { loggedIn : Bool } -> Model
emptyModel { loggedIn } =
    { user =
        { email = ""
        , firstname = ""
        , lastname = ""
        , cgu = False
        }
    , action = Register
    , loggedIn = loggedIn
    }


type Action
    = Register
    | Authenticate


type Msg
    = AskForLogin
    | ChangeAction Action
    | GotUserInfo (Result Http.Error User)
    | Login
    | Logout
    | LoggedIn (Result String Session.FullImpacts)
    | TokenEmailSent (Result Http.Error String)
    | UpdateForm Model


init : Session -> { loggedIn : Bool } -> ( Model, Session, Cmd Msg )
init session data =
    ( emptyModel data
    , session
    , if data.loggedIn then
        -- Query the user endpoint on the backend to validate that the user is connected
        getUserInfo

      else
        Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        AskForLogin ->
            ( model
            , session
            , askForLogin model.user.email
            )

        ChangeAction action ->
            ( { model | action = action }
            , session
            , Cmd.none
            )

        GotUserInfo (Ok user) ->
            ( { model | user = user }
            , session
            , Session.login LoggedIn
            )

        GotUserInfo (Err _) ->
            ( model
            , session
                |> Session.notifyError "Erreur lors du login" ""
            , Cmd.none
            )

        Login ->
            ( model
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

        TokenEmailSent (Ok message) ->
            ( model
            , session
                |> Session.notifyInfo "Un email vous a été envoyé avec un lien de connexion" message
            , Cmd.none
            )

        TokenEmailSent (Err _) ->
            ( model
            , session
                |> Session.notifyError "Erreur lors du login" ""
            , Cmd.none
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
                [ if model.loggedIn then
                    text "logged in"

                  else if Session.isAuthenticated session then
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
                    viewRegisterForm model

                Authenticate ->
                    viewLoginForm model
            ]
        ]


viewLoginForm : Model -> Html Msg
viewLoginForm ({ user } as model) =
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
                , required True
                , value user.email
                , onInput (\email -> UpdateForm { model | user = { user | email = email } })
                ]
                []
            ]
        , button
            [ type_ "submit"
            , class "btn btn-primary mb-3"
            , disabled <| String.isEmpty user.email
            , onClick AskForLogin
            ]
            [ text "Connexion" ]
        ]


viewRegisterForm : Model -> Html Msg
viewRegisterForm ({ user } as model) =
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
                , required True
                , value user.email
                , onInput (\email -> UpdateForm { model | user = { user | email = email } })
                ]
                []
            ]
        , div [ class "mb-3" ]
            [ label
                [ for "firstnameInput"
                , class "form-label"
                ]
                [ text "Prénom" ]
            , input
                [ type_ "text"
                , class "form-control"
                , id "firstnameInput"
                , placeholder "Joséphine"
                , required True
                , value user.firstname
                , onInput (\firstname -> UpdateForm { model | user = { user | firstname = firstname } })
                ]
                []
            ]
        , div [ class "mb-3" ]
            [ label
                [ for "lastnameInput"
                , class "form-label"
                ]
                [ text "Nom" ]
            , input
                [ type_ "text"
                , class "form-control"
                , id "lastnameInput"
                , placeholder "Durand"
                , required True
                , value user.lastname
                , onInput (\lastname -> UpdateForm { model | user = { user | lastname = lastname } })
                ]
                []
            ]
        , div [ class "mb-3" ]
            [ label
                [ for "cguInput"
                , class "form-check form-switch form-check-label pt-1"
                ]
                [ input
                    [ type_ "checkbox"
                    , class "form-check-input"
                    , id "cguInput"
                    , required True
                    , checked user.cgu
                    , onCheck (\isChecked -> UpdateForm { model | user = { user | cgu = isChecked } })
                    ]
                    []
                , text "Je m'engage à ne pas utiliser les données pour une utilisation commerciale."
                ]
            ]
        , button
            [ type_ "submit"
            , class "btn btn-primary mb-3"
            , onClick Login
            ]
            [ text "M'inscrire" ]
        ]



---- helpers


askForLogin : String -> Cmd Msg
askForLogin email =
    Http.post
        { url = login_url
        , body = Http.jsonBody (encodeEmail email)
        , expect = Http.expectJson TokenEmailSent decodeTokenAsked
        }


getUserInfo : Cmd Msg
getUserInfo =
    Http.riskyRequest
        { method = "GET"
        , headers = []
        , url = profile_url
        , body = Http.emptyBody
        , expect = Http.expectJson GotUserInfo decodeUserInfo
        , timeout = Nothing
        , tracker = Nothing
        }



---- encoders/decoders


decodeTokenAsked : Decoder String
decodeTokenAsked =
    Decode.field "message" Decode.string


decodeUserInfo : Decoder User
decodeUserInfo =
    Decode.succeed User
        |> Pipe.required "email" Decode.string
        |> Pipe.required "first_name" Decode.string
        |> Pipe.required "last_name" Decode.string
        |> Pipe.required "terms_of_use" Decode.bool


encodeEmail : String -> Encode.Value
encodeEmail =
    Encode.string
