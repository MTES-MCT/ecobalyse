module Page.Admin.Process exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import App exposing (Msg, PageUpdate)
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
    , selected : List Process.Id
    }


type Msg
    = ProcessListResponse (WebData (List Process))
    | ToggleSelected Process.Id Bool
    | ToggleSelectedAll Bool
    | UpdateScopeFilters (List Scope)
    | UpdateSearch String


init : Session -> AdminSection.Section -> PageUpdate Model Msg
init session section =
    { processes = RemoteData.Loading
    , scopes = Scope.all
    , search = ""
    , section = section
    , selected = []
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

        ToggleSelected processId flag ->
            { model | selected = model.selected |> AdminView.toggleSelected processId flag }
                |> App.createUpdate session

        ToggleSelectedAll flag ->
            { model | selected = model.processes |> AdminView.selectAll flag }
                |> App.createUpdate session

        UpdateScopeFilters scopes ->
            { model | scopes = scopes }
                |> App.createUpdate session

        UpdateSearch search ->
            { model | search = String.toLower search }
                |> App.createUpdate session


view : Session -> Model -> ( String, List (Html Msg) )
view { db } { processes, scopes, search, section, selected } =
    ( "Admin Procédés"
    , [ Container.centered [ class "d-flex flex-column gap-3 pb-5" ]
            [ AdminView.header section
            , warning
            , AdminView.scopedSearchForm
                { scopes = scopes
                , search = UpdateSearch
                , searched = search
                , updateScopes = UpdateScopeFilters
                }
            , processes
                |> WebDataView.map
                    (Lazy.lazy5 processListView db.definitions scopes search selected)
            , processes
                |> WebDataView.map
                    (processFilters scopes search
                        >> Lazy.lazy4 AdminView.downloadElementsButton "processes.json" Process.encode selected
                    )
            ]
      ]
    )


processFilters : List Scope -> String -> List Process -> List Process
processFilters scopes search =
    (if scopes == [] then
        List.filter (\p -> p.scopes == [])

     else
        Scope.anyOf scopes
    )
        >> Text.search
            { minQueryLength = 2
            , query = search
            , sortBy = Nothing
            , toString = Process.asSearchableText
            }


processListView : Definitions -> List Scope -> String -> List Process.Id -> List Process -> Html Msg
processListView definitions scopes search selected processes =
    Table.responsiveDefault []
        [ thead []
            [ tr []
                [ th [ class "align-start text-center" ]
                    [ AdminView.selectAllCheckbox ToggleSelectedAll processes selected
                    ]
                , th [] [ label [ for AdminView.selectAllId ] [ text "Nom" ] ]
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
            |> processFilters scopes search
            |> List.map
                (\process ->
                    ( Process.idToString process.id
                    , Lazy.lazy3 processRowView definitions selected process
                    )
                )
            |> Keyed.node "tbody" []
        ]


processRowView : Definitions -> List Process.Id -> Process -> Html Msg
processRowView definitions selected process =
    tr []
        [ td [ class "align-start text-center" ]
            [ selected
                |> AdminView.toggleElementCheckbox Process.idToString ToggleSelected process.id
            ]
        , th [ class "text-truncate", style "max-width" "325px", title <| Process.getDisplayName process ]
            [ label [ for <| AdminView.toggleElementId Process.idToString process.id ]
                [ text (Process.getDisplayName process) ]
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
