module Data.Food.Recipe exposing
    ( IngredientQuery
    , PlantOptions
    , Query
    , Recipe
    , TransformQuery
    , addIngredient
    , compute
    , deleteIngredient
    , empty
    , encode
    , fromQuery
    , resetTransform
    , serialize
    , setTransform
    , toQuery
    , tunaPizza
    , updateIngredientMass
    , updateTransformMass
    )

import Data.Country as Country
import Data.Food.Db as FoodDb
import Data.Food.Process as Process exposing (Process)
import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
import Json.Encode as Encode
import Mass exposing (Mass)
import Result.Extra as RE



---- Query


type alias IngredientQuery =
    { code : Process.Code
    , mass : Mass
    , country : Maybe Country.Code
    , labels : List String
    }


type alias TransformQuery =
    { code : Process.Code
    , mass : Mass
    }


type alias Query =
    { ingredients : List IngredientQuery
    , transform : Maybe TransformQuery
    , plant : PlantOptions
    }


type alias PlantOptions =
    { country : Maybe Country.Code }


empty : Query
empty =
    { ingredients = []
    , transform = Nothing
    , plant = { country = Nothing }
    }


tunaPizza : Query
tunaPizza =
    { ingredients =
        [ -- Mozzarella cheese, from cow's milk, at plant
          { code = Process.codeFromString "2e3f03c6de1e43900e09ae852182e9c7"
          , mass = Mass.grams 268
          , country = Nothing
          , labels = []
          }
        , -- Olive oil, at plant
          { code = Process.codeFromString "83da330027d4b25dbc7817f06b738571"
          , mass = Mass.grams 30
          , country = Nothing
          , labels = []
          }
        , -- Tuna, fillet, raw, at processing
          { code = Process.codeFromString "568c715f977f32948813855d5efd95ba"
          , mass = Mass.grams 149
          , country = Nothing
          , labels = []
          }
        , -- Water, municipal
          { code = Process.codeFromString "65e2a1f81e8525d74bc3d4d5bd559114"
          , mass = Mass.grams 100
          , country = Nothing
          , labels = []
          }
        , -- Wheat flour, at industrial mill
          { code = Process.codeFromString "a343353e431d7dddc7bb25cbc41e179a"
          , mass = Mass.grams 168
          , country = Nothing
          , labels = []
          }
        , -- Tomato, for processing, peeled, at plant
          { code = Process.codeFromString "3af9739fc89492167dd0d273daac957a"
          , mass = Mass.grams 425
          , country = Nothing
          , labels = []
          }
        ]
    , transform =
        Just
            { -- Cooking, industrial, 1kg of cooked product/ FR U
              code = Process.codeFromString "aded2490573207ec7ad5a3813978f6a4"
            , mass = Mass.grams 1050
            }
    , plant =
        { country = Nothing
        }
    }



---- Recipe


type alias Ingredient =
    { process : Process
    , mass : Mass
    , country : Maybe Country.Code
    , labels : List String
    }


type alias Transform =
    { process : Process.Process
    , mass : Mass
    }


type alias Recipe =
    { ingredients : List Ingredient
    , transform : Maybe Transform
    , plant : PlantOptions
    }


addIngredient : Mass -> Process.Code -> Query -> Query
addIngredient mass code query =
    { query
        | ingredients =
            { code = code
            , mass = mass
            , country = Nothing
            , labels = []
            }
                :: query.ingredients
    }


deleteIngredient : Process.Code -> Query -> Query
deleteIngredient code query =
    { query | ingredients = query.ingredients |> List.filter (.code >> (/=) code) }


fromQuery : FoodDb.Db -> Query -> Result String Recipe
fromQuery foodDb query =
    Result.map3 Recipe
        (ingredientsFromQuery foodDb query)
        (transformFromQuery foodDb query)
        (Ok query.plant)


ingredientsFromQuery : FoodDb.Db -> Query -> Result String (List Ingredient)
ingredientsFromQuery foodDb query =
    query.ingredients
        |> RE.combineMap (ingredientFromQuery foodDb)


ingredientFromQuery : FoodDb.Db -> IngredientQuery -> Result String Ingredient
ingredientFromQuery { processes } ingredientQuery =
    Result.map4 Ingredient
        (Process.findByCode processes ingredientQuery.code)
        (Ok ingredientQuery.mass)
        (Ok ingredientQuery.country)
        (Ok ingredientQuery.labels)


