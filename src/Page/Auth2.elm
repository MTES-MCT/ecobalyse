module Page.Auth2 exposing
    ( Model
    , Msg(..)
    , init
    , initLogin
    , update
    , view
    )

import Browser.Navigation as Nav
import Data.ApiToken exposing (CreatedToken)
import Data.Env as Env
import Data.Session as Session exposing (Session)
import Data.User2 as User exposing (AccessTokenData, FormErrors, SignupForm, User)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import RemoteData
import Request.ApiToken as ApiTokenHttp
import Request.Auth2 as Auth
import Request.BackendHttp exposing (WebData)
import Route
import Views.Button as Button
import Views.Container as Container
import Views.Icon as Icon
import Views.Markdown as Markdown
import Views.Spinner as Spinner
import Views.Table as Table


type alias Model =
    { tab : Tab
    }


type alias Email =
    String


type alias Token =
    String


type Msg
    = ApiTokensResponse (WebData (List CreatedToken))
    | CopyToClipboard String
    | LoginResponse (WebData AccessTokenData)
    | Logout User
    | LogoutResponse (WebData ())
    | MagicLinkResponse (WebData ())
    | MagicLinkSubmit
    | ProfileResponse AccessTokenData (WebData User)
    | SignupResponse (WebData User)
    | SignupSubmit
    | SwitchTab Tab
    | UpdateAskLoginEmailForm Email
    | UpdateSignupForm SignupForm


type Tab
    = Account Session.Auth2
    | ApiTokens (List CreatedToken)
    | Authenticating
    | MagicLinkForm Email
    | MagicLinkSent Email
    | Signup SignupForm FormErrors
    | SignupCompleted Email


init : Session -> ( Model, Session, Cmd Msg )
init session =
    case Session.getAuth2 session of
        Just auth ->
            ( { tab = Account auth }
            , session
              -- Always ensure fetching the freshest user profile
            , Cmd.batch
                [ Auth.profile session (ProfileResponse auth.accessTokenData)
                , ApiTokenHttp.list session ApiTokensResponse
                ]
            )

        Nothing ->
            ( { tab = MagicLinkForm "" }, session, Cmd.none )


