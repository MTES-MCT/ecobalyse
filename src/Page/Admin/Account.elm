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
import Table as SortableTable
import Time exposing (Posix)
import Views.Admin as AdminView
import Views.Alert as Alert
import Views.Container as Container
import Views.Format as Format
import Views.Spinner as Spinner


type alias Model =
    { accounts : WebData (List User)
    , section : AdminSection.Section
    , tableState : SortableTable.State
    }


type Msg
    = AccountListResponse (WebData (List User))
    | SetTableState SortableTable.State


init : Session -> AdminSection.Section -> PageUpdate Model Msg
init session section =
    { accounts = RemoteData.NotAsked
    , section = section
    , tableState = SortableTable.initialSort "Nom"
    }
        |> App.createUpdate session
        |> App.withCmds [ AuthApi.listAccounts session AccountListResponse ]


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        AccountListResponse response ->
            App.createUpdate session
                { model | accounts = response }

        SetTableState tableState ->
            App.createUpdate session
                { model | tableState = tableState }


booleanColumn : String -> (User -> Bool) -> SortableTable.Column User Msg
booleanColumn name getter =
    let
        yesNo bool =
            if bool then
                "Oui"

            else
                "Non"
    in
    SortableTable.customColumn
        { name = name
        , viewData = getter >> yesNo
        , sorter = SortableTable.increasingOrDecreasingBy (getter >> yesNo)
        }


dateColumn : String -> (User -> Posix) -> SortableTable.Column User Msg
dateColumn name getter =
    SortableTable.customColumn
        { name = name
        , viewData = getter >> Format.frenchDate
        , sorter = SortableTable.increasingOrDecreasingBy (getter >> Time.posixToMillis)
        }


tableConfig : SortableTable.Config User Msg
tableConfig =
    let
        defaultCustomizations =
            SortableTable.defaultCustomizations
    in
    SortableTable.customConfig
        { toId = .email
        , toMsg = SetTableState
        , columns =
            [ SortableTable.stringColumn "Prénom" (.profile >> .firstName)
            , SortableTable.stringColumn "Nom" (.profile >> .lastName)
            , SortableTable.stringColumn "Email " .email
            , SortableTable.stringColumn "Organisation" (.profile >> .organization >> User.organizationToString)
            , booleanColumn "Actif" .isActive
            , booleanColumn "Superutilisateur" .isSuperuser
            , booleanColumn "Vérifié" .isVerified
            , dateColumn "Inscrit le" (.joinedAt >> Maybe.withDefault (Time.millisToPosix 0))
            ]
        , customizations =
            { defaultCustomizations
                | tableAttrs = [ class "table table-striped table-hover table-responsive mb-0 view-list cursor-pointer" ]
            }
        }


view : Session -> Model -> ( String, List (Html Msg) )
view _ model =
    ( "User admin"
    , [ Container.centered [ class "d-flex flex-column gap-3 pb-5" ]
            [ AdminView.header model.section
            , model.accounts |> mapRemoteData (viewAccounts model.tableState)
            ]
      ]
    )


viewAccounts : SortableTable.State -> List User -> Html Msg
viewAccounts tableState accounts =
    div [ class "DatasetTable table-responsive" ]
        [ SortableTable.view tableConfig tableState accounts
        ]


mapRemoteData : (a -> Html msg) -> WebData a -> Html msg
mapRemoteData fn webData =
    -- TODO make this a generic view helper (see component admin)
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