ingredientToQuery : Ingredient -> IngredientQuery
ingredientToQuery ingredient =
    { code = ingredient.process.code
    , mass = ingredient.mass
    , country = ingredient.country
    , labels = ingredient.labels
    }


resetTransform : Query -> Query
resetTransform query =
    { query | transform = Nothing }


setTransform : Mass -> Process.Code -> Query -> Query
setTransform mass code query =
    { query | transform = Just { code = code, mass = mass } }


toQuery : Recipe -> Query
toQuery recipe =
    { ingredients = List.map ingredientToQuery recipe.ingredients
    , transform = transformToQuery recipe.transform
    , plant = recipe.plant
    }


transformFromQuery : FoodDb.Db -> Query -> Result String (Maybe Transform)
transformFromQuery { processes } query =
    query.transform
        |> Maybe.map
            (\transform ->
                Result.map2 Transform
                    (Process.findByCode processes transform.code)
                    (Ok transform.mass)
                    |> Result.map Just
            )
        |> Maybe.withDefault (Ok Nothing)


transformToQuery : Maybe Transform -> Maybe TransformQuery
transformToQuery =
    Maybe.map
        (\transform ->
            { code = transform.process.code
            , mass = transform.mass
            }
        )


updateIngredientMass : Mass -> Process.Code -> Query -> Query
updateIngredientMass mass code query =
    { query
        | ingredients =
            query.ingredients
                |> List.map
                    (\ing ->
                        if ing.code == code then
                            { ing | mass = mass }

                        else
                            ing
                    )
    }


updateTransformMass : Mass -> Query -> Query
updateTransformMass mass query =
    { query
        | transform =
            query.transform
                |> Maybe.map (\transform -> { transform | mass = mass })
    }



---- Encoders


encode : Query -> Encode.Value
encode q =
    Encode.object
        [ ( "ingredients", Encode.list encodeIngredient q.ingredients )
        , ( "transform", q.transform |> Maybe.map encodeTransform |> Maybe.withDefault Encode.null )
        , ( "plant", encodePlantOptions q.plant )
        ]


encodeIngredient : IngredientQuery -> Encode.Value
encodeIngredient i =
    Encode.object
        [ ( "code", i.code |> Process.codeToString |> Encode.string )
        , ( "mass", Encode.float (Mass.inKilograms i.mass) )
        , ( "country", i.country |> Maybe.map Country.encodeCode |> Maybe.withDefault Encode.null )
        , ( "labels", Encode.list Encode.string i.labels )
        ]


encodeTransform : TransformQuery -> Encode.Value
encodeTransform p =
    Encode.object
        [ ( "code", p.code |> Process.codeToString |> Encode.string )
        , ( "mass", Encode.float (Mass.inKilograms p.mass) )
        ]


encodePlantOptions : PlantOptions -> Encode.Value
encodePlantOptions p =
    Encode.object
        [ ( "country", p.country |> Maybe.map Country.encodeCode |> Maybe.withDefault Encode.null )
        ]


serialize : Query -> String
serialize query =
    query
        |> encode
        |> Encode.encode 2


compute : FoodDb.Db -> Query -> Result String Impacts
compute db query =
    case fromQuery db query of
        Ok recipe ->
            let
                ingredientsImpact : List Impacts
                ingredientsImpact =
                    recipe
                        |> .ingredients
                        |> List.map computeIngredientImpacts

                ingredientsImpactWithTransformImpact : List Impacts
                ingredientsImpactWithTransformImpact =
                    recipe.transform
                        |> Maybe.map
                            (computeIngredientImpacts
                                >> List.singleton
                                >> (++) ingredientsImpact
                            )
                        |> Maybe.withDefault ingredientsImpact
            in
            ingredientsImpactWithTransformImpact
                |> Impact.sumImpacts db.impacts
                |> Ok

        Err error ->
            Err error


computeIngredientImpacts : { a | process : Process, mass : Mass } -> Impacts
computeIngredientImpacts item =
    let
        computeImpact : Mass -> Impact.Trigram -> Unit.Impact -> Unit.Impact
        computeImpact mass _ impact =
            impact
                |> Unit.impactToFloat
                |> (*) (Mass.inKilograms mass)
                |> Unit.impact
    in
    -- total + (item.amount * impact)
    item.process.impacts
        |> Impact.mapImpacts (computeImpact item.mass)
