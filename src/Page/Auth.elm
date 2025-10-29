module Page.Auth exposing
    ( Model
    , Msg(..)
    , init
    , initLogin
    , initSignup
    , update
    , view
    )

import App exposing (PageUpdate)
import Browser.Navigation as Nav
import Data.ApiToken as ApiToken exposing (CreatedToken, Token)
import Data.Env as Env
import Data.Plausible as Plausible
import Data.Session as Session exposing (Session)
import Data.User as User exposing (AccessTokenData, FormErrors, ProfileForm, SignupForm, User)
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
import Url
import Views.Alert as Alert
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
    | MagicLinkLoginConfirm
    | MagicLinkResponse (WebData ())
    | MagicLinkSubmit
    | ProfileResponse { updated : Bool } AccessTokenData (WebData User)
    | ProfileSubmit
    | SignupResponse (WebData User)
    | SignupSubmit
    | SwitchTab Tab
    | UpdateMagicLinkForm Email
    | UpdateProfileForm ProfileForm
    | UpdateSignupForm SignupForm


type Tab
    = Account Session.Auth ProfileForm FormErrors
    | ApiTokenCreated Token
    | ApiTokenDelete CreatedToken
    | ApiTokens (WebData (List CreatedToken))
    | MagicLinkForm Email (WebData ())
    | MagicLinkLogin Email AccessToken
    | MagicLinkSent Email
    | Signup SignupForm FormErrors (WebData ())
    | SignupCompleted Email


init : Session -> PageUpdate Model Msg
init session =
    case Session.getAuth session of
        Just auth ->
            { tab = Account auth User.emptyProfileForm Dict.empty }
                |> App.createUpdate session
                |> App.withCmds
                    [ Auth.profile session (ProfileResponse { updated = False } auth.accessTokenData)
                    , ApiTokenHttp.list session ApiTokensResponse
                    ]

        Nothing ->
            { tab = MagicLinkForm "" RemoteData.NotAsked }
                |> App.createUpdate session


{-| Init page when we receive magic link information
-}
initLogin : Session -> Email -> AccessToken -> PageUpdate Model Msg
initLogin session email token =
    App.createUpdate session { tab = MagicLinkLogin email token }


initSignup : Session -> PageUpdate Model Msg
initSignup session =
    case Session.getAuth session of
        Just user ->
            { tab = Account user User.emptyProfileForm Dict.empty }
                |> App.createUpdate session
                |> App.withCmds [ Nav.pushUrl session.navKey <| Route.toString Route.Auth ]

        Nothing ->
            { tab = Signup User.emptySignupForm Dict.empty RemoteData.NotAsked }
                |> App.createUpdate session


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        -- Generic page updates
        CopyToClipboard accessToken ->
            App.createUpdate session model
                |> App.withCmds [ Ports.copyToClipboard accessToken ]
                |> App.notifyInfo "Le jeton d'API a été copié dans le presse-papiers"

        -- Update db with detailed processes when we get them
        DetailedProcessesResponse (RemoteData.Success rawDetailedProcessesJson) ->
            model
                |> App.createUpdate (session |> Session.updateDbProcesses rawDetailedProcessesJson)
                |> App.withCmds [ Nav.pushUrl session.navKey <| Route.toString Route.Auth ]
                |> App.notifyInfo "Vous avez désormais accès aux impacts détaillés"
                |> App.withCmds [ Plausible.send Plausible.AuthLoginOK ]

        DetailedProcessesResponse (RemoteData.Failure error) ->
            model
                |> App.createUpdate (session |> Session.notifyBackendError error)

        -- Account tab initialisation: retrieve the latest user profile
        SwitchTab (Account auth _ _) ->
            { model | tab = Account auth User.emptyProfileForm Dict.empty }
                |> App.createUpdate session
                |> App.withCmds [ Auth.profile session (ProfileResponse { updated = False } auth.accessTokenData) ]

        -- ApiTokens tab initialisation: retrieve the latest list of tokens
        SwitchTab (ApiTokens _) ->
            { model | tab = ApiTokens RemoteData.Loading }
                |> App.createUpdate session
                |> App.withCmds [ ApiTokenHttp.list session ApiTokensResponse ]

        -- Generic tab initialisation
        SwitchTab tab ->
            { model | tab = tab }
                |> App.createUpdate session

        -- Specific tab updates
        tabMsg ->
            case model.tab of
                Account auth profileForm formErrors ->
                    updateAccountTab session auth profileForm formErrors tabMsg model

                ApiTokenCreated _ ->
                    App.createUpdate session model

                ApiTokenDelete apiToken ->
                    updateApiTokenDeleteTab session apiToken tabMsg model

                ApiTokens apiTokens ->
                    updateApiTokensTab session apiTokens tabMsg model

                MagicLinkForm email webData ->
                    updateMagicLinkFormTab session email webData tabMsg model

                MagicLinkLogin email token ->
                    updateMagicLinkLoginTab session email token tabMsg model

                MagicLinkSent _ ->
                    App.createUpdate session model
                        |> App.withCmds [ Plausible.send Plausible.AuthMagicLinkSent ]

                Signup signupForm _ webData ->
                    updateSignupTab session signupForm webData tabMsg model

                SignupCompleted _ ->
                    updateNothing session model


