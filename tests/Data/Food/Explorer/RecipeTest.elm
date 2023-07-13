module Data.Food.Explorer.RecipeTest exposing (..)

import Data.Food.Explorer.Recipe as Recipe
import Data.Food.Process as Process
import Data.Impact as Impact
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
            , let
                expectImpactEqual =
                    Expect.within (Expect.Relative 0.01)
              in
              describe "compute"
                [ Recipe.tunaPizza
                    |> Recipe.compute explorerDb
                    |> Result.map (Tuple.second >> .impacts)
                    |> Result.withDefault Impact.empty
                    |> TestUtils.expectImpactsEqual
                        { acd = expectImpactEqual 0.03563816517303142
                        , bvi = expectImpactEqual 0
                        , cch = expectImpactEqual 2.340400439828958
                        , ecs = expectImpactEqual 221.38520044798148
                        , etf = expectImpactEqual 70.13958449015763
                        , etfc = expectImpactEqual 0
                        , fru = expectImpactEqual 27.7623776311341
                        , fwe = expectImpactEqual 0.0003131751866055857
                        , htc = expectImpactEqual 8.16161881596257e-10
                        , htcc = expectImpactEqual 0
                        , htn = expectImpactEqual 4.2366936866668135e-8
                        , htnc = expectImpactEqual 0
                        , ior = expectImpactEqual 0.6655424206621998
                        , ldu = expectImpactEqual 103.19136587989166
                        , mru = expectImpactEqual 0.000006171700549716389
                        , ozd = expectImpactEqual 2.6450658409466755e-7
                        , pco = expectImpactEqual 0.015076022211779597
                        , pef = expectImpactEqual 307.45215299658
                        , pma = expectImpactEqual 2.614489711886471e-7
                        , swe = expectImpactEqual 0.010932969853481399
                        , tre = expectImpactEqual 0.12407138654493885
                        , wtu = expectImpactEqual 0.7436928514704245
                        , cage = expectImpactEqual 0
                        }
                    |> asTest "should return computed impacts"
                ]
            ]
        )
