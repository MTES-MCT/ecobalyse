module Data.ImpactSetTest exposing (..)

import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.ImpactSet as ImpactSet
import Data.Split as Split
import Expect
import Mass
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.ImpactSet"
        (\db ->
            let
                defaultImpacts =
                    ImpactSet.empty

                expectScoreEquals expectedValue testValue =
                    testValue
                        |> Impact.toFloat
                        |> Expect.within (Expect.Absolute 0.01) expectedValue
            in
            [ describe "update"
                [ defaultImpacts
                    |> ImpactSet.update db.definitions Definition.Cch (Impact.fromFloat 1)
                    |> ImpactSet.mapImpacts (\_ -> Quantity.multiplyBy 2)
                    |> ImpactSet.getImpact Definition.Cch
                    |> Expect.equal (Impact.fromFloat 2)
                    |> asTest "should map impacts"
                ]
            , describe "per100grams"
                [ defaultImpacts
                    |> ImpactSet.update db.definitions Definition.Cch (Impact.fromFloat 1)
                    |> ImpactSet.per100grams (Mass.kilograms 2)
                    |> ImpactSet.getImpact Definition.Cch
                    |> Expect.equal (Impact.fromFloat 0.05)
                    |> asTest "should compute impacts per 100g of product"
                ]
            , describe "perKg"
                [ defaultImpacts
                    |> ImpactSet.update db.definitions Definition.Cch (Impact.fromFloat 1)
                    |> ImpactSet.perKg (Mass.kilograms 2)
                    |> ImpactSet.getImpact Definition.Cch
                    |> Expect.equal (Impact.fromFloat 0.5)
                    |> asTest "should compute impacts per kg of product"
                ]
            , describe "sumImpacts"
                [ []
                    |> ImpactSet.sumImpacts
                    |> Expect.equal defaultImpacts
                    |> asTest "should sum an empty impacts list"
                , [ defaultImpacts |> ImpactSet.mapImpacts (\_ _ -> Impact.fromFloat 1)
                  , defaultImpacts |> ImpactSet.mapImpacts (\_ _ -> Impact.fromFloat 2)
                  ]
                    |> ImpactSet.sumImpacts
                    |> Expect.equal (defaultImpacts |> ImpactSet.mapImpacts (\_ _ -> Impact.fromFloat 3))
                    |> asTest "should sum a non-empty impacts list"
                ]
            , describe "updateImpact"
                [ defaultImpacts
                    |> ImpactSet.update db.definitions Definition.Cch (Impact.fromFloat 9)
                    |> ImpactSet.getImpact Definition.Cch
                    |> Expect.equal (Impact.fromFloat 9)
                    |> asTest "should update a given impact"
                ]
            , let
                impacts =
                    defaultImpacts
                        |> ImpactSet.update db.definitions Definition.Cch (Impact.fromFloat 1)
                        |> ImpactSet.update db.definitions Definition.Fwe (Impact.fromFloat 1)
              in
              describe "updateAggregatedScores"
                [ impacts
                    |> ImpactSet.getImpact Definition.Ecs
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
