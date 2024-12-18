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
    { filename = "processes"
    , toId = .id >> Process.idToString
    , toRoute = .id >> Just >> Dataset.TextileProcesses >> Route.Explore scope
    , legend = []
    , columns =
        [ { label = "Identifiant"
          , toValue = Table.StringValue <| .id >> Process.idToString
          , toCell =
                \process ->
                    if detailed then
                        code [] [ text (Process.idToString process.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.TextileProcesses (Just process.id))) ]
                            [ code [] [ text (Process.idToString process.id) ] ]
          }
        , { label = "Nom"
          , toValue = Table.StringValue Process.getDisplayName
          , toCell = Process.getDisplayName >> text
          }
        , { label = "Nom technique"
          , toValue = Table.StringValue .name
          , toCell = .name >> text
          }
        , { label = "Catégories"
          , toValue = Table.StringValue <| .categories >> String.join ","
          , toCell = .categories >> String.join "," >> text
          }
        , { label = "Source"
          , toValue = Table.StringValue .source
          , toCell =
                \process ->
                    span [ title process.source ] [ text process.source ]
          }
        , { label = "Unité"
          , toValue = Table.StringValue .unit
          , toCell = .unit >> text
          }
        , { label = "Commentaire"
          , toValue = Table.StringValue .comment
          , toCell =
                \process ->
                    span [ title process.comment ] [ text process.comment ]
          }
        ]
    }
