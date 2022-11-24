module Data.Food.BuilderQuery exposing
    ( IngredientQuery
    , PackagingQuery
    , Query
    , TransformQuery
    , Variant(..)
    , addIngredient
    , carrotCake
    , deleteIngredient
    , emptyQuery
    , updateIngredient
    )

import Data.Food.Ingredient as Ingredient
import Data.Food.Process as Process
import Mass exposing (Mass)
import Quantity


type Variant
    = Default
    | Organic


type alias IngredientQuery =
    { name : Ingredient.Name
    , mass : Mass
    , variant : Variant
    }


type alias PackagingQuery =
    { code : Process.Code
    , mass : Mass
    }


type alias Query =
    { ingredients : List IngredientQuery
    , transform : Maybe TransformQuery
    , packaging : List PackagingQuery
    }


type alias TransformQuery =
    { code : Process.Code
    , mass : Mass
    }


addIngredient : IngredientQuery -> Query -> Query
addIngredient ingredient query =
    { query
        | ingredients =
            query.ingredients
                ++ [ ingredient ]
    }
        |> updateTransformMass


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


deleteIngredient : IngredientQuery -> Query -> Query
deleteIngredient ingredientQuery query =
    { query
        | ingredients =
            query.ingredients
                |> List.filter ((/=) ingredientQuery)
    }
        |> updateTransformMass


getIngredientMass : Query -> Mass
getIngredientMass query =
    query.ingredients
        |> List.map .mass
        |> Quantity.sum


updateIngredient : Ingredient.Name -> IngredientQuery -> Query -> Query
updateIngredient oldIngredientName newIngredient query =
    { query
        | ingredients =
            query.ingredients
                |> List.map
                    (\ingredient ->
                        if ingredient.name == oldIngredientName then
                            newIngredient

                        else
                            ingredient
                    )
    }
        |> updateTransformMass


updateTransformMass : Query -> Query
updateTransformMass query =
    { query
        | transform =
            query.transform
                |> Maybe.map
                    (\transform ->
                        { transform | mass = getIngredientMass query }
                    )
    }
