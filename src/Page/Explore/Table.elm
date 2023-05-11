module Page.Explore.Table exposing
    ( Config
    , TableWithValue
    , viewDetailsWithOrdering
    , viewListWithOrdering
    )

import Data.Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Table as SortableTable
import Views.Table as TableView


type alias TableWithValue data comparable msg =
    List
        { label : String
        , toValue : data -> comparable
        , toCell : data -> Html msg
        }


type alias Config data msg =
    { toId : data -> String
    , toMsg : SortableTable.State -> msg
    , columns : List (SortableTable.Column data msg)
    , customizations : SortableTable.Customizations data msg
    }


viewDetailsWithOrdering :
    Scope
    -> ({ detailed : Bool, scope : Scope } -> TableWithValue data comparable msg)
    -> data
    -> Html msg
viewDetailsWithOrdering scope createTable item =
    TableView.responsiveDefault [ class "view-details" ]
        [ createTable { detailed = True, scope = scope }
            |> List.map
                (\{ label, toCell } ->
                    tr []
                        [ th [] [ text label ]
                        , td [] [ item |> toCell ]
                        ]
                )
            |> tbody []
        ]


viewListWithOrdering :
    Config data msg
    -> SortableTable.State
    -> Scope
    -> ({ detailed : Bool, scope : Scope } -> TableWithValue data comparable msg)
    -> List data
    -> Html msg
viewListWithOrdering defaultConfig tableState scope createTable items =
    let
        tableData =
            createTable { detailed = False, scope = scope }

        config =
            { defaultConfig
                | columns =
                    tableData
                        |> List.map
                            (\{ label, toCell, toValue } ->
                                SortableTable.veryCustomColumn
                                    { name = label
                                    , viewData = \item -> { attributes = [], children = [ item |> toCell ] }
                                    , sorter = SortableTable.increasingOrDecreasingBy toValue
                                    }
                            )
            }
                |> SortableTable.customConfig
    in
    div [ class "DatasetTable table-responsive" ]
        [ SortableTable.view config tableState items
        ]
