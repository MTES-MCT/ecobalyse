module Page.Explore.ObjectProcesses exposing (table)

import Data.Dataset as Dataset
import Data.Object.Process as ObjectProcess
import Data.Scope exposing (Scope)
import Html exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route


table : { detailed : Bool, scope : Scope } -> Table ObjectProcess.Process String msg
table { detailed, scope } =
    { filename = "processes"
    , toId = .id >> ObjectProcess.idToString
    , toRoute = .id >> Just >> Dataset.ObjectProcesses >> Route.Explore scope
    , legend = []
    , columns =
        [ { label = "Identifiant"
          , toValue = Table.StringValue <| .id >> ObjectProcess.idToString
          , toCell =
                \process ->
                    if detailed then
                        code [] [ text (ObjectProcess.idToString process.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.ObjectProcesses (Just process.id))) ]
                            [ code [] [ text (ObjectProcess.idToString process.id) ] ]
          }
        , { label = "Nom"
          , toValue = Table.StringValue .displayName
          , toCell = .displayName >> text
          }
        , { label = "Nom technique"
          , toValue = Table.StringValue <| .name
          , toCell = .name >> text
          }
        , { label = "Source"
          , toValue = Table.StringValue <| .source
          , toCell = .source >> text
          }
        , { label = "Unité"
          , toValue = Table.StringValue <| .unit
          , toCell = .unit >> text
          }
        , { label = "Commentaire"
          , toValue = Table.StringValue .comment
          , toCell = .comment >> text
          }
        ]
    }