updateAccountTab : Session -> Session.Auth -> ProfileForm -> FormErrors -> Msg -> Model -> PageUpdate Model Msg
updateAccountTab session currentAuth profileForm _ msg model =
    case msg of
        Logout user ->
            model
                |> App.createUpdate session
                |> App.withCmds [ user |> Auth.logout session LogoutResponse ]

        LogoutResponse (RemoteData.Failure error) ->
            model
                |> App.createUpdate
                    (session
                        -- FIXME: what to do with backend errors?
                        |> Session.notifyBackendError error
                        |> Session.logout
                    )
                |> App.notifyInfo "Vous avez été deconnecté"

        LogoutResponse (RemoteData.Success _) ->
            model
                |> App.createUpdate session
                |> App.mapSession Session.logout
                |> App.notifyInfo "Vous avez été deconnecté"
                |> App.withCmds [ Nav.load <| Route.toString Route.Auth ]

        ProfileResponse { updated } _ (RemoteData.Success user) ->
            App.createUpdate session
                { model
                    | tab =
                        Account { currentAuth | user = user }
                            { emailOptin = user.profile.emailOptin
                            , firstName = user.profile.firstName
                            , lastName = user.profile.lastName
                            }
                            Dict.empty
                }
                |> App.mapSession (Session.updateAuth (\auth -> { auth | user = user }))
                |> App.notifyInfoIf updated "Votre profil a été mis à jour avec succès"
                |> App.withCmds
                    [ if updated then
                        Plausible.send Plausible.AuthProfileUpdated

                      else
                        Cmd.none
                    ]

        ProfileResponse _ _ (RemoteData.Failure error) ->
            if (BackendError.mapErrorResponse error |> .statusCode) == 401 then
                { model | tab = MagicLinkForm "" RemoteData.NotAsked }
                    |> App.createUpdate session
                    |> App.mapSession Session.logout
                    |> App.notifyInfo "Session invalide ou expirée, vous avez été deconnecté. Vous devrez vous reconnecter."

            else
                model
                    |> App.createUpdate (session |> Session.notifyBackendError error)

        ProfileSubmit ->
            let
                newFormErrors =
                    User.validateProfileForm profileForm

                newModel =
                    { model | tab = Account currentAuth profileForm newFormErrors }
            in
            if newFormErrors == Dict.empty then
                newModel
                    |> App.createUpdate (session |> Session.clearNotifications)
                    |> App.withCmds
                        [ profileForm
                            |> Auth.updateProfile session (ProfileResponse { updated = True } currentAuth.accessTokenData)
                        ]

            else
                newModel
                    |> App.createUpdate session
                    |> App.notifyError "Erreur de sauvegarde" "Veuillez corriger les champs en erreur"

        UpdateProfileForm profileForm_ ->
            { model | tab = Account currentAuth profileForm_ Dict.empty }
                |> App.createUpdate session

        _ ->
            updateNothing session model


