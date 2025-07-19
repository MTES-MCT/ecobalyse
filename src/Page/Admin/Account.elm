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
import Html.Events exposing (..)
import Page.Admin.Section as AdminSection
import RemoteData
import Request.Auth as AuthApi
import Request.BackendHttp exposing (WebData)
import Table as SortableTable
import Time exposing (Posix)
import Views.Admin as AdminView
import Views.Container as Container
import Views.Format as Format
import Views.WebData as WebDataView


type alias Model =
    { accounts : WebData (List User)
    , filters : Filters
    , section : AdminSection.Section
    , tableState : SortableTable.State
    }


type Msg
    = AccountListResponse (WebData (List User))
    | SetFilters Filters
    | SetTableState SortableTable.State


type alias Filters =
    { isActive : Bool
    , isSuperuser : Bool
    , isVerified : Bool
    }


init : Session -> AdminSection.Section -> PageUpdate Model Msg
init session section =
    { accounts = RemoteData.NotAsked
    , filters = { isActive = True, isSuperuser = True, isVerified = True }
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

        SetFilters filters ->
            App.createUpdate session
                { model | filters = filters }

        SetTableState tableState ->
            App.createUpdate session
                { model | tableState = tableState }


filterAccounts : Filters -> List User -> List User
filterAccounts filters accounts =
    accounts
        |> List.filter (\account -> filters.isActive == account.isActive)
        |> List.filter (\account -> filters.isSuperuser == account.isSuperuser)
        |> List.filter (\account -> filters.isVerified == account.isVerified)


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
    ( "Admin Utilisateurs"
    , [ Container.centered [ class "d-flex flex-column gap-3 pb-5" ]
            [ AdminView.header model.section
            , viewFilters model.filters
            , model.accounts |> WebDataView.map (viewAccounts model.filters model.tableState)
            ]
      ]
    )


viewAccounts : Filters -> SortableTable.State -> List User -> Html Msg
viewAccounts filters tableState accounts =
    let
        matches =
            accounts
                |> filterAccounts filters
    in
    div [ class "DatasetTable table-responsive" ]
        [ if List.isEmpty matches then
            div [ class "alert alert-info" ] [ text "Aucun résultat" ]

          else
            matches
                |> SortableTable.view tableConfig tableState
        ]


viewFilters : Filters -> Html Msg
viewFilters filters =
    div [ class "d-flex flex-row align-center input-group border" ]
        [ h3 [ class "h6 mb-0 input-group-text" ] [ text "Filtres" ]
        , [ ( "Actif", .isActive, \f -> { f | isActive = not filters.isActive } )
          , ( "Superutilisateur", .isSuperuser, \f -> { f | isSuperuser = not filters.isSuperuser } )
          , ( "Vérifié", .isVerified, \f -> { f | isVerified = not filters.isVerified } )
          ]
            |> List.map
                (\( label, getter, updateFilters ) ->
                    div [ class "form-check form-check-inline" ]
                        [ Html.label [ class "form-check-label" ]
                            [ Html.input
                                [ type_ "checkbox"
                                , class "form-check-input"
                                , checked (getter filters)
                                , onClick (SetFilters (updateFilters filters))
                                ]
                                []
                            , text label
                            ]
                        ]
                )
            |> div [ class "form-control bg-white" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
