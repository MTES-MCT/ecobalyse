module Page.Admin.Process exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import App exposing (Msg, PageUpdate)
import Base64
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category
import Data.Scope as Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Data.Text as Text
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed as Keyed
import Html.Lazy as Lazy
import Json.Encode as Encode
import Page.Admin.Section as AdminSection
import RemoteData
import Request.BackendHttp exposing (WebData)
import Request.Process as ProcessApi
import Views.Admin as AdminView
import Views.Alert as Alert
import Views.Container as Container
import Views.Format as Format
import Views.Table as Table
import Views.WebData as WebDataView


type alias Model =
    { processes : WebData (List Process)
    , scopes : List Scope
    , search : String
    , section : AdminSection.Section
    }


type Msg
    = ProcessListResponse (WebData (List Process))
    | UpdateScopeFilters (List Scope)
    | UpdateSearch String


init : Session -> AdminSection.Section -> PageUpdate Model Msg
init session section =
    { processes = RemoteData.NotAsked
    , scopes = Scope.all
    , search = ""
    , section = section
    }
        |> App.createUpdate session
        |> App.withCmds [ ProcessApi.getProcesses session ProcessListResponse ]


update : Session -> Msg -> Model -> PageUpdate Model Msg
update session msg model =
    case msg of
        ProcessListResponse response ->
            { model | processes = response }
                |> App.createUpdate session
                |> App.mapSession
                    (case response of
                        RemoteData.Success processes ->
                            Session.updateDb (\db -> { db | processes = processes })

                        _ ->
                            identity
                    )

        UpdateScopeFilters scopes ->
            App.createUpdate session { model | scopes = scopes }

        UpdateSearch search ->
            App.createUpdate session { model | search = String.toLower search }


view : Session -> Model -> ( String, List (Html Msg) )
view { db } model =
    ( "Admin Procédés"
    , [ Container.centered [ class "d-flex flex-column gap-3 pb-5" ]
            [ AdminView.header model.section
            , warning
            , AdminView.scopedSearchForm
                { scopes = model.scopes
                , search = UpdateSearch
                , searched = model.search
                , updateScopes = UpdateScopeFilters
                }
            , model.processes
                |> WebDataView.map
                    (\processes ->
                        processes
                            |> processFilters model.scopes model.search
                            |> Lazy.lazy2 processListView db.definitions
                    )
            , model.processes
                |> WebDataView.map downloadDbButton
            ]
      ]
    )


downloadDbButton : List Process -> Html Msg
downloadDbButton processes =
    p [ class "text-end mt-3" ]
        [ a
            [ class "btn btn-primary"
            , download "processes.json"
            , processes
                |> Encode.list Process.encode
                |> Encode.encode 2
                |> Base64.encode
                |> (++) "data:application/json;base64,"
                |> href
            ]
            [ text "Exporter la base de données de procédés" ]
        ]


processFilters : List Scope -> String -> List Process -> List Process
processFilters scopes search =
    (if scopes == [] then
        List.filter (\p -> p.scopes == [])

     else
        Scope.anyOf scopes
    )
        >> Text.search
            { query = search
            , sortBy = Nothing
            , toString = Process.getDisplayName
            }


processListView : Definitions -> List Process -> Html Msg
processListView definitions processes =
    Table.responsiveDefault []
        [ thead []
            [ tr []
                [ th [] [ text "Nom" ]
                , th [] [ text "Catégories" ]
                , th [] [ text "Verticales" ]
                , th [] [ text "Source" ]
                , th [] [ text "Identifiant dans la source" ]
                , th [] [ text "Unité" ]
                , th [] [ text "Élec" ]
                , th [] [ text "Chaleur" ]
                , th [] [ text "Pertes" ]
                , th [] [ text "Densité" ]
                , th [] [ text "Coût env." ]
                , th [] [ text "Commentaire" ]
                ]
            ]
        , processes
            |> List.map
                (\process ->
                    ( Process.idToString process.id
                    , Lazy.lazy2 processRowView definitions process
                    )
                )
            |> Keyed.node "tbody" []
        ]


processRowView : Definitions -> Process -> Html Msg
processRowView definitions process =
    tr []
        [ th [ class "text-truncate", style "max-width" "325px", title <| Process.getDisplayName process ]
            [ text (Process.getDisplayName process)
            , small [ class "d-block fw-normal" ]
                [ code [] [ text (Process.idToString process.id) ] ]
            ]
        , td []
            [ process.categories
                |> List.map
                    (Category.toLabel
                        >> text
                        >> List.singleton
                        >> div [ class "badge text-bg-light fs-10 me-1" ]
                    )
                |> div []
            ]
        , td []
            [ process.scopes
                |> List.map
                    (Scope.toString
                        >> text
                        >> List.singleton
                        >> small [ class "badge bg-secondary fs-10" ]
                    )
                |> div []
            ]
        , td [ class "text-nowrap" ]
            [ text process.source ]
        , td []
            [ code [ class "fs-9" ]
                [ text (Process.getTechnicalName process) ]
            ]
        , td []
            [ text process.unit ]
        , td [ class "text-end" ]
            [ Format.kilowattHours process.elec ]
        , td [ class "text-end" ]
            [ Format.megajoules process.heat ]
        , td [ class "text-end" ]
            [ Format.splitAsPercentage 2 process.waste ]
        , td [ class "text-end" ]
            [ Format.density process ]
        , td [ class "text-end" ]
            [ process.impacts |> Format.formatImpact (Definition.get Definition.Ecs definitions) ]
        , td []
            [ span [ class "fs-9" ] [ text process.comment ] ]
        ]


warning : Html msg
warning =
    Alert.simple
        { attributes = []
        , close = Nothing
        , content =
            [ text "Attention, la base de données mobilisée peut être réinitialisée à tout moment et vos modifications avec."
            ]
        , level = Alert.Warning
        , title = Nothing
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
