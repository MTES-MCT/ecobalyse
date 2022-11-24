module Data.Food.BuilderQuery exposing
    ( IngredientQuery
    , Query
    , Variant(..)
    , carrotCake
    , emptyQuery
    , updateIngredient
    )

import Data.Food.ExplorerRecipe as Recipe
import Data.Food.Ingredient as Ingredient
import Data.Food.Process as Process
import Mass exposing (Mass)


type Variant
    = Default
    | Organic


type alias IngredientQuery =
    { name : Ingredient.Name
    , mass : Mass
    , variant : Variant
    }


type alias Query =
    { ingredients : List IngredientQuery
    , transform : Maybe Recipe.TransformQuery
    , packaging : List Recipe.PackagingQuery
    }


emptyQuery : Query
emptyQuery =
    { ingredients = []
    , transform = Nothing
    , packaging = []
    }


carrotCake : Query
carrotCake =
    { ingredients =
        [ { name = Ingredient.nameFromString "oeuf"
          , mass = Mass.grams 120
          , variant = Default
          }
        , { name = Ingredient.nameFromString "blé tendre"
          , mass = Mass.grams 140
          , variant = Default
          }
        , { name = Ingredient.nameFromString "lait"
          , mass = Mass.grams 60
          , variant = Default
          }
        , { name = Ingredient.nameFromString "carotte"
          , mass = Mass.grams 225
          , variant = Default
          }
        ]
    , transform =
        Just
            { -- Cooking, industrial, 1kg of cooked product/ FR U
              code = Process.codeFromString "aded2490573207ec7ad5a3813978f6a4"
            , mass = Mass.grams 545
            }
    , packaging =
        [ { -- Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent
            code = Process.codeFromString "23b2754e5943bc77916f8f871edc53b6"
          , mass = Mass.grams 105
          }
        ]
    }


updateIngredient : Ingredient.Name -> IngredientQuery -> List IngredientQuery -> List IngredientQuery
updateIngredient oldIngredientName newIngredient ingredients =
    ingredients
        |> List.map
            (\ingredient ->
                if ingredient.name == oldIngredientName then
                    newIngredient

                else
                    ingredient
            )
