module Page.Explore.Table exposing
    ( Table
    , TableWithValue
    , viewDetails
    , viewDetailsWithOrdering
    , viewList
    , viewListWithOrdering
    )

import Data.Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Table
import Views.Table as TableView


type alias Table a msg =
    List
        { label : String
        , toCell : a -> Html msg
        }


type alias TableWithValue data comparable msg =
    List
        { label : String
        , toValue : data -> comparable
        , toCell : comparable -> Html msg
        }


viewDetails : Scope -> ({ detailed : Bool, scope : Scope } -> Table a msg) -> a -> Html msg
viewDetails scope createTable item =
    TableView.responsiveDefault [ class "view-details" ]
        [ createTable { detailed = True, scope = scope }
            |> List.map
                (\{ label, toCell } ->
                    tr []
                        [ th [] [ text label ]
                        , td [] [ toCell item ]
                        ]
                )
            |> tbody []
        ]


viewDetailsWithOrdering :
    Scope
    -> ({ detailed : Bool, scope : Scope } -> TableWithValue data comparable msg)
    -> data
    -> Html msg
viewDetailsWithOrdering scope createTable item =
    TableView.responsiveDefault [ class "view-details" ]
        [ createTable { detailed = True, scope = scope }
            |> List.map
                (\{ label, toValue, toCell } ->
                    tr []
                        [ th [] [ text label ]
                        , td [] [ item |> toValue |> toCell ]
                        ]
                )
            |> tbody []
        ]


viewList : Scope -> ({ detailed : Bool, scope : Scope } -> Table a msg) -> List a -> Html msg
viewList scope createTable items =
    let
        tableData =
            createTable { detailed = False, scope = scope }
    in
    TableView.responsiveDefault [ class "view-list" ]
        [ thead []
            [ tableData
                |> List.map (\{ label } -> th [] [ text label ])
                |> tr []
            ]
        , items
            |> List.map
                (\item ->
                    tableData
                        |> List.map (\{ toCell } -> td [] [ toCell item ])
                        |> tr []
                )
            |> tbody []
        ]


viewListWithOrdering :
    { toId : data -> String
    , toMsg : Table.State -> msg
    , columns : List (Table.Column data msg)
    , customizations : Table.Customizations data msg
    }
    -> Table.State
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
                                Table.veryCustomColumn
                                    { name = label
                                    , viewData = \item -> { attributes = [], children = [ item |> toValue |> toCell ] }
                                    , sorter = Table.increasingOrDecreasingBy toValue
                                    }
                            )
            }
                |> Table.customConfig
    in
    div [ class "DatasetTable table-responsive" ]
        [ Table.view config tableState items
        ]
