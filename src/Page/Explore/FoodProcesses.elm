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
    , toId = .id >> FoodProcess.idToString
    , toRoute = .id >> Just >> Dataset.FoodProcesses >> Route.Explore scope
    , legend = []
    , columns =
        [ { label = "Identifiant"
          , toValue = Table.StringValue <| .id >> FoodProcess.idToString
          , toCell =
                \process ->
                    if detailed then
                        code [] [ text (FoodProcess.idToString process.id) ]

                    else
                        a [ Route.href (Route.Explore scope (Dataset.FoodProcesses (Just process.id))) ]
                            [ code [] [ text (FoodProcess.idToString process.id) ] ]
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
                        >> String.join ", "
          , toCell =
                .categories
                    >> List.map FoodProcess.categoryToLabel
                    >> String.join ", "
                    >> text
          }
        , { label = "Nom technique"
          , toValue = Table.StringValue .name
          , toCell = .name >> text
          }
        , { label = "Source"
          , toValue = Table.StringValue <| .source
          , toCell = .source >> text
          }
        , { label = "Identifiant dans la source"
          , toValue = Table.StringValue <| .sourceId >> FoodProcess.sourceIdToString
          , toCell = .sourceId >> FoodProcess.sourceIdToString >> text >> List.singleton >> code []
          }
        , { label = "Alias"
          , toValue = Table.StringValue <| .alias >> Maybe.withDefault ""
          , toCell = .alias >> Maybe.map (text >> List.singleton >> em []) >> Maybe.withDefault (text "")
          }
        , { label = "Unité"
          , toValue = Table.StringValue <| .unit
          , toCell = .unit >> text
          }
        , { label = "Commentaire"
          , toValue = Table.StringValue <| .comment >> Maybe.withDefault "N/A"
          , toCell = .comment >> Maybe.withDefault "N/A" >> text
          }
        ]
    }
