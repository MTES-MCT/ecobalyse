module Data.ImpactTest exposing (..)

import Data.Impact as Impact
import Data.Impact.Definition as Definition
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
                    Impact.empty

                expectScoreEquals expectedValue testValue =
                    testValue
                        |> Unit.impactToFloat
                        |> Expect.within (Expect.Absolute 0.01) expectedValue
            in
            [ describe "computeAggregatedScore"
                [ defaultImpacts
                    |> Impact.updateImpact textileDb.impactDefinitions Definition.Cch (Unit.impact 1)
                    |> Impact.getImpact Definition.Pef
                    |> expectScoreEquals 27.88266508497196
                    |> asTest "should compute aggregate score from cch impact"
                , defaultImpacts
                    |> Impact.updateImpact textileDb.impactDefinitions Definition.Fwe (Unit.impact 1)
                    |> Impact.getImpact Definition.Pef
                    |> expectScoreEquals 17425.397516880857
                    |> asTest "should compute aggregate score from fwe impact"
                ]
            , describe "mapImpacts"
                [ defaultImpacts
                    |> Impact.updateImpact textileDb.impactDefinitions Definition.Cch (Unit.impact 1)
                    |> Impact.mapImpacts (\_ -> Quantity.multiplyBy 2)
                    |> Impact.getImpact Definition.Cch
                    |> Expect.equal (Unit.impact 2)
                    |> asTest "should map impacts"
                ]
            , describe "perKg"
                [ defaultImpacts
                    |> Impact.updateImpact textileDb.impactDefinitions Definition.Cch (Unit.impact 1)
                    |> Impact.perKg (Mass.kilograms 2)
                    |> Impact.getImpact Definition.Cch
                    |> Expect.equal (Unit.impact 0.5)
                    |> asTest "should compute impacts per kg of product"
                ]
            , describe "sumImpacts"
                [ []
                    |> Impact.sumImpacts
                    |> Expect.equal defaultImpacts
                    |> asTest "should sum an empty impacts list"
                , [ defaultImpacts |> Impact.mapImpacts (\_ _ -> Unit.impact 1)
                  , defaultImpacts |> Impact.mapImpacts (\_ _ -> Unit.impact 2)
                  ]
                    |> Impact.sumImpacts
                    |> Expect.equal (defaultImpacts |> Impact.mapImpacts (\_ _ -> Unit.impact 3))
                    |> asTest "should sum a non-empty impacts list"
                ]
            , describe "updateImpact"
                [ defaultImpacts
                    |> Impact.updateImpact textileDb.impactDefinitions Definition.Cch (Unit.impact 9)
                    |> Impact.getImpact Definition.Cch
                    |> Expect.equal (Unit.impact 9)
                    |> asTest "should update a given impact"
                ]
            , let
                impacts =
                    defaultImpacts
                        |> Impact.updateImpact textileDb.impactDefinitions Definition.Cch (Unit.impact 1)
                        |> Impact.updateImpact textileDb.impactDefinitions Definition.Fwe (Unit.impact 1)
              in
              describe "updateAggregatedScores"
                [ impacts
                    |> Impact.getImpact Definition.Ecs
                    |> expectScoreEquals 12910.230115064745
                    |> asTest "should update EcoScore"
                , impacts
                    |> Impact.getImpact Definition.Pef
                    |> expectScoreEquals 17453.28018196583
                    |> asTest "should update PEF score"
                ]
            , describe "total weighting for impacts' ecoscoreData"
                [ Definition.trigrams
                    |> List.map (Definition.get textileDb.impactDefinitions)
                    |> List.filterMap .ecoscoreData
                    |> List.map .weighting
                    |> List.map Unit.ratioToFloat
                    |> List.sum
                    |> Expect.within (Expect.Absolute 0.01) 1
                    |> asTest "should be 1"
                ]
            , describe "total weighting for impacts' pefData"
                [ Definition.trigrams
                    |> List.map (Definition.get textileDb.impactDefinitions)
                    |> List.filterMap .pefData
                    |> List.map .weighting
                    |> List.map Unit.ratioToFloat
                    |> List.sum
                    |> Expect.within (Expect.Absolute 0.01) 1
                    |> asTest "should be 1"
                ]
            ]
        )
