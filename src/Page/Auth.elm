module Page.Auth exposing
    ( Model
    , Msg(..)
    , init
    , initLogin
    , initSignup
    , update
    , view
    )

import Browser.Navigation as Nav
import Data.ApiToken as ApiToken exposing (CreatedToken, Token)
import Data.Env as Env
import Data.Session as Session exposing (Session)
import Data.User as User exposing (AccessTokenData, FormErrors, SignupForm, User)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import RemoteData
import Request.ApiToken as ApiTokenHttp
import Request.Auth as Auth
import Request.BackendHttp exposing (WebData)
import Request.BackendHttp.Error as BackendError
import Route
import Views.Container as Container
import Views.Format as Format
import Views.Icon as Icon
import Views.Markdown as Markdown
import Views.Spinner as Spinner


type alias Model =
    { tab : Tab
    }


type alias AccessToken =
    String


type alias Email =
    String


type Msg
    = ApiTokensResponse (WebData (List CreatedToken))
    | CopyToClipboard String
    | CreateToken
    | CreateTokenResponse (WebData Token)
    | DeleteApiToken CreatedToken
    | DeleteApiTokenResponse (WebData ())
    | DetailedProcessesResponse (WebData String)
    | LoginResponse (WebData AccessTokenData)
    | Logout User
    | LogoutResponse (WebData ())
    | MagicLinkResponse (WebData ())
    | MagicLinkSubmit
    | ProfileResponse AccessTokenData (WebData User)
    | SignupResponse (WebData User)
    | SignupSubmit
    | SwitchTab Tab
    | UpdateMagicLinkForm Email
    | UpdateSignupForm SignupForm


type Tab
    = Account Session.Auth
    | ApiTokenCreated Token
    | ApiTokenDelete CreatedToken
    | ApiTokens (WebData (List CreatedToken))
    | MagicLinkForm Email
    | MagicLinkLogin
    | MagicLinkSent Email
    | Signup SignupForm FormErrors
    | SignupCompleted Email


init : Session -> ( Model, Session, Cmd Msg )
init session =
    case Session.getAuth session of
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
initLogin : Session -> Email -> AccessToken -> ( Model, Session, Cmd Msg )
initLogin session email token =
    ( { tab = MagicLinkLogin }
    , session
    , Auth.login session LoginResponse email token
    )


initSignup : Session -> ( Model, Session, Cmd Msg )
initSignup session =
    case Session.getAuth session of
        Just user ->
            ( { tab = Account user }, session, Nav.pushUrl session.navKey <| Route.toString Route.Auth )

        Nothing ->
            ( { tab = Signup User.emptySignupForm Dict.empty }, session, Cmd.none )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        -- Generic page updates
        CopyToClipboard accessToken ->
            ( model
            , session
            , Ports.copyToClipboard accessToken
            )

        -- Update db with detailed processes when we get them
        DetailedProcessesResponse (RemoteData.Success rawDetailedProcessesJson) ->
            ( model
            , session
                |> Session.updateDbProcesses rawDetailedProcessesJson
                |> Session.notifyInfo "Information" "Vous avez désormais accès aux impacts détaillés"
            , Nav.pushUrl session.navKey <| Route.toString Route.Auth
            )

        DetailedProcessesResponse (RemoteData.Failure error) ->
            ( model
            , session |> Session.notifyBackendError error
            , Cmd.none
            )

        -- Account tab initialisation: retrieve the latest user profile
        SwitchTab (Account auth) ->
            ( { model | tab = Account auth }
            , session
            , Auth.profile session (ProfileResponse auth.accessTokenData)
            )

        -- ApiTokens tab initialisation: retrieve the latest list of tokens
        SwitchTab (ApiTokens _) ->
            ( { model | tab = ApiTokens RemoteData.Loading }
            , session
            , ApiTokenHttp.list session ApiTokensResponse
            )

        -- Generic tab initialisation
        SwitchTab tab ->
            ( { model | tab = tab }, session, Cmd.none )

        -- Specific tab updates
        tabMsg ->
            case model.tab of
                Account auth ->
                    updateAccountTab session auth tabMsg model

                ApiTokenCreated _ ->
                    ( model, session, Cmd.none )

                ApiTokenDelete apiToken ->
                    updateApiTokenDeleteTab session apiToken tabMsg model

                ApiTokens apiTokens ->
                    updateApiTokensTab session apiTokens tabMsg model

                MagicLinkForm email ->
                    updateMagicLinkFormTab session email tabMsg model

                MagicLinkLogin ->
                    updateMagicLinkLoginTab session tabMsg model

                MagicLinkSent _ ->
                    ( model, session, Cmd.none )

                Signup signupForm _ ->
                    updateSignupTab session signupForm tabMsg model

                SignupCompleted _ ->
                    updateNothing session model


