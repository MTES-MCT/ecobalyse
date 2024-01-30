module Data.Textile.EconomicsTest exposing (..)

import Data.Textile.Economics as Economics exposing (..)
import Data.Unit as Unit
import Duration
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


expectRatioEqual : Float -> Unit.Ratio -> Expect.Expectation
expectRatioEqual val =
    Unit.ratioToFloat
        >> Expect.within (Expect.Absolute 0.01) val


suite : Test
suite =
    describe "Data.Textile.Economics"
        [ describe "computeDurabilityIndex"
            [ Economics.computeDurabilityIndex
                { business = SmallBusiness
                , marketingDuration = Duration.days 60
                , numberOfReferences = 20000
                , price = priceFromFloat 100
                , repairCost = priceFromFloat 10
                , traceability = False
                }
                |> Unit.durabilityToFloat
                |> Expect.within (Expect.Absolute 0.01) 0.825
                |> asTest "should compute durability index"
            ]
        , describe "computeMarketingDurationIndex"
            [ Economics.computeMarketingDurationIndex (Duration.days 60)
                |> expectRatioEqual 0
                |> asTest "should compute lowest ratio"
            , Economics.computeMarketingDurationIndex (Duration.days 120)
                |> expectRatioEqual 0.5
                |> asTest "should compute average ratio"
            , Economics.computeMarketingDurationIndex (Duration.days 180)
                |> expectRatioEqual 1
                |> asTest "should compute highest ratio"
            ]
        , describe "computeNumberOfReferencesIndex"
            [ Economics.computeNumberOfReferencesIndex 20000
                |> expectRatioEqual 0
                |> asTest "should compute lowest ratio"
            , Economics.computeNumberOfReferencesIndex 12500
                |> expectRatioEqual 0.5
                |> asTest "should compute average ratio"
            , Economics.computeNumberOfReferencesIndex 5000
                |> expectRatioEqual 1
                |> asTest "should compute highest ratio"
            ]
        , describe "computeRepairCostIndex"
            [ describe "for TPE/PME"
                [ computeRepairCostIndex SmallBusiness (priceFromFloat 100) (priceFromFloat 90)
                    |> expectRatioEqual 0
                    |> asTest "should compute lowest ratio"
                , computeRepairCostIndex SmallBusiness (priceFromFloat 100) (priceFromFloat 41.5)
                    |> expectRatioEqual 0.5
                    |> asTest "should compute average ratio"
                , computeRepairCostIndex SmallBusiness (priceFromFloat 100) (priceFromFloat 10)
                    |> expectRatioEqual 1
                    |> asTest "should compute highest ratio"
                ]
            , describe "for large businesses with service offerings"
                [ computeRepairCostIndex LargeBusinessWithServices (priceFromFloat 100) (priceFromFloat 90)
                    |> expectRatioEqual 0
                    |> asTest "should compute lowest ratio"
                , computeRepairCostIndex LargeBusinessWithServices (priceFromFloat 100) (priceFromFloat 41.5)
                    |> expectRatioEqual 0.5
                    |> asTest "should compute average ratio"
                , computeRepairCostIndex LargeBusinessWithServices (priceFromFloat 100) (priceFromFloat 10)
                    |> expectRatioEqual 1
                    |> asTest "should compute highest ratio"
                ]
            , describe "for large businesses with no service offerings"
                [ computeRepairCostIndex LargeBusinessWithoutServices (priceFromFloat 100) (priceFromFloat 90)
                    |> expectRatioEqual 0
                    |> asTest "should compute lowest ratio"
                , computeRepairCostIndex LargeBusinessWithoutServices (priceFromFloat 100) (priceFromFloat 41.5)
                    |> expectRatioEqual 0.335
                    |> asTest "should compute average ratio"
                , computeRepairCostIndex LargeBusinessWithoutServices (priceFromFloat 100) (priceFromFloat 10)
                    |> expectRatioEqual 0.67
                    |> asTest "should compute highest ratio"
                ]
            ]
        ]
