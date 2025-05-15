module Page.Auth2 exposing (Model, Msg(..), init, update, view)

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


type alias Model =
    { tab : Tab
    }


type Msg
    = SignupResponse (Result Http.Error User)
    | SignupSubmit
    | SwitchTab Tab
    | UpdateEmail String
    | UpdateFirstName String
    | UpdateLastName String
    | UpdateOrganization String
    | UpdateTermsAccepted Bool


type Tab
    = Login
    | Signup SignupForm FormErrors
    | SignupCompleted String


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { tab = Signup User.emptySignupForm Dict.empty
      }
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case ( model.tab, msg ) of
        ( Login, _ ) ->
            ( model, session, Cmd.none )

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

        ( Signup signupForm formErrors, UpdateEmail email ) ->
            ( { model | tab = Signup { signupForm | email = email } formErrors }
            , session
            , Cmd.none
            )

        ( Signup signupForm formErrors, UpdateFirstName firstName ) ->
            ( { model | tab = Signup { signupForm | firstName = firstName } formErrors }
            , session
            , Cmd.none
            )

        ( Signup signupForm formErrors, UpdateLastName lastName ) ->
            ( { model | tab = Signup { signupForm | lastName = lastName } formErrors }
            , session
            , Cmd.none
            )

        ( Signup signupForm formErrors, UpdateOrganization organization ) ->
            ( { model | tab = Signup { signupForm | organization = organization } formErrors }
            , session
            , Cmd.none
            )

        ( Signup signupForm formErrors, UpdateTermsAccepted termsAccepted ) ->
            ( { model | tab = Signup { signupForm | termsAccepted = termsAccepted } formErrors }
            , session
            , Cmd.none
            )

        ( SignupCompleted _, _ ) ->
            ( model, session, Cmd.none )

        ( _, SwitchTab tab ) ->
            ( { model | tab = tab }, session, Cmd.none )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Connexion / Inscription"
    , [ Container.centered [ class "pb-5" ]
            [ div [ class "row" ]
                [ div [ class "col-lg-10 offset-lg-1 col-xl-8 offset-xl-2 d-flex flex-column gap-3" ]
                    [ h1 []
                        [ text "Connexion / Inscription"
                        ]
                    , viewTab model.tab
                    ]
                ]
            ]
      ]
    )


isActiveTab : Tab -> Tab -> Bool
isActiveTab tab1 tab2 =
    case ( tab1, tab2 ) of
        ( Signup _ _, Signup _ _ ) ->
            True

        ( Signup _ _, SignupCompleted _ ) ->
            True

        ( Login, Login ) ->
            True

        _ ->
            False


viewTab : Tab -> Html Msg
viewTab currentTab =
    div [ class "card shadow-sm px-0" ]
        [ div [ class "card-header px-0 pb-0 border-bottom-0" ]
            [ ul [ class "Tabs nav nav-tabs nav-fill justify-content-end gap-2 px-2" ]
                ([ ( "Inscription", Signup User.emptySignupForm Dict.empty )
                 , ( "Connexion", Login )
                 ]
                    |> List.map
                        (\( label, tab ) ->
                            li
                                [ class "TabsTab nav-item"
                                , classList [ ( "active", isActiveTab tab currentTab ) ]
                                ]
                                [ button
                                    [ class "nav-link no-outline border-top-0"
                                    , classList [ ( "active", currentTab == tab ) ]
                                    , onClick (SwitchTab tab)
                                    ]
                                    [ text label ]
                                ]
                        )
                )
            ]
        , div [ class "card-body" ]
            [ case currentTab of
                Login ->
                    text "TODO login form"

                Signup signupForm formErrors ->
                    viewSignupForm signupForm formErrors

                SignupCompleted email ->
                    viewSignupCompleted email
            ]
        ]


viewSignupCompleted : String -> Html Msg
viewSignupCompleted email =
    div []
        [ h3 [] [ text "Inscription réussie" ]
        , p [] [ text <| "Un email de confirmation a été envoyé à l'adresse " ++ email ]
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
                , onInput UpdateEmail
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
                        , onInput UpdateFirstName
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
                        , onInput UpdateLastName
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
                , onInput UpdateOrganization
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
                , onCheck UpdateTermsAccepted
                , required True
                ]
                []
            , label [ class "form-check-label", for "termsAccepted" ]
                [ text "J'accepte les conditions d'utilisation du service" ]
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