updateAccountTab : Session -> Session.Auth -> Msg -> Model -> ( Model, Session, Cmd Msg )
updateAccountTab session currentAuth msg model =
    case msg of
        Logout user ->
            ( model
            , session
            , user |> Auth.logout session LogoutResponse
            )

        LogoutResponse (RemoteData.Failure error) ->
            ( model
            , session
                |> Session.notifyBackendError error
                |> Session.logout
                |> Session.notifyInfo "Déconnexion" "Vous avez été deconnecté"
            , Cmd.none
            )

        LogoutResponse (RemoteData.Success _) ->
            ( model
            , session
                |> Session.logout
                |> Session.notifyInfo "Déconnexion" "Vous avez été deconnecté"
            , Nav.load <| Route.toString Route.Auth
            )

        ProfileResponse _ (RemoteData.Success user) ->
            ( { model | tab = Account { currentAuth | user = user } }
            , session |> Session.updateAuth (\auth2 -> { auth2 | user = user })
            , Cmd.none
            )

        ProfileResponse _ (RemoteData.Failure error) ->
            ( model
            , session |> Session.notifyBackendError error
            , Cmd.none
            )

        _ ->
            updateNothing session model


updateApiTokensTab : Session -> WebData (List CreatedToken) -> Msg -> Model -> ( Model, Session, Cmd Msg )
updateApiTokensTab session _ tabMsg model =
    case tabMsg of
        ApiTokensResponse newApiTokens ->
            ( { model | tab = ApiTokens newApiTokens }, session, Cmd.none )

        CreateToken ->
            ( model, session, ApiTokenHttp.create session CreateTokenResponse )

        CreateTokenResponse (RemoteData.Success createdToken) ->
            ( { model | tab = ApiTokenCreated createdToken }
            , session
            , ApiTokenHttp.list session ApiTokensResponse
            )

        CreateTokenResponse (RemoteData.Failure error) ->
            ( model, session |> Session.notifyBackendError error, Cmd.none )

        SwitchTab (ApiTokens _) ->
            ( model
            , session
            , ApiTokenHttp.list session ApiTokensResponse
            )

        _ ->
            updateNothing session model


updateApiTokenDeleteTab : Session -> CreatedToken -> Msg -> Model -> ( Model, Session, Cmd Msg )
updateApiTokenDeleteTab session _ msg model =
    case msg of
        DeleteApiToken apiToken ->
            ( model
            , session
            , ApiTokenHttp.delete session apiToken DeleteApiTokenResponse
            )

        DeleteApiTokenResponse (RemoteData.Success _) ->
            ( { model | tab = ApiTokens RemoteData.Loading }
            , session
                |> Session.notifyInfo "Jeton d'API supprimé" "Le jeton d'API a été supprimé avec succès"
            , ApiTokenHttp.list session ApiTokensResponse
            )

        DeleteApiTokenResponse (RemoteData.Failure error) ->
            ( model, session |> Session.notifyBackendError error, Cmd.none )

        _ ->
            updateNothing session model


updateMagicLinkFormTab : Session -> Email -> Msg -> Model -> ( Model, Session, Cmd Msg )
updateMagicLinkFormTab session email msg model =
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

        UpdateMagicLinkForm email_ ->
            ( { model | tab = MagicLinkForm email_ }
            , session
            , Cmd.none
            )

        _ ->
            updateNothing session model


updateMagicLinkLoginTab : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
updateMagicLinkLoginTab session msg model =
    case msg of
        LoginResponse (RemoteData.Success accessTokenData) ->
            ( { model | tab = MagicLinkLogin }
            , session
            , accessTokenData.accessToken
                |> Auth.profileFromAccessToken session (ProfileResponse accessTokenData)
            )

        LoginResponse (RemoteData.Failure error) ->
            ( model
            , session |> Session.notifyBackendError error
            , Nav.load <| Route.toString Route.Auth
            )

        ProfileResponse accessTokenData (RemoteData.Success user) ->
            let
                newSession =
                    session |> Session.setAuth (Just { accessTokenData = accessTokenData, user = user })
            in
            ( { model | tab = Account { accessTokenData = accessTokenData, user = user } }
            , newSession
            , Auth.processes newSession DetailedProcessesResponse
            )

        ProfileResponse _ (RemoteData.Failure error) ->
            ( model
            , session |> Session.notifyBackendError error
            , Nav.load <| Route.toString Route.Auth
            )

        _ ->
            updateNothing session model


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
                , session |> Session.clearNotifications
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
            updateNothing session model


