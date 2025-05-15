module Page.Auth2 exposing (Model, Msg(..), init, update, view)

import Data.Session as Session exposing (Session)
import Data.User2 as User exposing (SignupForm, User)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Regex
import Request.Auth2 as Auth
import Request.Common as RequestCommon
import Views.Container as Container


type alias Model =
    { signupFormErrors : FormErrors
    , signupForm : SignupForm
    }


type Msg
    = SignupResponse (Result Http.Error User)
    | SignupSubmitted
    | UpdateEmail String
    | UpdateFirstName String
    | UpdateLastName String
    | UpdateOrganization String
    | UpdateTermsAccepted Bool


type alias FormErrors =
    Dict String String


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { signupFormErrors = Dict.empty
      , signupForm = User.emptySignupForm
      }
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        SignupResponse (Ok _) ->
            ( model
            , session
                -- TODO: update session with user info
                -- |> Session.authenticated user
                -- TODO: redirect to page saying "Un email de confirmation vous a été envoyé."
                |> Session.notifyInfo "Inscription réussie" "Un email de confirmation vous a été envoyé."
            , Cmd.none
            )

        SignupResponse (Err error) ->
            ( model
            , session
                |> Session.notifyError "Erreur lors de l'inscription" (RequestCommon.errorToString error)
            , Cmd.none
            )

        SignupSubmitted ->
            ( model
            , session
            , Auth.signup session SignupResponse model.signupForm
            )

        UpdateEmail email ->
            model |> updateForm session (\form -> { form | email = email })

        UpdateFirstName firstName ->
            model |> updateForm session (\form -> { form | firstName = firstName })

        UpdateLastName lastName ->
            model |> updateForm session (\form -> { form | lastName = lastName })

        UpdateOrganization organization ->
            model |> updateForm session (\form -> { form | organization = organization })

        UpdateTermsAccepted termsAccepted ->
            model |> updateForm session (\form -> { form | termsAccepted = termsAccepted })


updateForm : Session -> (SignupForm -> SignupForm) -> Model -> ( Model, Session, Cmd Msg )
updateForm session transform model =
    let
        newSignupForm =
            transform model.signupForm
    in
    ( { model
        | signupForm = newSignupForm
        , signupFormErrors = validateForm newSignupForm
      }
    , session
    , Cmd.none
    )


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "Inscription"
    , [ Container.centered [ class "mb-5" ]
            [ div [ class "row justify-content-center" ]
                [ div [ class "col-md-8 col-lg-6" ]
                    [ div [ class "card shadow" ]
                        [ div [ class "card-header" ]
                            [ h2 [ class "card-title h5 mb-0" ]
                                [ text "Créer un compte" ]
                            ]
                        , div [ class "card-body" ]
                            [ viewSignupForm model ]
                        ]
                    ]
                ]
            ]
      ]
    )


viewSignupForm : Model -> Html Msg
viewSignupForm { signupForm, signupFormErrors } =
    Html.form [ onSubmit SignupSubmitted ]
        [ div [ class "mb-3" ]
            [ label [ for "email", class "form-label" ]
                [ text "Email" ]
            , input
                [ type_ "email"
                , class "form-control"
                , classList [ ( "is-invalid", Dict.member "email" signupFormErrors ) ]
                , id "email"
                , placeholder "nom@example.com"
                , value signupForm.email
                , onInput UpdateEmail
                , required True
                ]
                []
            , viewFieldError "email" signupFormErrors
            ]
        , div [ class "row" ]
            [ div [ class "col-md-6" ]
                [ div [ class "mb-3" ]
                    [ label [ for "firstName", class "form-label" ]
                        [ text "Prénom" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , classList [ ( "is-invalid", Dict.member "firstName" signupFormErrors ) ]
                        , id "firstName"
                        , placeholder "Joséphine"
                        , value signupForm.firstName
                        , onInput UpdateFirstName
                        , required True
                        ]
                        []
                    , viewFieldError "firstName" signupFormErrors
                    ]
                ]
            , div [ class "col-md-6" ]
                [ div [ class "mb-3" ]
                    [ label [ for "lastName", class "form-label" ]
                        [ text "Nom" ]
                    , input
                        [ type_ "text"
                        , class "form-control"
                        , classList [ ( "is-invalid", Dict.member "lastName" signupFormErrors ) ]
                        , id "lastName"
                        , placeholder "Durand"
                        , value signupForm.lastName
                        , onInput UpdateLastName
                        , required True
                        ]
                        []
                    , viewFieldError "lastName" signupFormErrors
                    ]
                ]
            ]
        , div [ class "mb-3" ]
            [ label [ for "organization", class "form-label" ]
                [ text "Organisation" ]
            , input
                [ type_ "text"
                , class "form-control"
                , classList [ ( "is-invalid", Dict.member "organization" signupFormErrors ) ]
                , id "organization"
                , placeholder "ACME Inc."
                , value signupForm.organization
                , onInput UpdateOrganization
                , required True
                ]
                []
            , viewFieldError "organization" signupFormErrors
            ]
        , div [ class "mb-3 form-check" ]
            [ input
                [ type_ "checkbox"
                , class "form-check-input"
                , classList [ ( "is-invalid", Dict.member "termsAccepted" signupFormErrors ) ]
                , id "termsAccepted"
                , checked signupForm.termsAccepted
                , onCheck UpdateTermsAccepted
                , required True
                ]
                []
            , label [ class "form-check-label", for "termsAccepted" ]
                [ text "J'accepte les conditions d'utilisation du service" ]
            , viewFieldError "termsAccepted" signupFormErrors
            ]
        , div [ class "d-grid" ]
            [ button
                [ type_ "submit"
                , class "btn btn-primary"
                , disabled <| signupForm == User.emptySignupForm || signupFormErrors /= Dict.empty
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


validateForm : SignupForm -> FormErrors
validateForm form =
    let
        requiredMsg =
            "Le champ est obligatoire"

        addErrorIf field msg check =
            if check then
                Dict.insert field msg

            else
                identity
    in
    Dict.empty
        |> addErrorIf "email"
            "L'adresse e-mail est invalide"
            (Regex.fromString "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
                |> Maybe.map (\re -> form.email |> Regex.contains re |> not)
                |> Maybe.withDefault False
            )
        |> addErrorIf "firstName" requiredMsg (String.isEmpty form.firstName)
        |> addErrorIf "lastName" requiredMsg (String.isEmpty form.lastName)
        |> addErrorIf "organization" requiredMsg (String.isEmpty form.organization)
        |> addErrorIf "termsAccepted" requiredMsg (not form.termsAccepted)
