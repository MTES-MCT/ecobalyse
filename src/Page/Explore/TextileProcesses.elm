module Page.Explore.TextileProcesses exposing (table)

import Data.Dataset as Dataset
import Data.Scope exposing (Scope)
import Data.Textile.Process as Process exposing (Process)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route


table : { detailed : Bool, scope : Scope } -> Table Process String msg
table { detailed, scope } =
    { toId = .uuid >> Process.uuidToString
    , toRoute = .uuid >> Just >> Dataset.TextileProcesses >> Route.Explore scope
    , columns =
        [ { label = "Étape"
          , help = Nothing
          , toValue = Table.StringValue <| .stepUsage
          , toCell = .stepUsage >> text
          }
        , { label = "Identifiant"
          , help = Nothing
          , toValue = Table.StringValue <| .uuid >> Process.uuidToString
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
          , help = Nothing
          , toValue = Table.StringValue .name
          , toCell = .name >> text
          }
        , { label = "Source"
          , help = Nothing
          , toValue = Table.StringValue .source
          , toCell =
                \process ->
                    span [ title process.source ] [ text process.source ]
          }
        , { label = "Correctif"
          , help = Nothing
          , toValue = Table.StringValue .correctif
          , toCell =
                \process ->
                    span [ title process.correctif ] [ text process.correctif ]
          }
        , { label = "Unité"
          , help = Nothing
          , toValue = Table.StringValue .unit
          , toCell = .unit >> text
          }
        ]
    }
