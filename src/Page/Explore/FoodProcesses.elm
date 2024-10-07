module Page.Explore.FoodProcesses exposing (table)

import Data.Dataset as Dataset
import Data.Food.Db as FoodDb
import Data.Food.Process as FoodProcess
import Data.Scope exposing (Scope)
import Html exposing (..)
import Page.Explore.Table as Table exposing (Table)
import Route


table : FoodDb.Db -> { detailed : Bool, scope : Scope } -> Table FoodProcess.Process String msg
table _ { detailed, scope } =
    { filename = "processes"
    , toId = .identifier >> FoodProcess.identifierToString
    , toRoute = .identifier >> Just >> Dataset.FoodProcesses >> Route.Explore scope
    , legend = []
    , columns =
        [ { label = "Identifiant"
          , toValue = Table.StringValue <| .identifier >> FoodProcess.identifierToString
          , toCell =
                \process ->
                    if detailed then
                        code [] [ text (FoodProcess.identifierToString process.identifier) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.FoodProcesses (Just process.identifier))) ]
                            [ code [] [ text (FoodProcess.identifierToString process.identifier) ] ]
          }
        , { label = "Nom"
          , toValue = Table.StringValue FoodProcess.getDisplayName
          , toCell = FoodProcess.getDisplayName >> text
          }
        , { label = "Catégories"
          , toValue =
                Table.StringValue <|
                    .categories
                        >> List.map FoodProcess.categoryToLabel
                        >> List.intersperse ", "
                        >> String.concat
          , toCell =
                .categories
                    >> List.map FoodProcess.categoryToLabel
                    >> List.intersperse ", "
                    >> String.concat
                    >> text
          }
        , { label = "Nom technique"
          , toValue = Table.StringValue <| .name >> FoodProcess.nameToString
          , toCell = .name >> FoodProcess.nameToString >> text
          }
        , { label = "Source"
          , toValue = Table.StringValue <| .source
          , toCell = .source >> text
          }
        , { label = "Unité"
          , toValue = Table.StringValue <| .unit
          , toCell = .unit >> text
          }
        , { label = "Description du système"
          , toValue = Table.StringValue <| .systemDescription
          , toCell = .systemDescription >> text
          }
        , { label = "Commentaire"
          , toValue = Table.StringValue <| .comment >> Maybe.withDefault "N/A"
          , toCell = .comment >> Maybe.withDefault "N/A" >> text
          }
        ]
    }
