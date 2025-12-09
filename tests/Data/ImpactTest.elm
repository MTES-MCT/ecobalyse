module Data.ImpactTest exposing (..)

import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Split as Split
import Data.Unit as Unit
import Expect
import Mass
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Impact"
        (\db ->
            let
                defaultImpacts =
                    Impact.empty

                expectScoreEquals expectedValue testValue =
                    testValue
                        |> Unit.impactToFloat
                        |> Expect.within (Expect.Absolute 0.01) expectedValue
            in
            [ describe "mapImpacts"
                [ defaultImpacts
                    |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 1)
                    |> Impact.mapImpacts (\_ -> Quantity.multiplyBy 2)
                    |> Impact.getImpact Definition.Cch
                    |> Expect.equal (Unit.impact 2)
                    |> asTest "should map impacts"
                ]
            , describe "per100grams"
                [ defaultImpacts
                    |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 1)
                    |> Impact.per100grams (Mass.kilograms 2)
                    |> Impact.getImpact Definition.Cch
                    |> Expect.equal (Unit.impact 0.05)
                    |> asTest "should compute impacts per 100g of product"
                ]
            , describe "perKg"
                [ defaultImpacts
                    |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 1)
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
                    |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 9)
                    |> Impact.getImpact Definition.Cch
                    |> Expect.equal (Unit.impact 9)
                    |> asTest "should update a given impact"
                ]
            , let
                impacts =
                    defaultImpacts
                        |> Impact.updateImpact db.definitions Definition.Cch (Unit.impact 1)
                        |> Impact.updateImpact db.definitions Definition.Fwe (Unit.impact 1)
              in
              describe "updateAggregatedScores"
                [ impacts
                    |> Impact.getImpact Definition.Ecs
                    |> expectScoreEquals 13843.73355346908
                    |> asTest "should update EcoScore"
                ]
            , describe "total weighting for impacts' ecoscoreData"
                [ Definition.trigrams
                    |> List.map (\trigram -> Definition.get trigram db.definitions)
                    |> List.filterMap .ecoscoreData
                    |> List.map .weighting
                    |> List.map Split.toFloat
                    |> List.sum
                    |> Expect.within (Expect.Absolute 0.01) 1
                    |> asTest "should be 1"
                ]
            ]
        )