updateApiTokensTab : Session -> WebData (List CreatedToken) -> Msg -> Model -> PageUpdate Model Msg
updateApiTokensTab session _ tabMsg model =
    case tabMsg of
        ApiTokensResponse newApiTokens ->
            { model | tab = ApiTokens newApiTokens }
                |> App.createUpdate session

        CreateToken ->
            model
                |> App.createUpdate session
                |> App.withCmds [ ApiTokenHttp.create session CreateTokenResponse ]

        CreateTokenResponse (RemoteData.Success createdToken) ->
            { model | tab = ApiTokenCreated createdToken }
                |> App.createUpdate session
                |> App.withCmds
                    [ ApiTokenHttp.list session ApiTokensResponse
                    , Plausible.send Plausible.AuthApiTokenCreated
                    ]

        CreateTokenResponse (RemoteData.Failure error) ->
            model
                |> App.createUpdate (session |> Session.notifyBackendError error)

        SwitchTab (ApiTokens _) ->
            { model | tab = ApiTokens RemoteData.Loading }
                |> App.createUpdate session
                |> App.withCmds [ ApiTokenHttp.list session ApiTokensResponse ]

        _ ->
            updateNothing session model


updateApiTokenDeleteTab : Session -> CreatedToken -> Msg -> Model -> PageUpdate Model Msg
updateApiTokenDeleteTab session _ msg model =
    case msg of
        DeleteApiToken apiToken ->
            model
                |> App.createUpdate session
                |> App.withCmds [ ApiTokenHttp.delete session apiToken DeleteApiTokenResponse ]

        DeleteApiTokenResponse (RemoteData.Success _) ->
            { model | tab = ApiTokens RemoteData.Loading }
                |> App.createUpdate session
                |> App.notifySuccess "Le jeton d'API a été supprimé"
                |> App.withCmds [ ApiTokenHttp.list session ApiTokensResponse ]

        DeleteApiTokenResponse (RemoteData.Failure error) ->
            model
                |> App.createUpdate (session |> Session.notifyBackendError error)

        _ ->
            updateNothing session model


updateMagicLinkFormTab : Session -> Email -> WebData () -> Msg -> Model -> PageUpdate Model Msg
updateMagicLinkFormTab session email webData msg model =
    case msg of
        MagicLinkResponse (RemoteData.Success _) ->
            { model | tab = MagicLinkSent email }
                |> App.createUpdate session

        MagicLinkResponse (RemoteData.Failure error) ->
            model
                |> App.createUpdate (session |> Session.notifyBackendError error)

        MagicLinkSubmit ->
            { model | tab = MagicLinkForm email RemoteData.Loading }
                |> App.createUpdate session
                |> App.withCmds [ String.trim email |> Auth.askMagicLink session MagicLinkResponse ]

        UpdateMagicLinkForm email_ ->
            { model | tab = MagicLinkForm email_ webData }
                |> App.createUpdate session

        _ ->
            updateNothing session model


updateMagicLinkLoginTab : Session -> Email -> AccessToken -> Msg -> Model -> PageUpdate Model Msg
updateMagicLinkLoginTab session email token msg model =
    case msg of
        LoginResponse (RemoteData.Success accessTokenData) ->
            { model | tab = MagicLinkLogin email token }
                |> App.createUpdate session
                |> App.withCmds
                    [ accessTokenData.accessToken
                        |> Auth.profileFromAccessToken session (ProfileResponse { updated = False } accessTokenData)
                    ]

        LoginResponse (RemoteData.Failure error) ->
            model
                |> App.createUpdate
                    (if Session.isAuthenticated session && (BackendError.mapErrorResponse error |> .statusCode) == 403 then
                        -- An authenticated user is most likely trying to reuse a single-use magic link,
                        -- maybe to access the service via a bookmark or a pinned email: do nothing
                        session

                     else
                        session |> Session.notifyBackendError error
                    )
                |> App.withCmds [ Nav.load <| Route.toString Route.Auth ]

        MagicLinkLoginConfirm ->
            model
                |> App.createUpdate session
                |> App.withCmds [ Auth.login session LoginResponse email token ]

        ProfileResponse _ accessTokenData (RemoteData.Success user) ->
            let
                newSession =
                    session |> Session.setAuth (Just { accessTokenData = accessTokenData, user = user })
            in
            { model
                | tab =
                    Account { accessTokenData = accessTokenData, user = user }
                        User.emptyProfileForm
                        Dict.empty
            }
                |> App.createUpdate newSession
                |> App.withCmds [ Auth.processes newSession DetailedProcessesResponse ]

        ProfileResponse _ _ (RemoteData.Failure error) ->
            model
                |> App.createUpdate (session |> Session.notifyBackendError error)
                |> App.withCmds [ Nav.load <| Route.toString Route.Auth ]

        _ ->
            updateNothing session model


