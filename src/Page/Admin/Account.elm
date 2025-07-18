module Page.Admin.Account exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import App exposing (Msg, PageUpdate)
import Data.Session exposing (Session)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Admin.Section as AdminSection
import RemoteData
import Request.Auth as AuthApi
import Request.BackendHttp exposing (WebData)
import Request.BackendHttp.Error as BackendError
import Views.Admin as AdminView
import Views.Alert as Alert
import Views.Container as Container
import Views.Format as Format
import Views.Spinner as Spinner
import Views.Table as Table


type alias Model =
    { accounts : WebData (List User)
    , section : AdminSection.Section
    }


type Msg
    = AccountListResponse (WebData (List User))


init : Session -> AdminSection.Section -> PageUpdate Model Msg
init session section =
    { accounts = RemoteData.NotAsked
    , section = section
    }
        |> App.createUpdate session
        |> App.withCmds [ AuthApi.listAccounts session AccountListResponse ]


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        AccountListResponse response ->
            App.createUpdate session
                { model | accounts = response }


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "User admin"
    , [ Container.centered [ class "d-flex flex-column gap-3 pb-5" ]
            [ AdminView.header model.section
            , model.accounts |> mapRemoteData viewAccounts
            ]
      ]
    )


viewAccounts : List User -> Html Msg
viewAccounts accounts =
    Table.responsiveDefault []
        [ thead []
            [ tr []
                [ th [] [ text "Prénom" ]
                , th [] [ text "Nom" ]
                , th [] [ text "Email" ]
                , th [] [ text "Organisation" ]
                , th [] [ text "Actif" ]
                , th [] [ text "Superutilisateur" ]
                , th [] [ text "Vérifié" ]
                , th [] [ text "Date d'envoi du lien magique" ]
                ]
            ]
        , accounts
            |> List.map accountRowView
            |> tbody []
        ]


accountRowView : User -> Html Msg
accountRowView user =
    let
        yesNo bool =
            if bool then
                "Oui"

            else
                "Non"
    in
    tr []
        [ td [] [ text user.profile.firstName ]
        , td [] [ text user.profile.lastName ]
        , td [] [ text user.email ]
        , td [] [ text <| User.organizationToString user.profile.organization ]
        , td [] [ text <| yesNo user.isActive ]
        , td [] [ text <| yesNo user.isSuperuser ]
        , td [] [ text <| yesNo user.isVerified ]
        , td [] [ user.magicLinkSentAt |> Maybe.map Format.frenchDatetime |> Maybe.withDefault "-" |> text ]
        ]


mapRemoteData : (a -> Html msg) -> WebData a -> Html msg
mapRemoteData fn webData =
    case webData of
        RemoteData.Failure err ->
            Alert.serverError <| BackendError.errorToString err

        RemoteData.Loading ->
            Spinner.view

        RemoteData.NotAsked ->
            text ""

        RemoteData.Success data ->
            fn data


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
