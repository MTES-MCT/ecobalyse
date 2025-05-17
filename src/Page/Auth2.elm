module Page.Auth2 exposing
    ( Model
    , Msg(..)
    , init
    , initLogin
    , update
    , view
    )

import Browser.Navigation
import Data.Env as Env
import Data.Session as Session exposing (Session)
import Data.User2 as User exposing (AccessTokenData, FormErrors, SignupForm, User)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData
import Request.Auth2 as Auth
import Request.BackendHttp as BackendHttp exposing (WebData)
import Route
import Views.Container as Container
import Views.Markdown as Markdown
import Views.Spinner as Spinner


type alias Model =
    { tab : Tab
    }


type alias Email =
    String


type alias Token =
    String


type Msg
    = AskLoginEmailResponse (WebData ())
    | AskLoginEmailSubmit
    | LoginResponse (WebData AccessTokenData)
    | ProfileResponse AccessTokenData (WebData User)
    | SignupResponse (WebData User)
    | SignupSubmit
    | SwitchTab Tab
    | UpdateAskLoginEmailForm Email
    | UpdateSignupForm SignupForm


type Tab
    = Account User
    | AskLoginEmail Email
    | AskLoginEmailSent Email
    | Authenticating
    | Signup SignupForm FormErrors
    | SignupCompleted Email


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { tab =
            session
                |> Session.getAuth2
                |> Maybe.map (.user >> Account)
                |> Maybe.withDefault (AskLoginEmail "")
      }
    , session
    , Cmd.none
    )