updateNothing : Session -> Model -> ( Model, Session, Cmd Msg )
updateNothing session model =
    ( model, session, Cmd.none )


viewTab : Session -> Tab -> Html Msg
viewTab session currentTab =
    let
        ( heading, tabs ) =
            case Session.getAuth session of
                Just user ->
                    ( "Mon compte"
                    , [ ( "Compte", Account user )
                      , ( "Jetons d'API", ApiTokens RemoteData.Loading )
                      ]
                    )

                Nothing ->
                    ( "Connexion / Inscription"
                    , [ ( "Inscription", Signup User.emptySignupForm Dict.empty )
                      , ( "Connexion", MagicLinkForm "" )
                      ]
                    )
    in
    div []
        [ h1 [ class "mb-4" ] [ text heading ]
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

                    ApiTokenCreated token ->
                        viewApiTokenCreated token

                    ApiTokenDelete apiToken ->
                        viewApiTokenDelete apiToken

                    ApiTokens apiTokens ->
                        viewApiTokens apiTokens

                    MagicLinkForm email ->
                        viewMagicLinkForm email

                    MagicLinkLogin ->
                        Spinner.view

                    MagicLinkSent email ->
                        viewMagicLinkSent email

                    Signup signupForm formErrors ->
                        viewSignupForm signupForm formErrors

                    SignupCompleted email ->
                        viewMagicLinkSent email
                ]
            ]
        ]


viewAccount : Session.Auth -> Html Msg
viewAccount { user } =
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
          , Just ( "Organisation", viewOrganization user.profile.organization )
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


viewOrganization : User.Organization -> Html Msg
viewOrganization organization =
    case organization of
        User.Association name ->
            text <| "Association\u{00A0}: " ++ name

        User.Business name siren ->
            div []
                [ div [] [ text "Entreprise\u{00A0}: ", strong [] [ text name ] ]
                , div [] [ text <| "Siren\u{00A0}: " ++ User.sirenToString siren ]
                ]

        User.Education name ->
            text <| "Établissement\u{00A0}: " ++ name

        User.Individual ->
            text "Particulier"

        User.LocalAuthority name ->
            text <| "Collectivité\u{00A0}: " ++ name

        User.Media name ->
            text <| "Média\u{00A0}: " ++ name

        User.Public name ->
            text <| "Établissement public\u{00A0}: " ++ name


viewApiTokenCreated : Token -> Html Msg
viewApiTokenCreated token =
    div []
        [ h2 [ class "h5 mb-3" ]
            [ text "✅\u{00A0}Un nouveau jeton d'API a été créé" ]
        , p []
            [ text "Il vous permet d'effectuer des requêtes sur "
            , a [ Route.href Route.Api, target "_blank" ] [ text "l'API Ecobalyse" ]
            , text "."
            ]
        , """Attention, **ce jeton d'API ne vous sera affiché qu'une seule et unique fois ci-dessous**.
             Conservez-le précieusement."""
            |> Markdown.simple [ class "alert alert-warning d-flex align-items-center gap-1 mb-3" ]
        , div
            [ class "input-group" ]
            [ input
                [ type_ "url"
                , class "form-control"
                , value <| ApiToken.toString token
                ]
                []
            , button
                [ class "input-group-text"
                , title "Copier dans le presse-papiers"
                , onClick (CopyToClipboard <| ApiToken.toString token)
                ]
                [ Icon.clipboard
                ]
            ]
        , p [ class "fs-8 text-muted mt-1 mb-0" ]
            [ text "Vous pouvez copier le jeton d'API ci-dessus en cliquant sur le bouton copier à droite du champ."
            ]
        , div [ class "d-grid mt-2" ]
            [ button
                [ class "btn btn-link", onClick <| SwitchTab (ApiTokens RemoteData.Loading) ]
                [ text "«\u{00A0}Retour à la liste des jetons d'API" ]
            ]
        ]


