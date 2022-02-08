module Page.Explore.Countries exposing (table)

import Data.Country as Country exposing (Country)
import Data.Db as Db
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route
import Views.Format as Format


table : { detailed : Bool } -> Table Country msg
table { detailed } =
    [ { label = "Code"
      , toCell =
            \country ->
                if detailed then
                    code [] [ text (Country.codeToString country.code) ]

                else
                    a [ Route.href (Route.Explore (Db.Countries (Just country.code))) ]
                        [ code [] [ text (Country.codeToString country.code) ] ]
      }
    , { label = "Nom"
      , toCell = .name >> text
      }
    , { label = "Mix éléctrique"
      , toCell = .electricityProcess >> .name >> text
      }
    , { label = "Chaleur"
      , toCell = .heatProcess >> .name >> text
      }
    , { label = "Majoration de teinture"
      , toCell = .dyeingWeighting >> Format.ratio
      }
    , { label = "Part du transport aérien"
      , toCell = .airTransportRatio >> Format.ratio
      }
    ]
