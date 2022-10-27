module Data.Food.RecipeTest exposing (..)

import Data.Food.Process as Process
import Data.Food.Recipe as Recipe
import Data.Unit as Unit
import Dict
import Dict.Any as AnyDict
import Expect
import Mass
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Food.Recipe"
        (\{ foodDb } ->
            [ let
                exampleQuery =
                    Recipe.tunaPizza

                recipe =
                    exampleQuery
                        |> Recipe.fromQuery foodDb
              in
              describe "fromQuery"
                [ recipe
                    |> Expect.ok
                    |> asTest "should return an Ok for a valid query"
                , { exampleQuery
                    | ingredients =
                        [ { code = Process.codeFromString "not an process name"
                          , mass = Mass.kilograms 0
                          , country = Nothing
                          , labels = []
                          }
                        ]
                  }
                    |> Recipe.fromQuery foodDb
                    |> Expect.err
                    |> asTest "should return an Err for an invalid query"
                , case recipe of
                    Ok r ->
                        r.ingredients
                            |> List.map (.process >> .code)
                            |> Expect.equalLists
                                (exampleQuery.ingredients
                                    |> List.map .code
                                )
                            |> asTest "should have the same ingredients as the query"

                    Err error ->
                        Expect.fail error
                            |> asTest "should not raise a parse error"
                , case recipe of
                    Ok r ->
                        r.transform
                            |> Maybe.map (.process >> .code)
                            |> Expect.equal (exampleQuery.transform |> Maybe.map .code)
                            |> asTest "should have the same processing"

                    Err error ->
                        Expect.fail error
                            |> asTest "should not raise a parse error"
                , { exampleQuery | transform = Nothing }
                    |> Recipe.fromQuery foodDb
                    |> Result.map .transform
                    |> Expect.equal (Ok Nothing)
                    |> asTest "should have processing=Nothing if there was no processing in the query"
                , { exampleQuery
                    | transform =
                        Just
                            { code = Process.codeFromString "not a process"
                            , mass = Mass.kilograms 0
                            }
                  }
                    |> Recipe.fromQuery foodDb
                    |> Result.map .transform
                    |> Expect.err
                    |> asTest "should return an Err for an invalid processing"
                ]
            , describe "toQuery"
                [ Recipe.tunaPizza
                    |> Recipe.fromQuery foodDb
                    |> Result.map Recipe.toQuery
                    |> Expect.equal (Ok Recipe.tunaPizza)
                    |> asTest "should convert a recipe to a query"
                ]
            , describe "compute"
                [ Recipe.tunaPizza
                    |> Recipe.compute foodDb
                    |> Result.map AnyDict.toDict
                    |> Result.withDefault Dict.empty
                    |> Expect.equalDicts
                        (Dict.fromList
                            [ ( "acd", Unit.impact 0.03506343974477965 )
                            , ( "cch", Unit.impact 2.2335115112338064 )
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
                            , ( "pef", Unit.impact 290.3211763700538 )
                            , ( "pma", Unit.impact 2.52021824433807e-7 )
                            , ( "swe", Unit.impact 0.010653579129237457 )
                            , ( "tre", Unit.impact 0.12223778737362725 )
                            , ( "wtu", Unit.impact 0.6942896122967769 )
                            ]
                        )
                    |> asTest "should return computed impacts"
                ]
            ]
        )