viewApiTokens : WebData (List CreatedToken) -> Html Msg
viewApiTokens apiTokens =
    case apiTokens of
        RemoteData.Failure error ->
            p [ class "alert alert-danger" ]
                [ text <| "Erreur lors de la récupération des jetons d'API : " ++ BackendError.errorToString error ]

        RemoteData.Loading ->
            Spinner.view

        RemoteData.NotAsked ->
            text ""

        RemoteData.Success tokens ->
            div []
                [ if List.isEmpty tokens then
                    p [] [ text "Aucun jeton d'API actif." ]

                  else
                    div [ class "table-responsive border shadow-sm" ]
                        [ table [ class "table table-striped mb-0" ]
                            [ thead []
                                [ tr []
                                    [ th [] [ text "ID" ]
                                    , th [ class "text-end" ] [ text "Date de dernière utilisation" ]
                                    , th [ class "text-end" ] []
                                    ]
                                ]
                            , tokens
                                |> List.map
                                    (\apiToken ->
                                        tr []
                                            [ td [ class "align-middle" ] [ text apiToken.id ]
                                            , td [ class "align-middle text-end" ]
                                                [ apiToken.lastAccessedAt
                                                    |> Maybe.map Format.frenchDatetime
                                                    |> Maybe.withDefault "Jamais utilisé"
                                                    |> text
                                                ]
                                            , td [ class "align-middle text-end" ]
                                                [ button
                                                    [ class "btn btn-sm btn-danger"
                                                    , title "Supprimer ce jeton"
                                                    , onClick <| SwitchTab (ApiTokenDelete apiToken)
                                                    ]
                                                    [ Icon.trash ]
                                                ]
                                            ]
                                    )
                                |> tbody []
                            ]
                        ]
                , div [ class "d-grid mt-3" ]
                    [ button
                        [ class "btn btn-primary", onClick CreateToken ]
                        [ text "Créer un jeton d'API" ]
                    ]
                ]


viewApiTokenDelete : CreatedToken -> Html Msg
viewApiTokenDelete apiToken =
    div []
        [ h2 [ class "h5 mb-3" ] [ text "Supprimer et invalider ce jeton d'API" ]
        , p []
            [ """Êtes-vous sûr de vouloir supprimer et invalider ce jeton d'API\u{00A0}?
                 Vous ne pourrez plus l'utiliser."""
                |> Markdown.simple []
            ]
        , case apiToken.lastAccessedAt of
            Just lastAccessedAt ->
                p [ class "alert alert-warning d-flex align-items-center gap-1" ]
                    [ Icon.warning
                    , text "Dernière utilisation\u{00A0}:"
                    , text <| Format.frenchDatetime lastAccessedAt
                    ]

            Nothing ->
                p [ class "alert alert-success d-flex align-items-center gap-1" ]
                    [ Icon.info
                    , text "Le token n'a jamais été utilisé"
                    ]
        , div [ class "d-flex justify-content-center gap-2 mt-1" ]
            [ button
                [ class "btn btn-link", onClick <| SwitchTab (ApiTokens RemoteData.Loading) ]
                [ text "Annuler" ]
            , button
                [ class "btn btn-danger", onClick <| DeleteApiToken apiToken ]
                [ text "Supprimer et invalider ce jeton d'API" ]
            ]
        ]


viewMagicLinkForm : Email -> Html Msg
viewMagicLinkForm email =
    Html.form [ onSubmit MagicLinkSubmit ]
        [ p [ class "fs-8" ]
            [ """Si vous avez un compte, entrez votre adresse email ci-dessous pour recevoir un email
                 de connexion. Si vous n'en avez pas, vous pouvez [créer un compte]({url})."""
                |> String.replace "{url}" (Route.toString Route.AuthSignup)
                |> Markdown.simple []
            ]
        , div [ class "mb-3" ]
            [ label [ for "email", class "form-label" ]
                [ text "Adresse email" ]
            , input
                [ type_ "email"
                , class "form-control"
                , id "email"
                , placeholder "nom@example.com"
                , value email
                , onInput UpdateMagicLinkForm
                , required True
                ]
                []
            ]
        , div [ class "d-grid" ]
            [ button
                [ type_ "submit"
                , class "btn btn-primary"
                , disabled <| email == "" || User.validateEmailForm email /= Dict.empty
                ]
                [ text "Recevoir un email de connexion" ]
            ]
        ]


viewMagicLinkSent : Email -> Html msg
viewMagicLinkSent email =
    div [ class "alert alert-info mb-0" ]
        [ h2 [ class "h5" ] [ text "Email de connexion envoyé" ]
        , "Un email contenant un lien de connexion au service a été envoyé à l'adresse **`{email}`**."
            |> String.replace "{email}" email
            |> Markdown.simple []
        ]


