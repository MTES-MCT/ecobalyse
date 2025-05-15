module Page.Auth2 exposing (Model, Msg(..), init, update, view)

import Data.Env as Env
import Data.Session as Session exposing (Session)
import Data.User2 as User exposing (FormErrors, SignupForm, User)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Request.Auth2 as Auth
import Request.Common as RequestCommon
import Views.Container as Container
import Views.Markdown as Markdown


type alias Model =
    { tab : Tab
    }


type Msg
    = LoginResponse (Result Http.Error ())
    | LoginSubmit
    | SignupResponse (Result Http.Error User)
    | SignupSubmit
    | SwitchTab Tab
    | UpdateLoginForm String
    | UpdateSignupForm SignupForm


type Tab
    = Login String
    | LoginEmailSent String
    | Signup SignupForm FormErrors
    | SignupCompleted String


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { tab = Login "" }
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case ( model.tab, msg ) of
        --
        -- Global page updates
        --
        ( _, SwitchTab tab ) ->
            ( { model | tab = tab }
            , session
            , Cmd.none
            )

        --
        -- Login tab updates
        --
        ( Login _, UpdateLoginForm email ) ->
            ( { model | tab = Login email }
            , session
            , Cmd.none
            )

        ( Login email, LoginResponse (Ok _) ) ->
            ( { model | tab = LoginEmailSent email }
            , session
            , Cmd.none
            )

        ( Login _, LoginResponse (Err error) ) ->
            ( model
            , session
                |> Session.notifyError "Erreur lors de la connexion" (RequestCommon.errorToString error)
            , Cmd.none
            )

        ( Login email, LoginSubmit ) ->
            ( model
            , session
            , email |> String.trim |> Auth.login session LoginResponse
            )

        -- Login tab catch all
        ( Login _, _ ) ->
            ( model, session, Cmd.none )

        -- LoginEmailSent tab catch all
        ( LoginEmailSent _, _ ) ->
            ( model, session, Cmd.none )

        --
        -- Signup tab updates
        --
        ( Signup { email } _, SignupResponse (Ok _) ) ->
            ( { model | tab = SignupCompleted email }
            , session
              -- TODO: update session with user info
              -- |> Session.authenticated user
            , Cmd.none
            )

        ( Signup _ _, SignupResponse (Err error) ) ->
            ( model
            , session
                |> Session.notifyError "Erreur lors de l'inscription" (RequestCommon.errorToString error)
            , Cmd.none
            )

        ( Signup signupForm _, SignupSubmit ) ->
            let
                newFormErrors =
                    User.validateSignupForm signupForm
            in
            ( { model | tab = Signup signupForm newFormErrors }
            , session
            , if newFormErrors == Dict.empty then
                Auth.signup session SignupResponse signupForm

              else
                Cmd.none
            )

        ( Signup _ _, UpdateSignupForm signupForm ) ->
            ( { model | tab = Signup signupForm Dict.empty }, session, Cmd.none )

        -- Signup tab catch all
        ( Signup _ _, _ ) ->
            ( model, session, Cmd.none )

        -- SignupCompleted tab catch all
        ( SignupCompleted _, _ ) ->
            ( model, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Connexion / Inscription"
    , [ Container.centered [ class "pb-5" ]
            [ div [ class "row" ]
                [ div [ class "col-lg-10 offset-lg-1 col-xl-8 offset-xl-2 d-flex flex-column gap-3" ]
                    [ h1 [] [ text "Connexion / Inscription" ]
                    , viewTab model.tab
                    ]
                ]
            ]
      ]
    )


viewTab : Tab -> Html Msg
viewTab currentTab =
    div [ class "card shadow-sm px-0" ]
        [ div [ class "card-header px-0 pb-0 border-bottom-0" ]
            [ ul [ class "Tabs nav nav-tabs nav-fill justify-content-end gap-2 px-2" ]
                ([ ( "Inscription", Signup User.emptySignupForm Dict.empty )
                 , ( "Connexion", Login "" )
                 ]
                    |> List.map
                        (\( label, tab ) ->
                            li
                                [ class "TabsTab nav-item"
                                , classList [ ( "active", isActiveTab currentTab tab ) ]
                                ]
                                [ button
                                    [ type_ "button"
                                    , class "nav-link no-outline border-top-0"
                                    , classList [ ( "active", isActiveTab currentTab tab ) ]
                                    , onClick (SwitchTab tab)
                                    ]
                                    [ text label ]
                                ]
                        )
                )
            ]
        , div [ class "card-body" ]
            [ case currentTab of
                Login email ->
                    viewLoginForm email

                LoginEmailSent email ->
                    viewLoginEmailSent email

                Signup signupForm formErrors ->
                    viewSignupForm signupForm formErrors

                SignupCompleted email ->
                    viewSignupCompleted email
            ]
        ]


