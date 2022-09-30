module Data.Food.RecipeTest exposing (..)

import Data.Food.Recipe as Recipe
import Expect
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithFoodDb)


suite : Test
suite =
    suiteWithFoodDb "Data.Inputs"
        (\db ->
            [ describe "Food.Recipe"
                [ describe "fromQuery"
                    [ Recipe.example
                        |> Recipe.fromQuery db
                        |> Expect.equal (Ok ())
                        |> asTest "should return a query result"
                    ]
                , describe "toQuery" [ Test.todo "toQuery" ]
                , describe "compute" [ Test.todo "compute" ]
                ]
            ]
        )
