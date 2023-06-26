module Data.Food.Explorer.Recipe exposing
    ( IngredientQuery
    , Packaging
    , PackagingQuery
    , PlantOptions
    , Query
    , Recipe
    , Results
    , Transform
    , TransformQuery
    , compute
    , fromQuery
    , toQuery
    , tunaPizza
    )

import Data.Country as Country
import Data.Food.Explorer.Db exposing (Db)
import Data.Food.Process as Process exposing (Process)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Unit as Unit
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


type alias PackagingQuery =
    { code : Process.Code
    , mass : Mass
    }


type alias Query =
    { ingredients : List IngredientQuery
    , transform : Maybe TransformQuery
    , packaging : List PackagingQuery
    , plant : PlantOptions
    }


type alias PlantOptions =
    { country : Maybe Country.Code }


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
              code = Process.codeFromString "AGRIBALU000000003103966"
            , mass = Mass.grams 1140
            }
    , packaging =
        [ { -- Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent
            code = Process.codeFromString "AGRIBALU000000003104019"
          , mass = Mass.grams 105
          }
        ]
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


type alias Packaging =
    { process : Process.Process
    , mass : Mass
    }


type alias Recipe =
    { ingredients : List Ingredient
    , transform : Maybe Transform
    , packaging : List Packaging
    , plant : PlantOptions
    }


fromQuery : Db -> Query -> Result String Recipe
fromQuery db query =
    Result.map4 Recipe
        (ingredientListFromQuery db query)
        (transformFromQuery db query)
        (packagingListFromQuery db query)
        (Ok query.plant)


ingredientListFromQuery : Db -> Query -> Result String (List Ingredient)
ingredientListFromQuery db query =
    query.ingredients
        |> RE.combineMap (ingredientFromQuery db)


ingredientFromQuery : Db -> IngredientQuery -> Result String Ingredient
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


packagingListFromQuery : Db -> Query -> Result String (List Packaging)
packagingListFromQuery db query =
    query.packaging
        |> RE.combineMap (packagingFromQuery db)


packagingFromQuery : Db -> PackagingQuery -> Result String Packaging
packagingFromQuery { processes } { code, mass } =
    Result.map2 Packaging
        (Process.findByCode processes code)
        (Ok mass)


packagingToQuery : Packaging -> PackagingQuery
packagingToQuery packaging =
    { code = packaging.process.code
    , mass = packaging.mass
    }


toQuery : Recipe -> Query
toQuery recipe =
    { ingredients = List.map ingredientToQuery recipe.ingredients
    , transform = transformToQuery recipe.transform
    , packaging = List.map packagingToQuery recipe.packaging
    , plant = recipe.plant
    }


transformFromQuery : Db -> Query -> Result String (Maybe Transform)
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



---- Results


type alias Results =
    { impacts : Impacts
    , recipe :
        { ingredients : Impacts
        , transform : Impacts
        }
    , packaging : Impacts
    }


compute : Db -> Query -> Result String ( Recipe, Results )
compute db =
    fromQuery db
        >> Result.map
            (\({ ingredients, transform, packaging } as recipe) ->
                let
                    ingredientsImpacts =
                        ingredients
                            |> List.map computeProcessImpacts

                    transformImpacts =
                        transform
                            |> Maybe.map computeProcessImpacts
                            |> Maybe.withDefault Impact.empty

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
                            |> Impact.sumImpacts
                  , recipe =
                        { ingredients = Impact.sumImpacts ingredientsImpacts
                        , transform = transformImpacts
                        }
                  , packaging = Impact.sumImpacts packagingImpacts
                  }
                )
            )


computeProcessImpacts : { a | process : Process, mass : Mass } -> Impacts
computeProcessImpacts item =
    let
        computeImpact : Mass -> Definition.Trigram -> Unit.Impact -> Unit.Impact
        computeImpact mass _ impact =
            impact
                |> Unit.impactToFloat
                |> (*) (Mass.inKilograms mass)
                |> Unit.impact
    in
    item.process.impacts
        |> Impact.mapImpacts (computeImpact item.mass)
