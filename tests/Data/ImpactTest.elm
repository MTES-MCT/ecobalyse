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
        (\{ textileDb } ->
            let
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
                    |> expectScoreEquals 14335.212731488828
                    |> asTest "should update EcoScore"
                , impacts
                    |> Impact.getImpact (Impact.trg "pef")
                    |> expectScoreEquals 17451.41187295143
                    |> asTest "should update PEF score"
                ]
            ]
        )
