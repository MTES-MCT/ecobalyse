module Data.Food.Builder.RecipeTest exposing (..)

import Data.Food.Builder.Query as Query
import Data.Food.Builder.Recipe as Recipe
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
    let
        exampleQuery =
            Query.carrotCake
    in
    suiteWithDb "Data.Food.Builder.Recipe"
        (\{ builderDb } ->
            [ let
                recipe =
                    exampleQuery
                        |> Recipe.fromQuery builderDb
              in
              describe "fromQuery"
                [ recipe
                    |> Expect.ok
                    |> asTest "should return an Ok for a valid query"
                , { exampleQuery
                    | transform =
                        Just
                            { code = Process.codeFromString "not a process"
                            , mass = Mass.kilograms 0
                            }
                  }
                    |> Recipe.fromQuery builderDb
                    |> Result.map .transform
                    |> Expect.err
                    |> asTest "should return an Err for an invalid processing"
                ]
            , describe "compute"
                [ exampleQuery
                    |> Recipe.compute builderDb
                    |> Result.map (Tuple.second >> .impacts >> AnyDict.toDict)
                    |> Result.withDefault Dict.empty
                    |> Expect.equalDicts
                        (Dict.fromList
                            [ ( "acd", Unit.impact 0.011003657548498127 )
                            , ( "bvi", Unit.impact 0.710392 )
                            , ( "cch", Unit.impact 0.48260009555595884 )
                            , ( "ecs", Unit.impact 84.8347574615068 )
                            , ( "etf", Unit.impact 32.575650059926154 )
                            , ( "fru", Unit.impact 9.080992944015192 )
                            , ( "fwe", Unit.impact 0.00015638016353461696 )
                            , ( "htc", Unit.impact 2.0964675010638222e-10 )
                            , ( "htn", Unit.impact 1.7866923914337903e-8 )
                            , ( "ior", Unit.impact 0.2844546503390845 )
                            , ( "ldu", Unit.impact 41.01494334721711 )
                            , ( "mru", Unit.impact 0.0000011758164443743993 )
                            , ( "ozd", Unit.impact 5.929356623133964e-8 )
                            , ( "pco", Unit.impact 0.0015898633138200164 )
                            , ( "pef", Unit.impact 94.96342355600991 )
                            , ( "pma", Unit.impact 8.096835076313684e-8 )
                            , ( "swe", Unit.impact 0.003412585088489147 )
                            , ( "tre", Unit.impact 0.04669426104713227 )
                            , ( "wtu", Unit.impact 0.213976334671988 )
                            ]
                        )
                    |> asTest "should return computed impacts"
                ]
            ]
        )
