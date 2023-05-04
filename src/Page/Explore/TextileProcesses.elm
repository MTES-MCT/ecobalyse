module Page.Explore.TextileProcesses exposing (table)

import Data.Dataset as Dataset
import Data.Scope exposing (Scope)
import Data.Textile.Db exposing (Db)
import Data.Textile.Process as Process exposing (Process)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (TableWithValue)
import Route


table : Db -> { detailed : Bool, scope : Scope } -> TableWithValue Process String msg
table _ { detailed, scope } =
    [ { label = "Étape"
      , toValue = .step_usage
      , toCell = text
      }
    , { label = "Identifiant"
      , toValue = .uuid >> Process.uuidToString
      , toCell =
            \uuid ->
                if detailed then
                    code [] [ text uuid ]

                else
                    a [ Route.href (Route.Explore scope (Dataset.TextileProcesses (Just (Process.Uuid uuid)))) ]
                        [ code [] [ text uuid ] ]
      }
    , { label = "Nom"
      , toValue = .name
      , toCell = text
      }
    , { label = "Source"
      , toValue = .source
      , toCell =
            \source ->
                span [ title source ] [ text source ]
      }
    , { label = "Correctif"
      , toValue = .correctif
      , toCell =
            \correctif ->
                span [ title correctif ] [ text correctif ]
      }
    , { label = "Unité"
      , toValue = .unit
      , toCell = text
      }
    ]
