module Page.Explore.Countries exposing (details, view)

import Data.Country as Country exposing (Country)
import Data.Db as Db exposing (Db)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Views.Format as Format
import Views.Table as Table


table : { detailed : Bool } -> List { label : String, toCell : Country -> Html msg }
table { detailed } =
    [ { label = "Identifiant"
      , toCell =
            \country ->
                td []
                    [ if detailed then
                        code [] [ text (Country.codeToString country.code) ]

                      else
                        a [ Route.href (Route.Explore (Db.Countries (Just country.code))) ]
                            [ code [] [ text (Country.codeToString country.code) ] ]
                    ]
      }
    , { label = "Nom"
      , toCell = \country -> text country.name
      }
    , { label = "Code"
      , toCell = \country -> code [] [ text (Country.codeToString country.code) ]
      }
    , { label = "Nom"
      , toCell = \country -> text country.name
      }
    , { label = "Mix éléctrique"
      , toCell = \country -> text country.electricityProcess.name
      }
    , { label = "Chaleur"
      , toCell = \country -> text country.heatProcess.name
      }
    , { label = "Majoration de teinture"
      , toCell = \country -> Format.ratio country.dyeingWeighting
      }
    , { label = "Part du transport aérien"
      , toCell = \country -> Format.ratio country.airTransportRatio
      }
    ]


details : Db -> Country -> Html msg
details _ country =
    Table.responsiveDefault [ class "view-details" ]
        [ table { detailed = True }
            |> List.map
                (\{ label, toCell } ->
                    tr []
                        [ th [] [ text label ]
                        , td [] [ toCell country ]
                        ]
                )
            |> tbody []
        ]


view : List Country -> Html msg
view countries =
    Table.responsiveDefault [ class "view-list" ]
        [ thead []
            [ table { detailed = False }
                |> List.map (\{ label } -> th [] [ text label ])
                |> tr []
            ]
        , countries
            |> List.map
                (\country ->
                    table { detailed = False }
                        |> List.map (\{ toCell } -> td [] [ toCell country ])
                        |> tr []
                )
            |> tbody []
        ]
