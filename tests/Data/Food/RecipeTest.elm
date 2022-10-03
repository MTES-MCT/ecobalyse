module Data.Food.RecipeTest exposing (..)

import Data.Food.Product as Product
import Data.Food.Recipe as Recipe
import Data.Unit as Unit
import Dict
import Dict.Any as AnyDict
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
                , describe "toQuery"
                    [ Recipe.example
                        |> Recipe.fromQuery db
                        |> Result.map Recipe.toQuery
                        |> Expect.equal (Ok Recipe.example)
                        |> asTest "should convert a recipe to a query"
                    ]
                , describe "compute"
                    [ Recipe.example
                        |> Recipe.compute db
                        |> Result.map AnyDict.toDict
                        |> Result.withDefault Dict.empty
                        |> Expect.equalDicts
                            (Dict.fromList
                                [ ( "acd", Unit.impact 0.03506343974477965 )
                                , ( "ccb", Unit.impact 0.8858187208604257 )
                                , ( "ccf", Unit.impact 1.2803235915026747 )
                                , ( "cch", Unit.impact 2.2335115112338064 )
                                , ( "ccl", Unit.impact 0.06736919887070567 )
                                , ( "etf", Unit.impact 56.33753956463498 )
                                , ( "fru", Unit.impact 25.520977035797088 )
                                , ( "fwe", Unit.impact 0.00026193949288136565 )
                                , ( "htc", Unit.impact 7.591811510804789e-10 )
                                , ( "htn", Unit.impact 4.0416605861081724e-8 )
                                , ( "ior", Unit.impact 0.6159118897240683 )
                                , ( "ldu", Unit.impact 98.44473501661736 )
                                , ( "mru", Unit.impact 0.000005858507829227684 )
                                , ( "ozd", Unit.impact 2.487407380843292e-7 )
                                , ( "pco", Unit.impact 0.014729543445464777 )
                                , ( "pef", Unit.impact 287.08362502550256 )
                                , ( "pma", Unit.impact 2.52021824433807e-7 )
                                , ( "swe", Unit.impact 0.010653579129237457 )
                                , ( "tre", Unit.impact 0.12223778737362725 )
                                , ( "wtu", Unit.impact 0.6942896122967769 )
                                ]
                            )
                        |> asTest "should return computed impacts"
                    ]
                ]
            ]
        )
