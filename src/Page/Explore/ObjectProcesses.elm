module Page.Explore.ObjectProcesses exposing (table)

import Data.Dataset as Dataset
import Data.Process as Process
import Data.Scope exposing (Scope)
import Html exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route
import Views.Format as Format


table : { detailed : Bool, scope : Scope } -> Table Process.Process String msg
table { detailed, scope } =
    { filename = "processes"
    , toId = .id >> Process.idToString
    , toRoute = .id >> Just >> Dataset.ObjectProcesses >> Route.Explore scope
    , legend = []
    , columns =
        [ { label = "Identifiant"
          , toValue = Table.StringValue <| .id >> Process.idToString
          , toCell =
                \process ->
                    if detailed then
                        code [] [ text (Process.idToString process.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.ObjectProcesses (Just process.id))) ]
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
        , { label = "Source"
          , toValue = Table.StringValue .source
          , toCell = .source >> text
          }
        , { label = "Unité"
          , toValue = Table.StringValue .unit
          , toCell = .unit >> text
          }
        , { label = "Densité"
          , toValue = Table.FloatValue .density
          , toCell = Format.density
          }
        , { label = "Alias"
          , toValue = Table.StringValue <| .alias >> Maybe.withDefault ""
          , toCell = .alias >> Maybe.map (text >> List.singleton >> em []) >> Maybe.withDefault (text "")
          }
        , { label = "Commentaire"
          , toValue = Table.StringValue .comment
          , toCell = .comment >> text
          }
        ]
    }
