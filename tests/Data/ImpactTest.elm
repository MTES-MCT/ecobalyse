module Data.ImpactTest exposing (..)

import Data.Impact.Definition as Definition
import Data.Impacts as Impacts
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
                    Impacts.empty

                expectScoreEquals expectedValue testValue =
                    testValue
                        |> Unit.impactToFloat
                        |> Expect.within (Expect.Absolute 0.01) expectedValue
            in
            [ describe "mapImpacts"
                [ defaultImpacts
                    |> Impacts.updateImpact db.definitions Definition.Cch (Unit.impact 1)
                    |> Impacts.mapImpacts (\_ -> Quantity.multiplyBy 2)
                    |> Impacts.getImpact Definition.Cch
                    |> Expect.equal (Unit.impact 2)
                    |> asTest "should map impacts"
                ]
            , describe "per100grams"
                [ defaultImpacts
                    |> Impacts.updateImpact db.definitions Definition.Cch (Unit.impact 1)
                    |> Impacts.per100grams (Mass.kilograms 2)
                    |> Impacts.getImpact Definition.Cch
                    |> Expect.equal (Unit.impact 0.05)
                    |> asTest "should compute impacts per 100g of product"
                ]
            , describe "perKg"
                [ defaultImpacts
                    |> Impacts.updateImpact db.definitions Definition.Cch (Unit.impact 1)
                    |> Impacts.perKg (Mass.kilograms 2)
                    |> Impacts.getImpact Definition.Cch
                    |> Expect.equal (Unit.impact 0.5)
                    |> asTest "should compute impacts per kg of product"
                ]
            , describe "sumImpacts"
                [ []
                    |> Impacts.sumImpacts
                    |> Expect.equal defaultImpacts
                    |> asTest "should sum an empty impacts list"
                , [ defaultImpacts |> Impacts.mapImpacts (\_ _ -> Unit.impact 1)
                  , defaultImpacts |> Impacts.mapImpacts (\_ _ -> Unit.impact 2)
                  ]
                    |> Impacts.sumImpacts
                    |> Expect.equal (defaultImpacts |> Impacts.mapImpacts (\_ _ -> Unit.impact 3))
                    |> asTest "should sum a non-empty impacts list"
                ]
            , describe "updateImpact"
                [ defaultImpacts
                    |> Impacts.updateImpact db.definitions Definition.Cch (Unit.impact 9)
                    |> Impacts.getImpact Definition.Cch
                    |> Expect.equal (Unit.impact 9)
                    |> asTest "should update a given impact"
                ]
            , let
                impacts =
                    defaultImpacts
                        |> Impacts.updateImpact db.definitions Definition.Cch (Unit.impact 1)
                        |> Impacts.updateImpact db.definitions Definition.Fwe (Unit.impact 1)
              in
              describe "updateAggregatedScores"
                [ impacts
                    |> Impacts.getImpact Definition.Ecs
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
