module Page.Explore.Table exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Table as TableView


type alias Table a msg =
    List
        { label : String
        , toCell : a -> Html msg
        }


viewDetails : ({ detailed : Bool } -> Table a msg) -> a -> Html msg
viewDetails createTable item =
    TableView.responsiveDefault [ class "view-details" ]
        [ createTable { detailed = True }
            |> List.map
                (\{ label, toCell } ->
                    tr []
                        [ th [] [ text label ]
                        , td [] [ toCell item ]
                        ]
                )
            |> tbody []
        ]


viewList : ({ detailed : Bool } -> Table a msg) -> List a -> Html msg
viewList createTable items =
    let
        tableData =
            createTable { detailed = False }
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
