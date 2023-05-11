module Page.Explore.TextileProcesses exposing (table)

import Data.Dataset as Dataset
import Data.Scope exposing (Scope)
import Data.Textile.Db exposing (Db)
import Data.Textile.Process as Process exposing (Process)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table exposing (TableWithValue)
import Route


table : { detailed : Bool, scope : Scope } -> TableWithValue Process String msg
table { detailed, scope } =
    [ { label = "Étape"
      , toValue = .step_usage
      , toCell = .step_usage >> text
      }
    , { label = "Identifiant"
      , toValue = .uuid >> Process.uuidToString
      , toCell =
            .uuid
                >> Process.uuidToString
                >> (\uuid ->
                        if detailed then
                            code [] [ text uuid ]

                        else
                            a [ Route.href (Route.Explore scope (Dataset.TextileProcesses (Just (Process.Uuid uuid)))) ]
                                [ code [] [ text uuid ] ]
                   )
      }
    , { label = "Nom"
      , toValue = .name
      , toCell = .name >> text
      }
    , { label = "Source"
      , toValue = .source
      , toCell =
            \process ->
                span [ title process.source ] [ text process.source ]
      }
    , { label = "Correctif"
      , toValue = .correctif
      , toCell =
            \process ->
                span [ title process.correctif ] [ text process.correctif ]
      }
    , { label = "Unité"
      , toValue = .unit
      , toCell = .unit >> text
      }
    ]