viewLoginForm : String -> Html Msg
viewLoginForm email =
    Html.form [ onSubmit LoginSubmit ]
        [ div [ class "mb-3" ]
            [ label [ for "email", class "form-label" ]
                [ text "Email" ]
            , input
                [ type_ "email"
                , class "form-control"
                , id "email"
                , placeholder "nom@example.com"
                , value email
                , onInput UpdateLoginForm
                , required True
                ]
                []
            ]
        , div [ class "d-grid" ]
            [ button
                [ type_ "submit"
                , class "btn btn-primary"
                , disabled <| email == "" || User.validateEmail email /= Dict.empty
                ]
                [ text "Recevoir un email de connexion" ]
            ]
        ]


viewLoginEmailSent : String -> Html msg
viewLoginEmailSent email =
    div [ class "alert alert-info mb-0" ]
        [ h2 [ class "h5" ] [ text "Email de connexion envoyé" ]
        , """Un email contenant un lien d'authentification a été envoyé à l'adresse `{email}`."""
            |> String.replace "{email}" email
            |> Markdown.simple []
        ]


viewSignupCompleted : String -> Html Msg
viewSignupCompleted email =
    div [ class "alert alert-info mb-0" ]
        [ h2 [ class "h5" ] [ text "Inscription réussie" ]
        , """Un email contenant un lien d'authentification a été envoyé à l'adresse `{email}`."""
            |> String.replace "{email}" email
            |> Markdown.simple []
        ]


viewSignupForm : SignupForm -> FormErrors -> Html Msg
viewSignupForm signupForm formErrors =
    Html.form [ onSubmit SignupSubmit ]
        [ div [ class "mb-3" ]
            [ label [ for "email", class "form-label" ]
                [ text "Email" ]
            , input
                [ type_ "email"
                , class "form-control"
                , classList [ ( "is-invalid", Dict.member "email" formErrors ) ]
                , id "email"
                , placeholder "nom@example.com"
                , value signupForm.email
                , onInput <| \email -> UpdateSignupForm { signupForm | email = email }
                , required True
                ]
                []
            , viewFieldError "email" formErrors
            ]
        , div [ class "row" ]
            [ div [ class "col-md-6" ]
                [ div [ class "mb-3" ]
                    [ label [ for "firstName", class "form-label" ]
                        [ text "Prénom" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , classList [ ( "is-invalid", Dict.member "firstName" formErrors ) ]
                        , id "firstName"
                        , placeholder "Joséphine"
                        , value signupForm.firstName
                        , onInput <| \firstName -> UpdateSignupForm { signupForm | firstName = firstName }
                        , required True
                        ]
                        []
                    , viewFieldError "firstName" formErrors
                    ]
                ]
            , div [ class "col-md-6" ]
                [ div [ class "mb-3" ]
                    [ label [ for "lastName", class "form-label" ]
                        [ text "Nom" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , classList [ ( "is-invalid", Dict.member "lastName" formErrors ) ]
                        , id "lastName"
                        , placeholder "Durand"
                        , value signupForm.lastName
                        , onInput <| \lastName -> UpdateSignupForm { signupForm | lastName = lastName }
                        , required True
                        ]
                        []
                    , viewFieldError "lastName" formErrors
                    ]
                ]
            ]
        , div [ class "mb-3" ]
            [ label [ for "organization", class "form-label" ]
                [ text "Organisation" ]
            , input
                [ type_ "text"
                , class "form-control"
                , classList [ ( "is-invalid", Dict.member "organization" formErrors ) ]
                , id "organization"
                , placeholder "ACME Inc."
                , value signupForm.organization
                , onInput <| \organization -> UpdateSignupForm { signupForm | organization = organization }
                , required True
                ]
                []
            , viewFieldError "organization" formErrors
            ]
        , div [ class "mb-3 form-check" ]
            [ input
                [ type_ "checkbox"
                , class "form-check-input"
                , classList [ ( "is-invalid", Dict.member "termsAccepted" formErrors ) ]
                , id "termsAccepted"
                , checked signupForm.termsAccepted
                , onCheck <| \termsAccepted -> UpdateSignupForm { signupForm | termsAccepted = termsAccepted }
                , required True
                ]
                []
            , label [ class "form-check-label", for "termsAccepted" ]
                [ text "Je m’engage à respecter les "
                , a [ href Env.cguUrl, target "_blank" ] [ text "conditions d'utilisation" ]
                ]
            , viewFieldError "termsAccepted" formErrors
            ]
        , div [ class "d-grid" ]
            [ button
                [ type_ "submit"
                , class "btn btn-primary"
                , disabled <| signupForm == User.emptySignupForm || formErrors /= Dict.empty
                ]
                [ text "Valider mon inscription" ]
            ]
        ]


viewFieldError : String -> FormErrors -> Html msg
viewFieldError field errors =
    case Dict.get field errors of
        Just error ->
            div [ class "invalid-feedback" ]
                [ text error ]

        Nothing ->
            text ""


isActiveTab : Tab -> Tab -> Bool
isActiveTab tab1 tab2 =
    case ( tab1, tab2 ) of
        ( Signup _ _, Signup _ _ ) ->
            True

        ( Signup _ _, SignupCompleted _ ) ->
            True

        ( SignupCompleted _, Signup _ _ ) ->
            True

        ( Login _, Login _ ) ->
            True

        ( Login _, LoginEmailSent _ ) ->
            True

        ( LoginEmailSent _, Login _ ) ->
            True

        _ ->
            False
