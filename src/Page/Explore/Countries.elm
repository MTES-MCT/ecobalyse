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