updateSignupTab : Session -> SignupForm -> WebData () -> Msg -> Model -> PageUpdate Model Msg
updateSignupTab session signupForm webData msg model =
    case msg of
        SignupResponse (RemoteData.Success _) ->
            { model | tab = SignupCompleted signupForm.email }
                |> App.createUpdate session
                |> App.withCmds [ Plausible.send Plausible.AuthSignup ]

        SignupResponse (RemoteData.Failure error) ->
            { model | tab = Signup signupForm Dict.empty RemoteData.NotAsked }
                |> App.createUpdate (session |> Session.notifyBackendError error)

        SignupSubmit ->
            let
                newFormErrors =
                    User.validateSignupForm signupForm
            in
            if newFormErrors == Dict.empty then
                { model | tab = Signup signupForm newFormErrors RemoteData.Loading }
                    |> App.createUpdate (session |> Session.clearNotifications)
                    |> App.withCmds [ Auth.signup session SignupResponse signupForm ]

            else
                { model | tab = Signup signupForm newFormErrors RemoteData.NotAsked }
                    |> App.createUpdate session
                    |> App.notifyError "Erreur de sauvegarde" "Veuillez corriger les champs en erreur"

        UpdateSignupForm signupForm_ ->
            { model | tab = Signup signupForm_ Dict.empty webData }
                |> App.createUpdate session

        _ ->
            updateNothing session model


updateNothing : Session -> Model -> PageUpdate Model Msg
updateNothing session model =
    App.createUpdate session model


viewTab : Session -> Tab -> Html Msg
viewTab session currentTab =
    let
        ( heading, tabs ) =
            case Session.getAuth session of
                Just user ->
                    ( "Mon compte"
                    , [ ( "Compte", Account user User.emptyProfileForm Dict.empty )
                      , ( "Jetons d'API", ApiTokens RemoteData.Loading )
                      ]
                    )

                Nothing ->
                    ( "Connexion / Inscription"
                    , [ ( "Inscription", Signup User.emptySignupForm Dict.empty RemoteData.NotAsked )
                      , ( "Connexion", MagicLinkForm "" RemoteData.NotAsked )
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
                    Account auth profileForm formErrors ->
                        viewAccount auth profileForm formErrors

                    ApiTokenCreated token ->
                        viewApiTokenCreated token

                    ApiTokenDelete apiToken ->
                        viewApiTokenDelete apiToken

                    ApiTokens apiTokens ->
                        viewApiTokens apiTokens

                    MagicLinkForm email webData ->
                        viewMagicLinkForm email webData

                    MagicLinkLogin email _ ->
                        viewMagicLinkLogin email

                    MagicLinkSent email ->
                        viewMagicLinkSent email

                    Signup signupForm formErrors webData ->
                        viewSignupForm signupForm formErrors webData

                    SignupCompleted email ->
                        viewMagicLinkSent email
                ]
            ]
        ]


