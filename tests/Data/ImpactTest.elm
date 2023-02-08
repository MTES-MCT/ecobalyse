module Data.ImpactTest exposing (..)

import Data.Impact as Impact
import Data.Unit as Unit
import Expect
import Mass
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Impact"
        (\{ builderDb, textileDb } ->
            let
                defaultBuilderImpacts =
                    Impact.impactsFromDefinitons builderDb.impacts

                defaultImpacts =
                    Impact.impactsFromDefinitons textileDb.impacts

                expectScoreEquals expectedValue testValue =
                    testValue
                        |> Unit.impactToFloat
                        |> Expect.within (Expect.Absolute 0.01) expectedValue
            in
            [ describe "computeAggregatedScore"
                [ defaultImpacts
                    |> Impact.updateImpact (Impact.trg "cch") (Unit.impact 1)
                    |> Impact.computeAggregatedScore .pefData textileDb.impacts
                    |> expectScoreEquals 26.014356070572276
                    |> asTest "should compute aggregate score from cch impact"
                , defaultImpacts
                    |> Impact.updateImpact (Impact.trg "fwe") (Unit.impact 1)
                    |> Impact.computeAggregatedScore .pefData textileDb.impacts
                    |> expectScoreEquals 17425.397516880857
                    |> asTest "should compute aggregate score from fwe impact"
                ]
            , describe "mapImpacts"
                [ defaultImpacts
                    |> Impact.updateImpact (Impact.trg "cch") (Unit.impact 1)
                    |> Impact.mapImpacts (\_ -> Quantity.multiplyBy 2)
                    |> Impact.getImpact (Impact.trg "cch")
                    |> Expect.equal (Unit.impact 2)
                    |> asTest "should map impacts"
                ]
            , describe "perKg"
                [ defaultImpacts
                    |> Impact.updateImpact (Impact.trg "cch") (Unit.impact 1)
                    |> Impact.perKg (Mass.kilograms 2)
                    |> Impact.getImpact (Impact.trg "cch")
                    |> Expect.equal (Unit.impact 0.5)
                    |> asTest "should compute impacts per kg of product"
                ]
            , describe "sumImpacts"
                [ []
                    |> Impact.sumImpacts textileDb.impacts
                    |> Expect.equal defaultImpacts
                    |> asTest "should sum an empty impacts list"
                , [ defaultImpacts |> Impact.mapImpacts (\_ _ -> Unit.impact 1)
                  , defaultImpacts |> Impact.mapImpacts (\_ _ -> Unit.impact 2)
                  ]
                    |> Impact.sumImpacts textileDb.impacts
                    |> Expect.equal (defaultImpacts |> Impact.mapImpacts (\_ _ -> Unit.impact 3))
                    |> asTest "should sum a non-empty impacts list"
                ]
            , describe "updateImpact"
                [ defaultImpacts
                    |> Impact.updateImpact (Impact.trg "cch") (Unit.impact 9)
                    |> Impact.getImpact (Impact.trg "cch")
                    |> Expect.equal (Unit.impact 9)
                    |> asTest "should update a given impact"
                ]
            , let
                impacts =
                    defaultImpacts
                        |> Impact.updateImpact (Impact.trg "cch") (Unit.impact 1)
                        |> Impact.updateImpact (Impact.trg "fwe") (Unit.impact 1)
                        |> Impact.updateAggregatedScores textileDb.impacts
              in
              describe "updateAggregatedScores"
                [ impacts
                    |> Impact.getImpact (Impact.trg "ecs")
                    |> expectScoreEquals 9921.150803156486
                    |> asTest "should update EcoScore"
                , impacts
                    |> Impact.getImpact (Impact.trg "pef")
                    |> expectScoreEquals 17451.41187295143
                    |> asTest "should update PEF score"
                ]
            , describe "getAggregatedScoreOutOf100"
                [ defaultBuilderImpacts
                    |> Impact.updateImpact (Impact.trg "ecs") (Unit.impact 1)
                    |> Impact.getImpact (Impact.trg "ecs")
                    |> Impact.getAggregatedScoreOutOf100
                    |> Expect.equal 100
                    |> asTest "should return a score of 100 for a very low impact"
                , defaultBuilderImpacts
                    |> Impact.updateImpact (Impact.trg "ecs") (Unit.impact 10000)
                    |> Impact.getImpact (Impact.trg "ecs")
                    |> Impact.getAggregatedScoreOutOf100
                    |> Expect.equal 0
                    |> asTest "should return a score of 0 for a very high impact"
                , defaultBuilderImpacts
                    |> Impact.updateImpact (Impact.trg "ecs") (Unit.impact 200)
                    |> Impact.getImpact (Impact.trg "ecs")
                    |> Impact.getAggregatedScoreOutOf100
                    |> Expect.equal 67
                    |> asTest "should return a medium score for a medium impact"
                ]
            , describe "getAggregatedScoreLetter"
                [ Impact.getAggregatedScoreLetter 19
                    |> Expect.equal "E"
                    |> asTest "should return a letter E for anything below 20"
                , Impact.getAggregatedScoreLetter 39
                    |> Expect.equal "D"
                    |> asTest "should return a letter D for anything below 40"
                , Impact.getAggregatedScoreLetter 59
                    |> Expect.equal "C"
                    |> asTest "should return a letter C for anything below 60"
                , Impact.getAggregatedScoreLetter 79
                    |> Expect.equal "B"
                    |> asTest "should return a letter B for anything below 80"
                , Impact.getAggregatedScoreLetter 80
                    |> Expect.equal "A"
                    |> asTest "should return a letter C for anything equal or above 80"
                ]
            , describe "getBoundedScoreOutOf100"
                [ Unit.impact 500
                    |> Impact.getBoundedScoreOutOf100 { impact100 = 100, impact0 = 1000 }
                    |> Expect.equal 30
                    |> asTest "should compute an average bounded score"
                , Unit.impact 10000
                    |> Impact.getBoundedScoreOutOf100 { impact100 = 100, impact0 = 1000 }
                    |> Expect.equal 0
                    |> asTest "should compute an a very low bounded score from very high impact"
                , Unit.impact 1
                    |> Impact.getBoundedScoreOutOf100 { impact100 = 100, impact0 = 1000 }
                    |> Expect.equal 100
                    |> asTest "should compute an a high bounded score from very low impact"
                ]
            ]
        )
