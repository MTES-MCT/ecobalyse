module Page.Explore.Table exposing
    ( Column
    , Config
    , Table
    , Value(..)
    , viewDetails
    , viewList
    )

import Data.Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route exposing (Route)
import Table as SortableTable
import Views.Table as TableView


type alias Table data comparable msg =
    { toId : data -> String
    , toRoute : data -> Route
    , columns : List (Column data comparable msg)
    }


type alias Column data comparable msg =
    { label : String
    , toValue : Value comparable data
    , toCell : data -> Html msg
    }


type Value comparable data
    = FloatValue (data -> Float)
    | IntValue (data -> Int)
    | StringValue (data -> String)
    | NoValue


type alias Config data msg =
    { toId : data -> String
    , toMsg : SortableTable.State -> msg
    , columns : List (SortableTable.Column data msg)
    , customizations : SortableTable.Customizations data msg
    }


viewDetails :
    Scope
    -> ({ detailed : Bool, scope : Scope } -> Table data comparable msg)
    -> data
    -> Html msg
viewDetails scope createTable item =
    TableView.responsiveDefault [ class "view-details" ]
        [ createTable { detailed = True, scope = scope }
            |> .columns
            |> List.map
                (\{ label, toCell } ->
                    tr []
                        [ th [] [ text label ]
                        , td [] [ toCell item ]
                        ]
                )
            |> tbody []
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
        { toId, toRoute, columns } =
            createTable { detailed = False, scope = scope }

        customizations =
            defaultConfig.customizations

        config =
            SortableTable.customConfig
                { defaultConfig
                    | toId = toId
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
                                                    SortableTable.increasingOrDecreasingBy getString
                                        }
                                )
                    , customizations =
                        { customizations
                            | rowAttrs = toRoute >> routeToMsg >> onClick >> List.singleton
                        }
                }
    in
    div [ class "DatasetTable table-responsive" ]
        [ SortableTable.view config tableState items
        ]
