module Data.Food.Explorer.RecipeTest exposing (..)

import Data.Food.Explorer.Recipe as Recipe
import Data.Food.Process as Process
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Unit as Unit
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
                    |> Result.map (Tuple.second >> .impacts)
                    |> Result.withDefault Impact.empty
                    |> Expect.all
                        [ \subject -> Expect.equal (Impact.getImpact Definition.Acd subject) (Unit.impact 0.03563816517303142)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Bvi subject) (Unit.impact 0)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Cch subject) (Unit.impact 2.340400439828958)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Ecs subject) (Unit.impact 221.38520044798148)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Etf subject) (Unit.impact 70.13958449015763)
                        , \subject -> Expect.equal (Impact.getImpact Definition.EtfC subject) (Unit.impact 0)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Fru subject) (Unit.impact 27.7623776311341)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Fwe subject) (Unit.impact 0.0003131751866055857)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Htc subject) (Unit.impact 8.16161881596257e-10)
                        , \subject -> Expect.equal (Impact.getImpact Definition.HtcC subject) (Unit.impact 0)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Htn subject) (Unit.impact 4.2366936866668135e-8)
                        , \subject -> Expect.equal (Impact.getImpact Definition.HtnC subject) (Unit.impact 0)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Ior subject) (Unit.impact 0.6655424206621998)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Ldu subject) (Unit.impact 103.19136587989166)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Mru subject) (Unit.impact 0.000006171700549716389)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Ozd subject) (Unit.impact 2.6450658409466755e-7)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Pco subject) (Unit.impact 0.015076022211779597)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Pef subject) (Unit.impact 307.45215299658)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Pma subject) (Unit.impact 2.614489711886471e-7)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Swe subject) (Unit.impact 0.010932969853481399)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Tre subject) (Unit.impact 0.12407138654493885)
                        , \subject -> Expect.equal (Impact.getImpact Definition.Wtu subject) (Unit.impact 0.7436928514704245)
                        ]
                    |> asTest "should return computed impacts"
                ]
            ]
        )
