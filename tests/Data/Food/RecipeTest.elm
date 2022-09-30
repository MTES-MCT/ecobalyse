module Data.Food.RecipeTest exposing (..)

import Data.Food.Product as Product
import Data.Food.Recipe as Recipe
import Expect
import Mass
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithFoodDb)


suite : Test
suite =
    suiteWithFoodDb "Data.Inputs"
        (\db ->
            [ describe "Food.Recipe"
                [ let
                    exampleQuery =
                        Recipe.example

                    recipe =
                        exampleQuery
                            |> Recipe.fromQuery db
                  in
                  describe "fromQuery"
                    [ recipe
                        |> Expect.ok
                        |> asTest "should return an Ok for a valid query"
                    , { exampleQuery
                        | ingredients =
                            [ { processName = Product.stringToProcessName "not an process name"
                              , mass = Mass.kilograms 0
                              , country = Nothing
                              , labels = []
                              }
                            ]
                      }
                        |> Recipe.fromQuery db
                        |> Expect.err
                        |> asTest "should return an Err for an invalid query"
                    , case recipe of
                        Ok r ->
                            r.ingredients
                                |> List.map (.process >> .name)
                                |> Expect.equalLists
                                    (exampleQuery.ingredients
                                        |> List.map .processName
                                    )
                                |> asTest "should have the same ingredients as the query"

                        Err error ->
                            Expect.fail error
                                |> asTest "should not raise a parse error"
                    , case recipe of
                        Ok r ->
                            r.processing
                                |> Maybe.map (.process >> .name)
                                |> Expect.equal (exampleQuery.processing |> Maybe.map .processName)
                                |> asTest "should have the same processing"

                        Err error ->
                            Expect.fail error
                                |> asTest "should not raise a parse error"
                    , { exampleQuery | processing = Nothing }
                        |> Recipe.fromQuery db
                        |> Result.map .processing
                        |> Expect.equal (Ok Nothing)
                        |> asTest "should have processing=Nothing if there was no processing in the query"
                    , { exampleQuery
                        | processing =
                            Just
                                { processName = Product.stringToProcessName "not a process"
                                , mass = Mass.kilograms 0
                                }
                      }
                        |> Recipe.fromQuery db
                        |> Result.map .processing
                        |> Expect.err
                        |> asTest "should return an Err for an invalid processing"
                    ]
                , describe "toQuery" [ Test.todo "toQuery" ]
                , describe "compute" [ Test.todo "compute" ]
                ]
            ]
        )
