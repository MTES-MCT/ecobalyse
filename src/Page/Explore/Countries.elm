module Page.Explore.Countries exposing (details, view)

import Data.Country as Country exposing (Country)
import Data.Db as Db exposing (Db)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Format as Format
import Views.Table as Table


details : Db -> Country -> Html msg
details _ country =
    Table.responsiveDefault [ class "view-details" ]
        [ tbody []
            [ tr []
                [ th [] [ text "Code" ]
                , td [] [ code [] [ text (Country.codeToString country.code) ] ]
                ]
            , tr []
                [ th [] [ text "Nom" ]
                , td [] [ text country.name ]
                ]
            , tr []
                [ th [] [ text "Mix éléctrique" ]
                , td [] [ text country.electricityProcess.name ]
                ]
            , tr []
                [ th [] [ text "Chaleur" ]
                , td [] [ text country.heatProcess.name ]
                ]
            , tr []
                [ th [] [ text "Majoration de teinture" ]
                , td [] [ Format.ratio country.dyeingWeighting ]
                ]
            , tr []
                [ th [] [ text "Part du transport aérien" ]
                , td [] [ Format.ratio country.airTransportRatio ]
                ]
            ]
        ]


view : List Country -> Html msg
view countries =
    Table.responsiveDefault [ class "view-list" ]
        [ thead []
            [ tr []
                [ th [] [ text "Code" ]
                , th [] [ text "Nom" ]
                , th [] [ text "Mix éléctrique" ]
                , th [] [ text "Chaleur" ]
                , th [] [ text "Majoration de teinture" ]
                , th [] [ text "Part du transport aérien" ]
                ]
            ]
        , countries
            |> List.map row
            |> tbody []
        ]


row : Country -> Html msg
row country =
    tr []
        [ td []
            [ a [ Route.href (Route.Explore (Db.Countries (Just country.code))) ]
                [ code [] [ text (Country.codeToString country.code) ] ]
            ]
        , td [] [ text country.name ]
        , td [] [ text country.electricityProcess.name ]
        , td [] [ text country.heatProcess.name ]
        , td [ class "text-end" ] [ Format.ratio country.dyeingWeighting ]
        , td [ class "text-end" ] [ Format.ratio country.airTransportRatio ]
        ]