viewAccount : Session.Auth -> ProfileForm -> FormErrors -> Html Msg
viewAccount { user } profileForm formErrors =
    div []
        [ Html.form [ onSubmit ProfileSubmit, class "mt-3" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 mb-3" ]
                    [ label [ for "email", class "form-label" ]
                        [ text "Adresse email" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , id "email"
                        , placeholder "nom@example.com"
                        , value user.email
                        , disabled True
                        ]
                        []
                    , small [ class "d-flex align-items-center gap-1 text-muted" ]
                        [ Icon.info, text "Vous ne pouvez pas encore modifier votre email" ]
                    ]
                , div [ class "col-md-6  mb-3" ]
                    [ div [ class "form-label" ] [ text "Organisation" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , id "organization"
                        , placeholder "ACME Inc."
                        , value <| viewOrganization user.profile.organization
                        , disabled True
                        ]
                        []
                    , small [ class "d-flex align-items-center gap-1 text-muted" ]
                        [ Icon.info, text "Vous ne pouvez pas modifier votre organisation" ]
                    ]
                ]
            , div [ class "row" ]
                [ div [ class "col-md-6 mb-3" ]
                    [ label [ for "firstName", class "form-label" ]
                        [ text "Prénom" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , classList [ ( "is-invalid", Dict.member "firstName" formErrors ) ]
                        , id "firstName"
                        , placeholder "Joséphine"
                        , value profileForm.firstName
                        , onInput <| \firstName -> UpdateProfileForm { profileForm | firstName = firstName }
                        , required True
                        ]
                        []
                    , viewFieldError "firstName" formErrors
                    ]
                , div [ class "col-md-6 mb-3" ]
                    [ label [ for "lastName", class "form-label" ]
                        [ text "Nom" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , classList [ ( "is-invalid", Dict.member "lastName" formErrors ) ]
                        , id "lastName"
                        , placeholder "Durand"
                        , value profileForm.lastName
                        , onInput <| \lastName -> UpdateProfileForm { profileForm | lastName = lastName }
                        , required True
                        ]
                        []
                    , viewFieldError "lastName" formErrors
                    ]
                ]
            , div [ class "mb-3 form-check" ]
                [ input
                    [ type_ "checkbox"
                    , class "form-check-input"
                    , classList [ ( "is-invalid", Dict.member "emailOptin" formErrors ) ]
                    , id "emailOptin"
                    , checked profileForm.emailOptin
                    , onCheck <| \emailOptin -> UpdateProfileForm { profileForm | emailOptin = emailOptin }
                    ]
                    []
                , label [ class "form-check-label", for "emailOptin" ]
                    [ text "J’accepte de recevoir des informations de la part d'Ecobalyse par email."
                    ]
                , viewFieldError "termsAccepted" formErrors
                ]
            , div [ class "d-grid" ]
                [ button
                    [ type_ "submit"
                    , class "btn btn-primary"
                    , disabled <| profileForm == User.emptyProfileForm || formErrors /= Dict.empty
                    , attribute "data-testid" "auth-signup-submit"
                    ]
                    [ text "Mettre à jour mes informations" ]
                ]
            ]
        , hr [ class "mt-3 mb-0" ] []
        , div [ class "d-flex justify-content-center align-items-center gap-3" ]
            [ a [ Route.href Route.Home ]
                [ text "Retour à l'accueil" ]
            , button
                [ type_ "button"
                , class "btn btn-primary my-3"
                , onClick <| Logout user
                ]
                [ text "Déconnexion" ]
            ]
        ]