{-| Init page when we receive magic link information
-}
initLogin : Session -> Email -> Token -> ( Model, Session, Cmd Msg )
initLogin session email token =
    ( { tab = Authenticating }
    , session
    , Auth.login session LoginResponse email token
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        -- Generic page updates
        CopyToClipboard accessToken ->
            ( model
            , session
            , Ports.copyToClipboard accessToken
            )

        SwitchTab tab ->
            ( { model | tab = tab }, session, Cmd.none )

        -- Specific tab updates
        tabMsg ->
            case model.tab of
                -- Account tab updates
                Account auth ->
                    updateAccountTab session auth tabMsg model

                -- ApiTokens tab updates
                ApiTokens apiTokens ->
                    updateApiTokensTab session apiTokens tabMsg model

                -- Authenticating tab updates
                Authenticating ->
                    updateAuthenticatingTab session tabMsg model

                -- AskLoginEmail tab updates
                MagicLinkForm email ->
                    updateMagicLinkTab session email tabMsg model

                -- AskedLoginEmailSent tab updates (currently no msg to handle)
                MagicLinkSent _ ->
                    ( model, session, Cmd.none )

                -- Signup tab updates
                Signup signupForm _ ->
                    updateSignupTab session signupForm tabMsg model

                -- SignupCompleted tab updates (currently no msg to handle)
                SignupCompleted _ ->
                    ( model, session, Cmd.none )


updateAccountTab : Session -> Session.Auth2 -> Msg -> Model -> ( Model, Session, Cmd Msg )
updateAccountTab session currentAuth msg model =
    case msg of
        Logout user ->
            ( model
            , session
            , user |> Auth.logout session LogoutResponse
            )

        LogoutResponse (RemoteData.Failure error) ->
            ( model
            , session |> Session.notifyBackendError error
            , Cmd.none
            )

        LogoutResponse (RemoteData.Success _) ->
            ( model
            , session
                |> Session.logout2
                |> Session.notifyInfo "Déconnexion" "Vous avez été deconnecté"
            , Nav.load <| Route.toString Route.Auth2
            )

        ProfileResponse _ (RemoteData.Success user) ->
            ( { model | tab = Account { currentAuth | user = user } }
            , session
            , Cmd.none
            )

        ProfileResponse _ (RemoteData.Failure error) ->
            ( model
            , session |> Session.notifyBackendError error
            , Cmd.none
            )

        _ ->
            ( model, session, Cmd.none )


updateApiTokensTab : Session -> List CreatedToken -> Msg -> Model -> ( Model, Session, Cmd Msg )
updateApiTokensTab session _ tabMsg model =
    case tabMsg of
        ApiTokensResponse (RemoteData.Success newApiTokens) ->
            ( { model | tab = ApiTokens newApiTokens }, session, Cmd.none )

        ApiTokensResponse (RemoteData.Failure error) ->
            ( model, session |> Session.notifyBackendError error, Cmd.none )

        _ ->
            ( model, session, Cmd.none )


updateMagicLinkTab : Session -> Email -> Msg -> Model -> ( Model, Session, Cmd Msg )
updateMagicLinkTab session email msg model =
    case msg of
        MagicLinkResponse (RemoteData.Success _) ->
            ( { model | tab = MagicLinkSent email }
            , session
            , Cmd.none
            )

        MagicLinkResponse (RemoteData.Failure error) ->
            ( model
            , session |> Session.notifyBackendError error
            , Cmd.none
            )

        MagicLinkSubmit ->
            ( model
            , session
            , String.trim email
                |> Auth.askMagicLink session MagicLinkResponse
            )

        UpdateAskLoginEmailForm email_ ->
            ( { model | tab = MagicLinkForm email_ }
            , session
            , Cmd.none
            )

        _ ->
            ( model, session, Cmd.none )


updateAuthenticatingTab : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
updateAuthenticatingTab session msg model =
    case msg of
        LoginResponse (RemoteData.Success accessTokenData) ->
            ( { model | tab = Authenticating }
            , session
            , accessTokenData.accessToken
                |> Auth.profileFromAccessToken session (ProfileResponse accessTokenData)
            )

        LoginResponse (RemoteData.Failure error) ->
            ( model
            , session |> Session.notifyBackendError error
            , Nav.load <| Route.toString Route.Auth2
            )

        ProfileResponse accessTokenData (RemoteData.Success user) ->
            ( { model | tab = Account { accessTokenData = accessTokenData, user = user } }
            , session |> Session.setAuth2 (Just { accessTokenData = accessTokenData, user = user })
            , Nav.pushUrl session.navKey <| Route.toString Route.Auth2
            )

        ProfileResponse _ (RemoteData.Failure error) ->
            ( model
            , session |> Session.notifyBackendError error
            , Nav.load <| Route.toString Route.Auth2
            )

        _ ->
            ( model, session, Cmd.none )


updateSignupTab : Session -> SignupForm -> Msg -> Model -> ( Model, Session, Cmd Msg )
updateSignupTab session signupForm msg model =
    case msg of
        SignupResponse (RemoteData.Success _) ->
            ( { model | tab = SignupCompleted signupForm.email }
            , session
            , Cmd.none
            )

        SignupResponse (RemoteData.Failure error) ->
            ( model
            , session |> Session.notifyBackendError error
            , Cmd.none
            )

        SignupSubmit ->
            let
                newFormErrors =
                    User.validateSignupForm signupForm

                newModel =
                    { model | tab = Signup signupForm newFormErrors }
            in
            if newFormErrors == Dict.empty then
                ( newModel
                , session
                , Auth.signup session SignupResponse signupForm
                )

            else
                ( newModel
                , session |> Session.notifyError "Erreur" "Veuillez corriger les champs en erreur"
                , Cmd.none
                )

        UpdateSignupForm signupForm_ ->
            ( { model | tab = Signup signupForm_ Dict.empty }, session, Cmd.none )

        _ ->
            ( model, session, Cmd.none )


viewTab : Session -> Tab -> Html Msg
viewTab session currentTab =
    let
        ( heading, tabs ) =
            case Session.getAuth2 session of
                Just user ->
                    ( "Mon compte (new auth)"
                    , [ ( "Compte", Account user )
                      , ( "Jetons d'API", ApiTokens [] )
                      ]
                    )

                Nothing ->
                    ( "Connexion / Inscription (new auth)"
                    , [ ( "Inscription", Signup User.emptySignupForm Dict.empty )
                      , ( "Connexion", MagicLinkForm "" )
                      ]
                    )
    in
    div []
        [ h1 [ class "mb-3" ] [ text heading ]
        , div [ class "card shadow-sm px-0" ]
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
                    Account auth ->
                        viewAccount auth

                    ApiTokens apiTokens ->
                        viewApiTokens apiTokens

                    Authenticating ->
                        Spinner.view

                    MagicLinkForm email ->
                        viewMagicLinkForm email

                    MagicLinkSent email ->
                        viewMagicLinkSent email

                    Signup signupForm formErrors ->
                        viewSignupForm signupForm formErrors

                    SignupCompleted email ->
                        viewSignupCompleted email
                ]
            ]
        ]


