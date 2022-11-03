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
                    |> Result.map (.impacts >> AnyDict.toDict)
                    |> Result.withDefault Dict.empty
                    |> Expect.equalDicts
                        (Dict.fromList
                            [ ( "acd", Unit.impact 0.035538585511525805 )
                            , ( "cch", Unit.impact 2.328510711055792 )
                            , ( "etf", Unit.impact 69.66998389133641 )
                            , ( "fru", Unit.impact 26.868391439880615 )
                            , ( "fwe", Unit.impact 0.0003098232117622499 )
                            , ( "htc", Unit.impact 8.068463765137786e-10 )
                            , ( "htn", Unit.impact 4.1922057747372465e-8 )
                            , ( "ior", Unit.impact 0.6274262452565238 )
                            , ( "ldu", Unit.impact 102.95269022995502 )
                            , ( "mru", Unit.impact 0.000006147592019647247 )
                            , ( "ozd", Unit.impact 2.60372986593049e-7 )
                            , ( "pco", Unit.impact 0.015047140231650873 )
                            , ( "pef", Unit.impact 305.500357835915 )
                            , ( "pma", Unit.impact 2.606324508518309e-7 )
                            , ( "swe", Unit.impact 0.010847509135589281 )
                            , ( "tre", Unit.impact 0.12370728057792263 )
                            , ( "wtu", Unit.impact 0.7267032517252009 )
                            ]
                        )
                    |> asTest "should return computed impacts"
                ]
            ]
        )
