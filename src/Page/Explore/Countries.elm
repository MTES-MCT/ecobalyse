module Page.Explore.Countries exposing (..)

import Data.Country as Country exposing (Country)
import Data.Db as Db
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Format as Format
import Views.Table as Table


view : List Country -> Html msg
view countries =
    Table.responsiveDefault []
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
        , td [] [ country.name |> text ]
        , td [] [ text country.electricityProcess.name ]
        , td [] [ text country.heatProcess.name ]
        , td [] [ Format.ratio country.dyeingWeighting ]
        , td [] [ Format.ratio country.airTransportRatio ]
        ]