viewSignupForm : SignupForm -> FormErrors -> Html Msg
viewSignupForm signupForm formErrors =
    Html.form [ onSubmit SignupSubmit ]
        [ p [ class "fs-8" ]
            [ text "Sauf mention contraire, tous les champs sont obligatoires." ]
        , div [ class "mb-3" ]
            [ label [ for "email", class "form-label" ]
                [ text "Adresse email" ]
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
        , viewOrganizationForm signupForm formErrors
        , div [ class "mb-3 form-check" ]
            [ input
                [ type_ "checkbox"
                , class "form-check-input"
                , classList [ ( "is-invalid", Dict.member "emailOptin" formErrors ) ]
                , id "emailOptin"
                , checked signupForm.emailOptin
                , onCheck <| \emailOptin -> UpdateSignupForm { signupForm | emailOptin = emailOptin }
                ]
                []
            , label [ class "form-check-label", for "emailOptin" ]
                [ text "J’accepte de recevoir des informations de la part d'Ecobalyse par email."
                ]
            , viewFieldError "termsAccepted" formErrors
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
                , text ", et suis informé(e) que cette utilisation ne peut se faire que dans le cadre de la vente de produits sur le marché français."
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


viewOrganizationForm : SignupForm -> FormErrors -> Html Msg
viewOrganizationForm signupForm formErrors =
    div [ class "row" ]
        [ div [ class "col-md-6" ]
            [ div [ class "mb-3" ]
                [ label [ for "organizationType", class "form-label" ]
                    [ text "Type d'organisation" ]
                , User.organizationTypes
                    |> List.map
                        (\( code, label ) ->
                            option
                                [ value code
                                , selected <| code == User.organizationTypeToString signupForm.organization
                                ]
                                [ text label ]
                        )
                    |> select
                        [ class "form-select"
                        , id "organizationType"
                        , onInput
                            (\type_ ->
                                UpdateSignupForm
                                    { signupForm
                                        | organization =
                                            signupForm.organization
                                                |> User.updateOrganizationType type_
                                    }
                            )
                        ]
                , viewFieldError "organization.type" formErrors
                ]
            ]
        , if signupForm.organization == User.Individual then
            text ""

          else
            div [ class "col-md-6" ]
                [ div [ class "mb-3" ]
                    [ label [ for "organization", class "form-label" ]
                        [ text "Nom de l'organisation" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , classList [ ( "is-invalid", Dict.member "organization.name" formErrors ) ]
                        , id "organization"
                        , placeholder "ACME Inc."
                        , User.getOrganizationName signupForm.organization
                            |> Maybe.withDefault ""
                            |> value
                        , onInput <|
                            \name ->
                                UpdateSignupForm
                                    { signupForm
                                        | organization =
                                            signupForm.organization
                                                |> User.updateOrganizationName name
                                    }
                        , required True
                        ]
                        []
                    , viewFieldError "organization.name" formErrors
                    ]
                ]
        , case signupForm.organization of
            User.Business _ siren ->
                div [ class "d-grid mb-3" ]
                    [ label [ for "siren", class "form-label" ]
                        [ text "Numéro SIREN" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , classList [ ( "is-invalid", Dict.member "organization.siren" formErrors ) ]
                        , id "siren"
                        , placeholder "123456789"
                        , value <| User.sirenToString siren
                        , onInput <|
                            \newSiren ->
                                UpdateSignupForm
                                    { signupForm
                                        | organization =
                                            signupForm.organization
                                                |> User.updateOrganizationSiren newSiren
                                    }
                        , required True
                        ]
                        []
                    , viewFieldError "organization.siren" formErrors
                    , p [ class "fs-8 text-muted mt-1 mb-0" ]
                        [ text "Vous pouvez rechercher le numéro SIREN à 9 chiffres d'une entreprise sur le "
                        , a [ href "https://annuaire-entreprises.data.gouv.fr/", target "_blank" ]
                            [ text "service d'annuaire des entreprises data.gouv.fr" ]
                        ]
                    ]

            _ ->
                text ""
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

        ( ApiTokens _, ApiTokenCreated _ ) ->
            True

        ( ApiTokens _, ApiTokenDelete _ ) ->
            True

        ( ApiTokenDelete _, ApiTokens _ ) ->
            True

        ( ApiTokenCreated _, ApiTokens _ ) ->
            True

        ( MagicLinkLogin, MagicLinkForm _ ) ->
            True

        ( MagicLinkForm _, MagicLinkLogin ) ->
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
