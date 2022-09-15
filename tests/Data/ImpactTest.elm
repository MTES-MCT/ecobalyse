module Data.ImpactTest exposing (..)

import Data.Impact as Impact
import Data.Unit as Unit
import Expect
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithTextileDb)


suite : Test
suite =
    suiteWithTextileDb "Data.Impact"
        (\db ->
            let
                defaultImpacts =
                    Impact.impactsFromDefinitons db.impacts

                expectPefScore expectedValue testValue =
                    testValue
                        |> Unit.impactToFloat
                        |> Expect.within (Expect.Absolute 0.01) expectedValue
            in
            [ describe "computePefScore"
                [ defaultImpacts
                    |> Impact.updateImpact (Impact.trg "cch") (Unit.impact 1)
                    |> Impact.computePefScore db.impacts
                    |> expectPefScore 26.014356070572276
                    |> asTest "should compute PEF score from cch impact"
                , defaultImpacts
                    |> Impact.updateImpact (Impact.trg "fwe") (Unit.impact 1)
                    |> Impact.computePefScore db.impacts
                    |> expectPefScore 17425.397516880857
                    |> asTest "should compute PEF score from fwe impact"
                ]
            , describe "mapImpacts"
                [ defaultImpacts
                    |> Impact.updateImpact (Impact.trg "cch") (Unit.impact 1)
                    |> Impact.mapImpacts (\_ -> Quantity.multiplyBy 2)
                    |> Impact.getImpact (Impact.trg "cch")
                    |> Expect.equal (Unit.impact 2)
                    |> asTest "should map impacts"
                ]
            , describe "sumImpacts"
                [ []
                    |> Impact.sumImpacts db.impacts
                    |> Expect.equal defaultImpacts
                    |> asTest "should sum an empty impacts list"
                , [ defaultImpacts |> Impact.mapImpacts (\_ _ -> Unit.impact 1)
                  , defaultImpacts |> Impact.mapImpacts (\_ _ -> Unit.impact 2)
                  ]
                    |> Impact.sumImpacts db.impacts
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
            , describe "updatePefImpact"
                [ defaultImpacts
                    |> Impact.updateImpact (Impact.trg "cch") (Unit.impact 1)
                    |> Impact.updateImpact (Impact.trg "fwe") (Unit.impact 1)
                    |> Impact.updatePefImpact db.impacts
                    |> Impact.getImpact (Impact.trg "pef")
                    |> expectPefScore 17451.41187295143
                    |> asTest "should update PEF impact score"
                ]
            ]
        )
