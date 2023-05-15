module Page.Explore.Table exposing
    ( Config
    , Table
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
    , rows :
        List
            { label : String
            , toValue : data -> comparable
            , toCell : data -> Html msg
            }
    }


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
            |> .rows
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
        { toId, toRoute, rows } =
            createTable { detailed = False, scope = scope }

        customizations =
            defaultConfig.customizations

        config =
            { defaultConfig
                | toId = toId
                , columns =
                    rows
                        |> List.map
                            (\{ label, toCell, toValue } ->
                                SortableTable.veryCustomColumn
                                    { name = label
                                    , viewData = \item -> { attributes = [], children = [ toCell item ] }
                                    , sorter = SortableTable.increasingOrDecreasingBy toValue
                                    }
                            )
                , customizations =
                    { customizations
                        | rowAttrs = toRoute >> routeToMsg >> onClick >> List.singleton
                    }
            }
                |> SortableTable.customConfig
    in
    div [ class "DatasetTable table-responsive" ]
        [ SortableTable.view config tableState items
        ]
