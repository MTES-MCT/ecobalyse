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
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
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
    { isActive : Maybe Bool
    , isSuperuser : Maybe Bool
    , isVerified : Maybe Bool
    , emailOptin : Maybe Bool
    , termsAccepted : Maybe Bool
    }


init : Session -> AdminSection.Section -> PageUpdate Model Msg
init session section =
    { accounts = RemoteData.NotAsked
    , filters = defaultFilters
    , section = section
    , tableState = SortableTable.initialSort "Nom"
    }
        |> App.createUpdate session
        |> App.withCmds [ AuthApi.listAccounts session AccountListResponse ]


defaultFilters : Filters
defaultFilters =
    { isActive = Nothing
    , isSuperuser = Nothing
    , isVerified = Nothing
    , emailOptin = Nothing
    , termsAccepted = Nothing
    }


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
        |> List.filter (\account -> filters.isActive |> Maybe.map ((==) account.isActive) |> Maybe.withDefault True)
        |> List.filter (\account -> filters.isSuperuser |> Maybe.map ((==) account.isSuperuser) |> Maybe.withDefault True)
        |> List.filter (\account -> filters.isVerified |> Maybe.map ((==) account.isVerified) |> Maybe.withDefault True)
        |> List.filter (\account -> filters.emailOptin |> Maybe.map ((==) account.profile.emailOptin) |> Maybe.withDefault True)
        |> List.filter (\account -> filters.termsAccepted |> Maybe.map ((==) account.profile.termsAccepted) |> Maybe.withDefault True)


yesNo : Bool -> String
yesNo bool =
    if bool then
        "Oui"

    else
        "Non"


booleanColumn : String -> (User -> Bool) -> SortableTable.Column User Msg
booleanColumn name getter =
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
            , booleanColumn "Vérifié" .isVerified
            , booleanColumn "Admin" .isSuperuser
            , booleanColumn "Opt-in" (.profile >> .emailOptin)
            , booleanColumn "CGU" (.profile >> .termsAccepted)
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
            , div [ class "row" ]
                [ div [ class "col-lg-9 col-xl-10" ]
                    [ model.accounts
                        |> WebDataView.map (viewAccounts model.filters model.tableState)
                    ]
                , div [ class "col-lg-3 col-xl-2" ]
                    [ viewFiltersForm model.filters ]
                ]
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
            div [ class "alert alert-info" ]
                [ text "Aucun résultat" ]

          else
            matches
                |> SortableTable.view tableConfig tableState
        ]


viewFilters : Filters -> Html Msg
viewFilters filters =
    if filters == defaultFilters then
        text ""

    else
        availableFilters
            |> Dict.map (\_ ( getter, setter ) -> ( getter filters, setter ))
            |> Dict.toList
            |> List.filterMap (\( field, ( value, setter ) ) -> value |> Maybe.map (\v -> ( field, yesNo v, setter )))
            |> List.map
                (\( field, value, setter ) ->
                    small [ class "btn-group fs-9" ]
                        [ span [ class "btn btn-sm btn-primary" ] [ text field ]
                        , span [ class "btn btn-sm btn-light" ] [ text value ]
                        , button
                            [ type_ "button"
                            , class "btn btn-sm btn-light"
                            , onClick <| SetFilters (setter filters Nothing)
                            ]
                            [ text "✕" ]
                        ]
                )
            |> div [ class "d-flex gap-2" ]


availableFilters : Dict String ( Filters -> Maybe Bool, Filters -> Maybe Bool -> Filters )
availableFilters =
    Dict.fromList
        [ ( "Actif", ( .isActive, \f val -> { f | isActive = val } ) )
        , ( "Admin", ( .isSuperuser, \f val -> { f | isSuperuser = val } ) )
        , ( "CGU", ( .termsAccepted, \f val -> { f | termsAccepted = val } ) )
        , ( "Opt-in", ( .emailOptin, \f val -> { f | emailOptin = val } ) )
        , ( "Vérifié", ( .isVerified, \f val -> { f | isVerified = val } ) )
        ]


viewFiltersForm : Filters -> Html Msg
viewFiltersForm filters =
    let
        filterRadio index name getter setter optionValue =
            Html.label [ class "form-check-label" ]
                [ Html.input
                    [ type_ "radio"
                    , Attr.name <| "filter-" ++ String.fromInt index ++ "-" ++ name
                    , class "form-check-input me-1"
                    , checked <| getter filters == optionValue
                    , onClick <| SetFilters (setter filters optionValue)
                    ]
                    []
                , text name
                ]
    in
    div [ class "card mt-3 mt-lg-0" ]
        [ h2 [ class "h6 mb-0 card-header" ] [ text "Filtres" ]
        , availableFilters
            |> Dict.toList
            |> List.indexedMap
                (\index ( label, ( getter, setter ) ) ->
                    div [ class "border-bottom p-2" ]
                        [ div [ class "fw-bold mb-1" ] [ text label ]
                        , div [ class "d-flex flex-row align-center justify-content-start  gap-2" ]
                            [ filterRadio index "Tout" getter setter Nothing
                            , filterRadio index "Oui" getter setter (Just True)
                            , filterRadio index "Non" getter setter (Just False)
                            ]
                        ]
                )
            |> div [ class "card-body p-0 fs-7" ]
        , div [ class "card-footer text-center p-1 border-top-0" ]
            [ button
                [ class "btn btn-sm btn-link"
                , onClick <| SetFilters defaultFilters
                , disabled <| filters == defaultFilters
                ]
                [ text "Réinitialiser les filtres" ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
