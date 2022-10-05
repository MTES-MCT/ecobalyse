module Data.Food.Recipe exposing
    ( compute
    , example
    , fromQuery
    , serialize
    , toQuery
    )

import Data.Country as Country
import Data.Food.Db as FoodDb
import Data.Food.Process as Process exposing (Process, ProcessName)
import Data.Food.Product as Product
import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
import Json.Encode as Encode
import Mass exposing (Mass)
import Result.Extra as RE



---- Query


type alias IngredientQuery =
    { processName : ProcessName
    , mass : Mass
    , country : Maybe Country.Code
    , labels : List String
    }


type alias ProcessingQuery =
    { processName : ProcessName
    , mass : Mass
    }


type alias Query =
    { ingredients : List IngredientQuery
    , processing : Maybe ProcessingQuery
    , plant : PlantOptions
    }


type alias PlantOptions =
    { country : Maybe Country.Code }


example : Query
example =
    { ingredients =
        [ { processName = Process.nameFromString "Mozzarella cheese, from cow's milk, at plant"
          , mass = Mass.grams 268
          , country = Nothing
          , labels = []
          }
        , { processName = Process.nameFromString "Olive oil, at plant"
          , mass = Mass.grams 30
          , country = Nothing
          , labels = []
          }
        , { processName = Process.nameFromString "Tuna, fillet, raw, at processing"
          , mass = Mass.grams 149
          , country = Nothing
          , labels = []
          }
        , { processName = Process.nameFromString "Water, municipal"
          , mass = Mass.grams 100
          , country = Nothing
          , labels = []
          }
        , { processName = Process.nameFromString "Wheat flour, at industrial mill"
          , mass = Mass.grams 168
          , country = Nothing
          , labels = []
          }
        , { processName = Process.nameFromString "Tomato, for processing, peeled, at plant"
          , mass = Mass.grams 425
          , country = Nothing
          , labels = []
          }
        ]
    , processing =
        Just
            { processName = Process.nameFromString "Cooking, industrial, 1kg of cooked product/ FR U"
            , mass = Mass.grams 1050
            }
    , plant =
        { country = Just (Country.codeFromString "FR")
        }
    }



---- Recipe


type alias Ingredient =
    { process : Process
    , mass : Mass
    , country : Maybe Country.Code
    , labels : List String
    }


type alias Processing =
    { process : Process.Process
    , mass : Mass
    }


type alias Recipe =
    { ingredients : List Ingredient
    , processing : Maybe Processing
    , plant : PlantOptions
    }



---- Utilities


fromQuery : FoodDb.Db -> Query -> Result String Recipe
fromQuery foodDb query =
    Result.map3 Recipe
        (ingredientsFromQuery foodDb query)
        (processingFromQuery foodDb query)
        (Ok query.plant)


ingredientsFromQuery : FoodDb.Db -> Query -> Result String (List Ingredient)
ingredientsFromQuery foodDb query =
    query.ingredients
        |> RE.combineMap (ingredientFromQuery foodDb)


ingredientFromQuery : FoodDb.Db -> IngredientQuery -> Result String Ingredient
ingredientFromQuery { processes } ingredientQuery =
    Result.map4 Ingredient
        (Process.findByName processes ingredientQuery.processName)
        (Ok ingredientQuery.mass)
        (Ok ingredientQuery.country)
        (Ok ingredientQuery.labels)


processingFromQuery : FoodDb.Db -> Query -> Result String (Maybe Processing)
processingFromQuery { processes } query =
    query.processing
        |> Maybe.map
            (\processing ->
                Result.map2 Processing
                    (Process.findByName processes processing.processName)
                    (Ok processing.mass)
                    |> Result.map Just
            )
        |> Maybe.withDefault (Ok Nothing)


toQuery : Recipe -> Query
toQuery recipe =
    { ingredients = ingredientsToQuery recipe.ingredients
    , processing = processingToQuery recipe.processing
    , plant = recipe.plant
    }


ingredientsToQuery : List Ingredient -> List IngredientQuery
ingredientsToQuery ingredients =
    ingredients
        |> List.map ingredientToQuery


ingredientToQuery : Ingredient -> IngredientQuery
ingredientToQuery ingredient =
    { processName = ingredient.process.name
    , mass = ingredient.mass
    , country = ingredient.country
    , labels = ingredient.labels
    }


processingToQuery : Maybe Processing -> Maybe ProcessingQuery
processingToQuery maybeProcessing =
    maybeProcessing
        |> Maybe.map
            (\processing ->
                { processName = processing.process.name
                , mass = processing.mass
                }
            )



---- Encoders


encode : Query -> Encode.Value
encode q =
    Encode.object
        [ ( "ingredients", Encode.list encodeIngredient q.ingredients )
        , ( "processing", q.processing |> Maybe.map encodeProcessing |> Maybe.withDefault Encode.null )
        , ( "plant", encodePlantOptions q.plant )
        ]


encodeIngredient : IngredientQuery -> Encode.Value
encodeIngredient i =
    Encode.object
        [ ( "processName", i.processName |> Process.nameToString |> Encode.string )
        , ( "mass", Encode.float (Mass.inKilograms i.mass) )
        , ( "country", i.country |> Maybe.map Country.encodeCode |> Maybe.withDefault Encode.null )
        , ( "labels", Encode.list Encode.string i.labels )
        ]


encodeProcessing : ProcessingQuery -> Encode.Value
encodeProcessing p =
    Encode.object
        [ ( "processName", p.processName |> Process.nameToString |> Encode.string )
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
                        |> List.map (Product.computeItemPefImpact db.impacts)
                        |> List.map computeIngredientImpacts

                ingredientsImpactWithProcessingImpact : List Impacts
                ingredientsImpactWithProcessingImpact =
                    recipe.processing
                        |> Maybe.map
                            (Product.computeItemPefImpact db.impacts
                                >> computeIngredientImpacts
                                >> List.singleton
                                >> (++) ingredientsImpact
                            )
                        |> Maybe.withDefault ingredientsImpact
            in
            ingredientsImpactWithProcessingImpact
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
