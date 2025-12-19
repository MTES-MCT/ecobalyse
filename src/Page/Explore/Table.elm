module Page.Explore.Table exposing
    ( Column
    , Config
    , Table
    , Value(..)
    , viewDetails
    , viewList
    )

import Base64
import Csv.Encode as EncodeCsv exposing (Csv)
import Data.Scope as Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route exposing (Route)
import String.Normalize as Normalize
import Table as SortableTable
import Views.Alert as Alert
import Views.Table as TableView


type alias Table data comparable msg =
    { filename : String
    , toId : data -> String
    , toRoute : data -> Route
    , columns : List (Column data comparable msg)
    , legend : List (Html msg)
    }


type alias Column data comparable msg =
    { label : String
    , toValue : Value comparable data
    , toCell : data -> Html msg
    }


type Value comparable data
    = FloatValue (data -> Float)
    | IntValue (data -> Int)
    | NoValue
    | StringValue (data -> String)


type alias Config data msg =
    { toId : data -> String
    , toMsg : SortableTable.State -> msg
    , columns : List (SortableTable.Column data msg)
    , customizations : SortableTable.Customizations data msg
    , search : String
    }


viewDetails :
    Scope
    -> ({ detailed : Bool, scope : Scope } -> Table data comparable msg)
    -> data
    -> Html msg
viewDetails scope createTable item =
    let
        { legend, columns } =
            createTable { detailed = True, scope = scope }
    in
    div []
        [ div [ class "text-muted fs-7" ] legend
        , TableView.responsiveDefault [ class "view-details" ]
            [ columns
                |> List.map
                    (\{ label, toCell } ->
                        tr []
                            [ th [] [ text label ]
                            , td [] [ toCell item ]
                            ]
                    )
                |> tbody []
            ]
        ]


viewList :
    (Route -> msg)
    -> Config data msg
    -> SortableTable.State
    -> Scope
    -> ({ detailed : Bool, scope : Scope } -> Table data comparable msg)
    -> List data
    -> Html msg
viewList routeToMsg defaultConfig tableState scope createTable items =
    let
        ({ filename, toId, toRoute, columns, legend } as table) =
            createTable { detailed = False, scope = scope }

        customizations =
            defaultConfig.customizations

        config =
            SortableTable.customConfig
                { toId = toId
                , toMsg = defaultConfig.toMsg
                , columns =
                    columns
                        |> List.map
                            (\{ label, toCell, toValue } ->
                                SortableTable.veryCustomColumn
                                    { name = label
                                    , viewData = \item -> { attributes = [], children = [ toCell item ] }
                                    , sorter =
                                        -- Note: yes, this looks odd but provides necessary type hints
                                        --       to the compiler so all branches are type-consistent
                                        case toValue of
                                            FloatValue getFloat ->
                                                SortableTable.increasingOrDecreasingBy getFloat

                                            IntValue getInt ->
                                                SortableTable.increasingOrDecreasingBy getInt

                                            NoValue ->
                                                SortableTable.unsortable

                                            StringValue getString ->
                                                SortableTable.increasingOrDecreasingBy
                                                    (getString
                                                        >> String.toLower
                                                        >> Normalize.removeDiacritics
                                                    )
                                    }
                            )
                , customizations =
                    { customizations
                        | rowAttrs = toRoute >> routeToMsg >> onClick >> List.singleton
                    }
                }

        csv =
            { filename = "ecobalyse-" ++ Scope.toString scope ++ "-" ++ filename ++ ".csv"
            , content =
                items
                    |> toCSV table
                    |> EncodeCsv.toString
            }
    in
    if List.isEmpty items then
        Alert.simple
            { attributes = []
            , close = Nothing
            , content =
                [ text <| "Aucun composant disponible pour le secteur "
                , strong [] [ text <| Scope.toLabel scope ]
                ]
            , level = Alert.Info
            , title = Nothing
            }

    else
        div []
            [ div [ class "DatasetTable table-responsive" ]
                [ items
                    |> searchItems defaultConfig
                    |> SortableTable.view config tableState
                , div [ class "text-muted fs-7" ] legend
                ]
            , div [ class "text-end pt-3" ]
                [ a
                    [ class "btn btn-secondary"
                    , href <| "data:text/csv;base64," ++ Base64.encode csv.content
                    , download csv.filename
                    ]
                    [ text "Télécharger ces données au format CSV" ]
                ]
            ]


searchItems : Config data msg -> List a -> List a
searchItems _ items =
    items


toCSV : Table data comparable msg -> List data -> Csv
toCSV { columns } items =
    let
        nonEmptyColumns =
            columns
                |> List.filter (.label >> (/=) "")
    in
    { headers =
        nonEmptyColumns
            |> List.map .label
    , records =
        items
            |> List.map
                (\item ->
                    nonEmptyColumns
                        |> List.map (.toValue >> valueToString item)
                )
    }


valueToString : data -> Value comparable data -> String
valueToString item toValue =
    case toValue of
        FloatValue getFloat ->
            getFloat item |> String.fromFloat

        IntValue getInt ->
            getInt item |> String.fromInt

        NoValue ->
            "N/A"

        StringValue getString ->
            getString item
