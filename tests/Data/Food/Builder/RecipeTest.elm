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
                            [ ( "acd", Unit.impact 0.011189089779453727 )
                            , ( "bvi", Unit.impact 0.710392 )
                            , ( "cch", Unit.impact 0.5278959114240785 )
                            , ( "ecs", Unit.impact 88.05101090781478 )
                            , ( "etf", Unit.impact 33.07775017647984 )
                            , ( "fru", Unit.impact 9.758462228742685 )
                            , ( "fwe", Unit.impact 0.00016001054438593383 )
                            , ( "htc", Unit.impact 2.2389788685985136e-10 )
                            , ( "htn", Unit.impact 1.843605739401256e-8 )
                            , ( "ior", Unit.impact 0.2878076593279296 )
                            , ( "ldu", Unit.impact 41.479821492518425 )
                            , ( "mru", Unit.impact 0.0000013109171817100135 )
                            , ( "ozd", Unit.impact 6.968557288711984e-8 )
                            , ( "pco", Unit.impact 0.0017711511249475765 )
                            , ( "pef", Unit.impact 98.85664854860329 )
                            , ( "pma", Unit.impact 8.489600897726418e-8 )
                            , ( "swe", Unit.impact 0.0034667856440380226 )
                            , ( "tre", Unit.impact 0.04729194432205231 )
                            , ( "wtu", Unit.impact 0.21650082137176382 )
                            ]
                        )
                    |> asTest "should return computed impacts"
                ]
            ]
        )