viewAccount : Session.Auth2 -> Html Msg
viewAccount { accessTokenData, user } =
    div []
        [ [ Just ( "Email", text user.email )
          , if user.isSuperuser then
                Just
                    ( "Équipe Ecobalyse"
                    , div [ class "d-flex justify-content-between align-middle gap-1" ]
                        [ strong [] [ text "Oui" ]
                        , a [ class "btn btn-sm btn-info", Route.href Route.Admin ]
                            [ Icon.lock, text "\u{00A0}Accès à l'admin" ]
                        ]
                    )

            else
                Nothing
          , Just ( "Nom", text user.profile.lastName )
          , Just ( "Prénom", text user.profile.firstName )
          , Just ( "Organisation", text user.profile.organization )
          , Just
                ( "Jeton d'API (API token)"
                , div []
                    [ code [] [ text "TODO" ]
                    , br [] []
                    , small [ class "text-muted" ]
                        [ text "Nécessaire pour obtenir les impacts détaillés dans "
                        , a [ Route.href Route.Api ] [ text "l'API" ]
                        ]
                    ]
                )

          -- FIXME: remove this before shipping to production; right now this is useful for debugging
          , if user.isSuperuser then
                Just ( "Jeton Web (Access token)", viewAccessData accessTokenData )

            else
                Nothing
          ]
            |> List.filterMap
                (Maybe.map
                    (\( label, htmlValue ) ->
                        tr []
                            [ th [ class "text-nowrap" ] [ text <| label ++ " : " ]
                            , td [] [ htmlValue ]
                            ]
                    )
                )
            |> tbody []
            |> List.singleton
            |> table [ class "table table-striped mb-0" ]
            |> List.singleton
            |> div [ class "table-responsive border shadow-sm" ]
        , div [ class "d-flex justify-content-center align-items-center gap-3" ]
            [ a [ Route.href Route.Home ]
                [ text "Retour à l'accueil" ]
            , button [ class "btn btn-primary my-3", onClick <| Logout user ]
                [ text "Déconnexion" ]
            ]
        ]


viewApiTokens : List CreatedToken -> Html Msg
viewApiTokens apiTokens =
    if List.isEmpty apiTokens then
        -- TODO: add a button to create an API token
        p [] [ text "Vous n'avez pas encore créé de jeton d'API. Vous pouvez en créer un en cliquant sur le bouton ci-dessous." ]

    else
        div [ class "table-responsive border shadow-sm" ]
            [ apiTokens
                |> List.map
                    (\apiToken ->
                        tr []
                            [ td [] [ text apiToken.id ]
                            , td [] [ apiToken.lastAccessedAt |> Maybe.withDefault "-" |> text ]
                            ]
                    )
                |> tbody []
                |> List.singleton
                |> table [ class "table table-striped mb-0" ]
            ]


viewAccessData : AccessTokenData -> Html Msg
viewAccessData data =
    div [ class "d-flex flex-column justify-content-between align-middle gap-1", style "overflow-x" "hidden" ]
        [ Table.responsiveDefault [ class "w-100" ]
            [ [ ( "accessToken", Just data.accessToken )
              , ( "expiresIn", data.expiresIn |> Maybe.map String.fromInt )
              , ( "refreshToken", data.refreshToken )
              , ( "tokenType", Just data.tokenType )
              ]
                |> List.map
                    (\( label, value ) ->
                        tr []
                            [ th [] [ text label ]
                            , td []
                                [ value
                                    |> Maybe.map (Button.copyButton CopyToClipboard)
                                    |> Maybe.withDefault (text "-")
                                ]
                            ]
                    )
                |> tbody []
            ]
        , div [ class "fs-8 text-muted d-flex gap-1 align-items-center" ]
            [ Icon.warning
            , text "Utile pour débugger, devrait être masqué avant mise en production effective. "
            ]
        ]


viewMagicLinkForm : Email -> Html Msg
viewMagicLinkForm email =
    Html.form [ onSubmit MagicLinkSubmit ]
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


viewMagicLinkSent : Email -> Html msg
viewMagicLinkSent email =
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

        ( ApiTokens _, ApiTokens _ ) ->
            True

        ( Authenticating, MagicLinkForm _ ) ->
            True

        ( MagicLinkForm _, Authenticating ) ->
            True

        ( MagicLinkForm _, MagicLinkForm _ ) ->
            True

        ( MagicLinkForm _, MagicLinkSent _ ) ->
            True

        ( MagicLinkSent _, MagicLinkForm _ ) ->
            True

        ( Signup _ _, Signup _ _ ) ->
            True

        ( Signup _ _, SignupCompleted _ ) ->
            True

        ( SignupCompleted _, Signup _ _ ) ->
            True

        _ ->
            False


view : Session -> Model -> ( String, List (Html Msg) )
view session model =
    ( "Authentification"
    , [ Container.centered [ class "pb-5" ]
            [ div [ class "row" ]
                [ div [ class "col-lg-10 offset-lg-1 col-xl-8 offset-xl-2 d-flex flex-column gap-3" ]
                    [ viewTab session model.tab ]
                ]
            ]
      ]
    )
