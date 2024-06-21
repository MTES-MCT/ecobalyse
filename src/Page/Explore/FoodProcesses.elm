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
    { toId = .code >> FoodProcess.codeToString
    , toRoute = .code >> Just >> Dataset.FoodProcesses >> Route.Explore scope
    , columns =
        [ { label = "Identifiant"
          , help = Nothing
          , toValue = Table.StringValue <| .code >> FoodProcess.codeToString
          , toCell =
                \process ->
                    if detailed then
                        code [] [ text (FoodProcess.codeToString process.code) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.FoodProcesses (Just process.code))) ]
                            [ code [] [ text (FoodProcess.codeToString process.code) ] ]
          }
        , { label = "Nom"
          , help = Nothing
          , toValue = Table.StringValue getDisplayName
          , toCell = getDisplayName >> text
          }
        , { label = "Catégorie"
          , help = Nothing
          , toValue = Table.StringValue <| .category >> FoodProcess.categoryToLabel
          , toCell = .category >> FoodProcess.categoryToLabel >> text
          }
        , { label = "Nom technique"
          , help = Nothing
          , toValue = Table.StringValue <| .name >> FoodProcess.nameToString
          , toCell = .name >> FoodProcess.nameToString >> text
          }
        , { label = "Identifiant source"
          , help = Nothing
          , toValue = Table.StringValue <| .code >> FoodProcess.codeToString
          , toCell = \process -> code [] [ text (FoodProcess.codeToString process.code) ]
          }
        , { label = "Unité"
          , help = Nothing
          , toValue = Table.StringValue <| .unit
          , toCell = .unit >> text
          }
        , { label = "Description du système"
          , help = Nothing
          , toValue = Table.StringValue <| .systemDescription
          , toCell = .systemDescription >> text
          }
        , { label = "Commentaire"
          , help = Nothing
          , toValue = Table.StringValue <| .comment >> Maybe.withDefault "N/A"
          , toCell = .comment >> Maybe.withDefault "N/A" >> text
          }
        ]
    }


getDisplayName : FoodProcess.Process -> String
getDisplayName process =
    case process.displayName of
        Just displayName ->
            displayName

        Nothing ->
            FoodProcess.nameToString process.name
