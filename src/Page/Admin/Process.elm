module Page.Admin.Process exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import App exposing (Msg, PageUpdate)
import Data.Impact.Definition as Definition
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category
import Data.Scope as Scope exposing (Scope)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as Encode
import Page.Admin.Section as AdminSection
import RemoteData
import Request.BackendHttp exposing (WebData)
import Request.Process as ProcessApi
import Static.Db exposing (Db)
import Views.Admin as AdminView
import Views.Alert as Alert
import Views.Container as Container
import Views.Format as Format
import Views.Scope as ScopeView
import Views.Table as Table
import Views.WebData as WebDataView


type alias Model =
    { processes : WebData (List Process)
    , scopes : List Scope
    , section : AdminSection.Section
    }


type Msg
    = ProcessListResponse (WebData (List Process))
    | UpdateScopeFilters (List Scope)


init : Session -> AdminSection.Section -> PageUpdate Model Msg
init session section =
    { processes = RemoteData.NotAsked
    , scopes = Scope.all
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


view : Session -> Model -> ( String, List (Html Msg) )
view { db } model =
    ( "Admin Procédés"
    , [ Container.centered [ class "d-flex flex-column gap-3 pb-5" ]
            [ AdminView.header model.section
            , warning
            , model.scopes
                |> ScopeView.scopeFilterForm UpdateScopeFilters
            , model.processes
                |> WebDataView.map (processListView db model.scopes)
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
                |> href
            ]
            [ text "Exporter la base de données de procédés" ]
        ]


processListView : Db -> List Scope -> List Process -> Html Msg
processListView db scopes processes =
    Table.responsiveDefault []
        [ thead []
            [ tr []
                ([ th [] [ text "Nom" ]
                 , th [] [ text "Catégories" ]
                 , th [] [ text "Verticales" ]
                 , th [] [ text "Source" ]
                 , th [] [ text "Identifiant dans la source" ]
                 , th [] [ text "Unité" ]
                 , th [] [ text "Électricité" ]
                 , th [] [ text "Chaleur" ]
                 , th [] [ text "Pertes" ]
                 , th [] [ text "Densité" ]
                 , th [] [ text "Commentaire" ]
                 ]
                    ++ (Definition.trigrams
                            |> List.map
                                (\trigram ->
                                    th
                                        [ class "text-center cursor-help"
                                        , Definition.get trigram db.definitions |> .label |> title
                                        ]
                                        [ text <| Definition.toString trigram ]
                                )
                       )
                )
            ]
        , processes
            |> (if scopes == [] then
                    List.filter (\p -> p.scopes == [])

                else
                    Scope.anyOf scopes
               )
            |> List.map (processRowView db)
            |> tbody []
        ]


processRowView : Db -> Process -> Html Msg
processRowView db process =
    tr []
        ([ th [ class "align-middle text-truncate", style "max-width" "350px" ]
            [ text (Process.getDisplayName process)
            , small [ class "d-block fw-normal" ]
                [ code [] [ text (Process.idToString process.id) ] ]
            ]
         , td [ class "align-middle" ]
            [ process.categories
                |> List.map
                    (Category.toLabel
                        >> text
                        >> List.singleton
                        >> div [ class "badge text-bg-light fs-10 me-1" ]
                    )
                |> div []
            ]
         , td [ class "align-middle" ]
            [ process.scopes
                |> List.map
                    (Scope.toString
                        >> text
                        >> List.singleton
                        >> small [ class "badge bg-secondary fs-10" ]
                    )
                |> div []
            ]
         , td [ class "align-middle text-nowrap" ]
            [ text process.source ]
         , td [ class "align-middle" ]
            [ code [ class "fs-9" ]
                [ text (Process.getTechnicalName process) ]
            ]
         , td [ class "align-middle" ]
            [ text process.unit ]
         , td [ class "align-middle text-end" ]
            [ Format.kilowattHours process.elec ]
         , td [ class "align-middle text-end" ]
            [ Format.megajoules process.heat ]
         , td [ class "align-middle text-end" ]
            [ Format.splitAsPercentage 2 process.waste ]
         , td [ class "align-middle text-end" ]
            [ Format.density process ]
         , td [ class "align-middle" ]
            [ span [ class "fs-9" ] [ text process.comment ] ]
         ]
            ++ (Definition.trigrams
                    |> List.map
                        (\trigram ->
                            td [ class "align-middle text-nowrap text-end" ]
                                [ process.impacts
                                    |> Format.formatImpact (Definition.get trigram db.definitions)
                                ]
                        )
               )
        )


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
