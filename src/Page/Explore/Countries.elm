module Page.Explore.Countries exposing (..)

import Data.Country as Country exposing (Country)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Format as Format


view : List Country -> Html msg
view countries =
    table [ class "table table-striped table-hover table-responsive" ]
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
        [ td [] [ country.code |> Country.codeToString |> text ]
        , td [] [ country.name |> text ]
        , td [] [ text country.electricityProcess.name ]
        , td [] [ text country.heatProcess.name ]
        , td [] [ Format.ratio country.dyeingWeighting ]
        , td [] [ Format.ratio country.airTransportRatio ]
        ]
