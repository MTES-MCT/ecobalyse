module Data.Food.Explorer.RecipeTest exposing (..)

import Data.Food.Explorer.Recipe as Recipe
import Data.Food.Process as Process
import Data.Unit as Unit
import Dict
import Dict.Any as AnyDict
import Expect
import Mass
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Food.Explorer.Recipe"
        (\{ explorerDb } ->
            [ let
                exampleQuery =
                    Recipe.tunaPizza

                recipe =
                    exampleQuery
                        |> Recipe.fromQuery explorerDb
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
                    |> Recipe.fromQuery explorerDb
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
                    |> Recipe.fromQuery explorerDb
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
                    |> Recipe.fromQuery explorerDb
                    |> Result.map .transform
                    |> Expect.err
                    |> asTest "should return an Err for an invalid processing"
                ]
            , describe "toQuery"
                [ Recipe.tunaPizza
                    |> Recipe.fromQuery explorerDb
                    |> Result.map Recipe.toQuery
                    |> Expect.equal (Ok Recipe.tunaPizza)
                    |> asTest "should convert a recipe to a query"
                ]
            , describe "compute"
                [ Recipe.tunaPizza
                    |> Recipe.compute explorerDb
                    |> Result.map (Tuple.second >> .impacts >> AnyDict.toDict)
                    |> Result.withDefault Dict.empty
                    |> Expect.equalDicts
                        (Dict.fromList
                            [ ( "acd", Unit.impact 0.03563816517303142 )
                            , ( "bvi", Unit.impact 0 )
                            , ( "cch", Unit.impact 2.340400439828958 )
                            , ( "ecs", Unit.impact 0 )
                            , ( "etf", Unit.impact 70.13958449015763 )
                            , ( "fru", Unit.impact 27.7623776311341 )
                            , ( "fwe", Unit.impact 0.0003131751866055857 )
                            , ( "htc", Unit.impact 8.16161881596257e-10 )
                            , ( "htn", Unit.impact 4.2366936866668135e-8 )
                            , ( "ior", Unit.impact 0.6655424206621998 )
                            , ( "ldu", Unit.impact 103.19136587989166 )
                            , ( "mru", Unit.impact 0.000006171700549716389 )
                            , ( "ozd", Unit.impact 2.6450658409466755e-7 )
                            , ( "pco", Unit.impact 0.015076022211779597 )
                            , ( "pef", Unit.impact 308.38011755405006 )
                            , ( "pma", Unit.impact 2.614489711886471e-7 )
                            , ( "swe", Unit.impact 0.010932969853481399 )
                            , ( "tre", Unit.impact 0.12407138654493885 )
                            , ( "wtu", Unit.impact 0.7436928514704245 )
                            , ( "etf-c", Unit.impact 0 )
                            , ( "htn-c", Unit.impact 0 )
                            , ( "htc-c", Unit.impact 0 )
                            ]
                        )
                    |> asTest "should return computed impacts"
                ]
            ]
        )
