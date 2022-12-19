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
        (\{ textileDb, builderDb } ->
            [ let
                recipe =
                    exampleQuery
                        |> Recipe.fromQuery builderDb textileDb.countries
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
                    |> Recipe.fromQuery builderDb textileDb.countries
                    |> Result.map .transform
                    |> Expect.err
                    |> asTest "should return an Err for an invalid processing"
                ]
            , describe "compute"
                [ exampleQuery
                    |> Recipe.compute builderDb textileDb.transports textileDb.countries
                    |> Result.map (Tuple.second >> .impacts >> AnyDict.toDict)
                    |> Result.withDefault Dict.empty
                    |> Expect.equalDicts
                        (Dict.fromList
                            [ ( "acd", Unit.impact 0.01100439927742195 )
                            , ( "bvi", Unit.impact 0.710392 )
                            , ( "cch", Unit.impact 0.48278127881943134 )
                            , ( "ecs", Unit.impact 78.51426140637388 )
                            , ( "etf", Unit.impact 32.57765846039237 )
                            , ( "fru", Unit.impact 9.083702821154102 )
                            , ( "fwe", Unit.impact 0.0001563946850580222 )
                            , ( "htc", Unit.impact 2.097037546533961e-10 )
                            , ( "htn", Unit.impact 1.7869200448256602e-8 )
                            , ( "ior", Unit.impact 0.2844680623750399 )
                            , ( "ldu", Unit.impact 41.01680285979832 )
                            , ( "mru", Unit.impact 0.000001176356847323742 )
                            , ( "ozd", Unit.impact 5.933513425796277e-8 )
                            , ( "pco", Unit.impact 0.0015905884650645268 )
                            , ( "pef", Unit.impact 94.9789964559803 )
                            , ( "pma", Unit.impact 8.098406139599333e-8 )
                            , ( "swe", Unit.impact 0.0034128018907113424 )
                            , ( "tre", Unit.impact 0.04669665178023195 )
                            , ( "wtu", Unit.impact 0.2139864326187871 )
                            ]
                        )
                    |> asTest "should return computed impacts"
                ]
            ]
        )
