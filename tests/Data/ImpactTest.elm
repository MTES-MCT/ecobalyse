module Data.ImpactTest exposing (..)

import Data.Impact as Impact
import Data.Unit as Unit
import Expect
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Impact"
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
                    |> expectPefScore 0.026
                    |> asTest "should compute PEF score from cch impact"
                , defaultImpacts
                    |> Impact.updateImpact (Impact.trg "fwe") (Unit.impact 1)
                    |> Impact.computePefScore db.impacts
                    |> expectPefScore 17.4
                    |> asTest "should compute PEF score from fwe impact"
                ]
            , describe "updatePefImpact"
                [ defaultImpacts
                    |> Impact.updateImpact (Impact.trg "cch") (Unit.impact 1)
                    |> Impact.updateImpact (Impact.trg "fwe") (Unit.impact 1)
                    |> Impact.updatePefImpact db.impacts
                    |> Impact.getImpact (Impact.trg "pef")
                    |> expectPefScore 17.42
                    |> asTest "should update PEF impact score"
                ]
            ]
        )
