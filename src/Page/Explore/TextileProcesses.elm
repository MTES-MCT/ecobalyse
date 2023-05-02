module Page.Explore.TextileProcesses exposing (table)

import Data.Dataset as Dataset
import Data.Scope exposing (Scope)
import Data.Textile.Db exposing (Db)
import Data.Textile.Process as Process exposing (Process)
import Energy
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (Table)
import Route


table : Db -> { detailed : Bool, scope : Scope } -> Table Process msg
table _ { detailed, scope } =
    [ { label = "Identifiant"
      , toCell =
            \process ->
                if detailed then
                    code [] [ text (Process.uuidToString process.uuid) ]

                else
                    a [ Route.href (Route.Explore scope (Dataset.TextileProcesses (Just process.uuid))) ]
                        [ code [] [ text (Process.uuidToString process.uuid) ] ]
      }
    , { label = "Nom"
      , toCell = .name >> text
      }
    , { label = "Source"
      , toCell =
            \process ->
                span [ title process.source ] [ text process.source ]
      }
    , { label = "Unité"
      , toCell = .unit >> text
      }
    , { label = "Chaleur (MJ)"
      , toCell = .heat >> Energy.inMegajoules >> String.fromFloat >> text
      }
    , { label = "Électricité kWh/(pick,m)"
      , toCell = .elec_pppm >> String.fromFloat >> text
      }
    , { label = "Électricité (MJ/kg de produit)"
      , toCell = .elec_pppm >> String.fromFloat >> text
      }
    ]