initLogin : Session -> Email -> Token -> ( Model, Session, Cmd Msg )
initLogin session email token =
    ( { tab = Authenticating }
    , session
    , Auth.login session LoginResponse email token
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case ( model.tab, msg ) of
        -- Tab updates
        ( _, SwitchTab tab ) ->
            ( { model | tab = tab }, session, Cmd.none )

        -- Account tab updates
        ( Account _, _ ) ->
            ( model, session, Cmd.none )

        --
        -- AskLoginEmail tab updates
        --
        ( AskLoginEmail email, AskLoginEmailResponse (RemoteData.Success _) ) ->
            ( { model | tab = AskLoginEmailSent email }
            , session
            , Cmd.none
            )

        ( AskLoginEmail _, AskLoginEmailResponse (RemoteData.Failure error) ) ->
            ( model
            , session
                |> Session.notifyError "Erreur lors de la connexion" (BackendHttp.errorToString error)
            , Cmd.none
            )

        ( AskLoginEmail _, UpdateAskLoginEmailForm email ) ->
            ( { model | tab = AskLoginEmail email }
            , session
            , Cmd.none
            )

        ( AskLoginEmail email, AskLoginEmailSubmit ) ->
            ( model
            , session
            , String.trim email
                |> Auth.askLoginEmail session AskLoginEmailResponse
            )

        -- AskLoginEmail tab catch all
        ( AskLoginEmail _, _ ) ->
            ( model, session, Cmd.none )

        -- AskedLoginEmailSent tab catch all
        ( AskLoginEmailSent _, _ ) ->
            ( model, session, Cmd.none )

        --
        -- Authenticating tab updates
        --
        ( Authenticating, LoginResponse (RemoteData.Success accessTokenData) ) ->
            ( { model | tab = Authenticating }
            , session
            , Auth.profileFromAccessToken session (ProfileResponse accessTokenData) accessTokenData.accessToken
            )

        ( Authenticating, LoginResponse (RemoteData.Failure error) ) ->
            ( model
            , session
                |> Session.notifyError
                    "Erreur lors de la récupération du jeton d'authentification"
                    (BackendHttp.errorToString error)
            , Browser.Navigation.load <| Route.toString Route.Auth2
            )

        ( Authenticating, ProfileResponse accessTokenData (RemoteData.Success user) ) ->
            ( { model | tab = Account user }
            , session |> Session.setAuth2 (Just { accessTokenData = accessTokenData, user = user })
            , Cmd.none
            )

        ( Authenticating, ProfileResponse _ (RemoteData.Failure error) ) ->
            ( model
            , session
                |> Session.notifyError
                    "Erreur lors de la récupération du profil utilisateur"
                    (BackendHttp.errorToString error)
            , Browser.Navigation.load <| Route.toString Route.Auth2
            )

        -- Authenticating tab catch all
        ( Authenticating, _ ) ->
            ( model, session, Cmd.none )

        --
        -- Signup tab updates
        --
        ( Signup { email } _, SignupResponse (RemoteData.Success _) ) ->
            ( { model | tab = SignupCompleted email }
            , session
            , Cmd.none
            )

        ( Signup _ _, SignupResponse (RemoteData.Failure error) ) ->
            ( model
            , session
                |> Session.notifyError "Erreur lors de l'inscription" (BackendHttp.errorToString error)
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
view session model =
    ( "Connexion / Inscription"
    , [ Container.centered [ class "pb-5" ]
            [ div [ class "row" ]
                [ div [ class "col-lg-10 offset-lg-1 col-xl-8 offset-xl-2 d-flex flex-column gap-3" ]
                    [ h1 [] [ text "Connexion / Inscription" ]
                    , viewTab session model.tab
                    ]
                ]
            ]
      ]
    )


viewTab : Session -> Tab -> Html Msg
viewTab session currentTab =
    let
        tabs =
            case Session.getAuth2 session of
                Just { user } ->
                    [ ( "Mon compte", Account user ) ]

                Nothing ->
                    [ ( "Inscription", Signup User.emptySignupForm Dict.empty )
                    , ( "Connexion", AskLoginEmail "" )
                    ]
    in
    div [ class "card shadow-sm px-0" ]
        [ div [ class "card-header px-0 pb-0 border-bottom-0" ]
            [ tabs
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
                |> ul [ class "Tabs nav nav-tabs nav-fill justify-content-end gap-2 px-2" ]
            ]
        , div [ class "card-body" ]
            [ case currentTab of
                Account user ->
                    viewAccount user

                AskLoginEmail email ->
                    viewAskLoginEmailForm email

                AskLoginEmailSent email ->
                    viewLoginEmailSent email

                Authenticating ->
                    Spinner.view

                Signup signupForm formErrors ->
                    viewSignupForm signupForm formErrors

                SignupCompleted email ->
                    viewSignupCompleted email
            ]
        ]


viewAccount : User -> Html Msg
viewAccount user =
    div []
        [ h2 [ class "h5" ] [ text "Profil utilisateur" ]
        , p []
            [ text "Email: "
            , text user.email
            ]
        , p []
            [ text "Prénom: "
            , text user.profile.firstName
            ]
        , p []
            [ text "Nom: "
            , text user.profile.lastName
            ]
        , p []
            [ text "Organisation: "
            , text user.profile.organization
            ]
        ]


viewAskLoginEmailForm : Email -> Html Msg
viewAskLoginEmailForm email =
    Html.form [ onSubmit AskLoginEmailSubmit ]
        [ div [ class "mb-3" ]
            [ label [ for "email", class "form-label" ]
                [ text "Email" ]
            , input
                [ type_ "email"
                , class "form-control"
                , id "email"
                , placeholder "nom@example.com"
                , value email
                , onInput UpdateAskLoginEmailForm
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


viewLoginEmailSent : Email -> Html msg
viewLoginEmailSent email =
    div [ class "alert alert-info mb-0" ]
        [ h2 [ class "h5" ] [ text "Email de connexion envoyé" ]
        , """Un email contenant un lien d'authentification a été envoyé à l'adresse `{email}`."""
            |> String.replace "{email}" email
            |> Markdown.simple []
        ]


viewSignupCompleted : Email -> Html Msg
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
        ( Account _, Account _ ) ->
            True

        ( Authenticating, AskLoginEmail _ ) ->
            True

        ( AskLoginEmail _, Authenticating ) ->
            True

        ( AskLoginEmail _, AskLoginEmail _ ) ->
            True

        ( AskLoginEmail _, AskLoginEmailSent _ ) ->
            True

        ( AskLoginEmailSent _, AskLoginEmail _ ) ->
            True

        ( Signup _ _, Signup _ _ ) ->
            True

        ( Signup _ _, SignupCompleted _ ) ->
            True

        ( SignupCompleted _, Signup _ _ ) ->
            True

        _ ->
            False
