module Page.Auth2 exposing (Model, Msg(..), init, update, view)

import Data.Session as Session exposing (Session)
import Data.User2 as User exposing (SignupForm, User)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Request.Auth2 as Auth
import Request.Common as RequestCommon
import Views.Container as Container


type alias Model =
    { formErrors : Dict String String
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


init : Session -> ( Model, Session, Cmd Msg )
init session =
    ( { formErrors = Dict.empty
      , signupForm = User.emptySignupForm
      }
    , session
    , Cmd.none
    )


update : Session -> Msg -> Model -> ( Model, Session, Cmd Msg )
update session msg model =
    case msg of
        SignupResponse (Ok user) ->
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
    ( { model | signupForm = transform model.signupForm }
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
viewSignupForm { signupForm, formErrors } =
    Html.form [ onSubmit SignupSubmitted ]
        [ div [ class "mb-3" ]
            [ label [ for "email", class "form-label" ]
                [ text "Email" ]
            , input
                [ type_ "email"
                , class "form-control"
                , classList [ ( "is-invalid", Dict.member "email" formErrors ) ]
                , id "email"
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
                , disabled (not (isValidForm signupForm))
                ]
                [ text "S'inscrire" ]
            ]
        ]


viewFieldError : String -> Dict String String -> Html msg
viewFieldError field errors =
    case Dict.get field errors of
        Just error ->
            div [ class "invalid-feedback" ]
                [ text error ]

        Nothing ->
            text ""


isValidForm : SignupForm -> Bool
isValidForm form =
    String.length form.email
        > 0
        && String.length form.firstName
        > 0
        && String.length form.lastName
        > 0
        && String.length form.organization
        > 0
        && form.termsAccepted
