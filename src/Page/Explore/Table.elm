module Page.Explore.Table exposing
    ( Table
    , viewDetails
    , viewList
    )

import Data.Scope exposing (Scope)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Table as TableView


type alias Table a msg =
    List
        { label : String
        , toCell : a -> Html msg
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
