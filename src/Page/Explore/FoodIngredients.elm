module Page.Explore.FoodIngredients exposing (table)

import Data.Dataset as Dataset
import Data.Food.Builder.Db as BuilderDb
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Html exposing (..)
import Page.Explore.Table exposing (Table)
import Route


table : BuilderDb.Db -> { detailed : Bool } -> Table Ingredient msg
table _ { detailed } =
    [ { label = "Identifiant"
      , toCell =
            \ingredient ->
                if detailed then
                    code [] [ text (Ingredient.idToString ingredient.id) ]

                else
                    a [ Route.href (Route.Explore (Dataset.FoodIngredients (Just ingredient.id))) ]
                        [ code [] [ text (Ingredient.idToString ingredient.id) ] ]
      }
    , { label = "Nom"
      , toCell = .name >> text
      }
    ]