viewOrganization : User.Organization -> String
viewOrganization organization =
    case organization of
        User.Association name ->
            "Association\u{00A0}: " ++ name

        User.Business name siren ->
            "Entreprise\u{00A0}: " ++ name ++ "(" ++ User.sirenToString siren ++ ")"

        User.Education name ->
            "Établissement\u{00A0}: " ++ name

        User.Individual ->
            "Particulier"

        User.LocalAuthority name ->
            "Collectivité\u{00A0}: " ++ name

        User.Media name ->
            "Média\u{00A0}: " ++ name

        User.Public name ->
            "Établissement public\u{00A0}: " ++ name

        User.Student name ->
            "Étudiant·e\u{00A0}: " ++ name


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
                [ type_ "text"
                , class "form-control"
                , attribute "data-testid" "auth-api-token"
                , readonly True
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
                    div [ class "table-responsive border shadow-sm", attribute "data-testid" "auth-api-tokens-table" ]
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
                    , text "Dernière utilisation\u{00A0}:\u{00A0}"
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


viewV6Alert : Html Msg
viewV6Alert =
    Alert.simple
        { attributes = []
        , close = Nothing
        , content =
            [ """ Depuis le **2 juillet 2025** et la mise en ligne de la version 6.0.0,
                      **les comptes précédemment existants ont été supprimés**. Vous devez
                      **[recréer un nouveau compte]({url})**.
                  """
                |> String.replace "{url}" (Route.toString Route.AuthSignup)
                |> Markdown.simple []
            ]
        , level = Alert.Info
        , title = Nothing
        }


viewMagicLinkForm : Email -> WebData () -> Html Msg
viewMagicLinkForm email webData =
    div [ class "d-flex flex-column gap-3" ]
        [ viewV6Alert
        , Html.form
            [ onSubmit MagicLinkSubmit
            , attribute "data-testid" "auth-magic-link-form"
            ]
            [ p []
                [ text """ En revanche, si vous avez créé un compte depuis cette date, vous pouvez
                           recevoir un lien de connexion en soumettant votre adresse email ci-dessous.
                       """
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
                    , disabled <| email == "" || User.validateEmailForm email /= Dict.empty || webData == RemoteData.Loading
                    , attribute "data-testid" "auth-magic-link-submit"
                    ]
                    [ text <|
                        case webData of
                            RemoteData.Loading ->
                                "Email de connexion en cours d’envoi…"

                            _ ->
                                "Recevoir un email de connexion"
                    ]
                ]
            ]
        ]


viewMagicLinkLogin : Email -> Html Msg
viewMagicLinkLogin email =
    Html.form
        [ class "d-flex flex-column justify-content-center p-3"
        , onSubmit MagicLinkLoginConfirm
        ]
        [ p [ class "d-flex align-items-baseline gap-1" ]
            [ Icon.info
            , text "Vous allez être connecté avec l'adresse email suivante\u{00A0}: "
            , strong [] [ email |> Url.percentDecode |> Maybe.withDefault email |> text ]
            ]
        , button
            [ type_ "submit"
            , attribute "data-testid" "auth-login-confirm"
            , class "btn btn-primary"
            ]
            [ text "Confirmer la connexion"
            ]
        ]


viewMagicLinkSent : Email -> Html msg
viewMagicLinkSent email =
    Alert.simple
        { attributes = []
        , close = Nothing
        , content =
            [ "Si vous possédez un compte, un email contenant un lien de connexion au service a été envoyé à l'adresse **`{email}`**."
                |> String.replace "{email}" email
                |> Markdown.simple []
            ]
        , level = Alert.Info
        , title = Just "Email de connexion envoyé"
        }


viewSignupForm : SignupForm -> FormErrors -> WebData () -> Html Msg
viewSignupForm signupForm formErrors webData =
    Html.form
        [ onSubmit SignupSubmit
        , attribute "data-testid" "auth-signup-form"
        ]
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
                , disabled <| signupForm == User.emptySignupForm || formErrors /= Dict.empty || webData == RemoteData.Loading
                , attribute "data-testid" "auth-signup-submit"
                ]
                [ text <|
                    case webData of
                        RemoteData.Loading ->
                            "Envoi de la demande d’inscription en cours…"

                        _ ->
                            "Valider mon inscription"
                ]
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
                    |> List.sortBy Tuple.second
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
        ( Account _ _ _, Account _ _ _ ) ->
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

        ( MagicLinkLogin _ _, MagicLinkForm _ _ ) ->
            True

        ( MagicLinkForm _ _, MagicLinkLogin _ _ ) ->
            True

        ( MagicLinkForm _ _, MagicLinkForm _ _ ) ->
            True

        ( MagicLinkForm _ _, MagicLinkSent _ ) ->
            True

        ( MagicLinkSent _, MagicLinkForm _ _ ) ->
            True

        ( Signup _ _ _, Signup _ _ _ ) ->
            True

        ( Signup _ _ _, SignupCompleted _ ) ->
            True

        ( SignupCompleted _, Signup _ _ _ ) ->
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
