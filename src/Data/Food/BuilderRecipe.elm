module Data.Food.BuilderRecipe exposing
    ( Recipe
    , RecipeIngredient
    , Results
    , availableIngredients
    , compute
    , ingredientQueryFromIngredient
    , serializeQuery
    )

import Data.Food.BuilderQuery as BuilderQuery exposing (Query)
import Data.Food.Db as FoodDb
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process exposing (Process)
import Data.Food.Recipe as Recipe exposing (Recipe)
import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
import Json.Encode as Encode
import Mass exposing (Mass)
import Result.Extra as RE


type alias RecipeIngredient =
    { ingredient : Ingredient
    , mass : Mass
    , variant : BuilderQuery.Variant
    }


type alias Recipe =
    { ingredients : List RecipeIngredient
    , transform : Maybe Recipe.Transform
    , packaging : List Recipe.Packaging
    }


type alias Results =
    { impacts : Impacts
    , recipe :
        { ingredients : Impacts
        , transform : Impacts
        }
    , packaging : Impacts
    }


availableIngredients : List Ingredient.Name -> List Ingredient.Name -> List Ingredient.Name
availableIngredients usedIngredientNames ingredientListNames =
    ingredientListNames
        |> List.filter
            (\name ->
                not (List.member name usedIngredientNames)
            )


compute : FoodDb.Db -> Query -> Result String ( Recipe, Results )
compute db =
    fromQuery db
        >> Result.map
            (\({ ingredients, transform, packaging } as recipe) ->
                let
                    ingredientsImpacts =
                        ingredients
                            |> List.map computeIngredientImpacts

                    transformImpacts =
                        transform
                            |> Maybe.map computeProcessImpacts
                            |> Maybe.withDefault Impact.noImpacts

                    packagingImpacts =
                        packaging
                            |> List.map computeProcessImpacts
                in
                ( recipe
                , { impacts =
                        [ ingredientsImpacts
                        , List.singleton transformImpacts
                        , packagingImpacts
                        ]
                            |> List.concat
                            |> Impact.sumImpacts db.impacts
                  , recipe =
                        { ingredients = Impact.sumImpacts db.impacts ingredientsImpacts
                        , transform = transformImpacts
                        }
                  , packaging = Impact.sumImpacts db.impacts packagingImpacts
                  }
                )
            )


computeImpact : Mass -> Impact.Trigram -> Unit.Impact -> Unit.Impact
computeImpact mass _ impact =
    impact
        |> Unit.impactToFloat
        |> (*) (Mass.inKilograms mass)
        |> Unit.impact


computeProcessImpacts : { a | process : Process, mass : Mass } -> Impacts
computeProcessImpacts item =
    item.process.impacts
        |> Impact.mapImpacts (computeImpact item.mass)


computeIngredientImpacts : RecipeIngredient -> Impacts
computeIngredientImpacts ingredient =
    let
        process =
            case ingredient.variant of
                BuilderQuery.Default ->
                    ingredient.ingredient.default

                BuilderQuery.Organic ->
                    ingredient.ingredient.variants.organic
                        |> Maybe.withDefault ingredient.ingredient.default
    in
    process.impacts
        |> Impact.mapImpacts (computeImpact ingredient.mass)


encodeQuery : Query -> Encode.Value
encodeQuery q =
    Encode.object
        [ ( "ingredients", Encode.list encodeIngredient q.ingredients )
        , ( "transform", q.transform |> Maybe.map Recipe.encodeTransform |> Maybe.withDefault Encode.null )
        , ( "packaging", Encode.list Recipe.encodePackaging q.packaging )
        ]


fromQuery : FoodDb.Db -> Query -> Result String Recipe
fromQuery foodDb query =
    Result.map3 Recipe
        (ingredientListFromQuery foodDb query)
        (Recipe.transformFromQuery foodDb query)
        (Recipe.packagingListFromQuery foodDb query)


ingredientListFromQuery : FoodDb.Db -> Query -> Result String (List RecipeIngredient)
ingredientListFromQuery foodDb query =
    query.ingredients
        |> RE.combineMap (ingredientFromQuery foodDb)


ingredientFromQuery : FoodDb.Db -> BuilderQuery.IngredientQuery -> Result String RecipeIngredient
ingredientFromQuery { ingredients } ingredientQuery =
    Result.map3 RecipeIngredient
        (Ingredient.findByName ingredients ingredientQuery.name)
        (Ok ingredientQuery.mass)
        (Ok ingredientQuery.variant)


ingredientQueryFromIngredient : Ingredient.Name -> BuilderQuery.IngredientQuery
ingredientQueryFromIngredient ingredientName =
    { name = ingredientName
    , mass = Mass.grams 100
    , variant = BuilderQuery.Default
    }


variantToString : BuilderQuery.Variant -> String
variantToString variant =
    case variant of
        BuilderQuery.Default ->
            "default"

        BuilderQuery.Organic ->
            "organic"


encodeIngredient : BuilderQuery.IngredientQuery -> Encode.Value
encodeIngredient i =
    Encode.object
        [ ( "name", i.name |> Ingredient.nameToString |> Encode.string )
        , ( "mass", Encode.float (Mass.inKilograms i.mass) )
        , ( "variant", variantToString i.variant |> Encode.string )
        ]


serializeQuery : Query -> String
serializeQuery =
    encodeQuery >> Encode.encode 2
