module Data.Textile.EconomicsTest exposing (..)

import Data.Textile.Economics as Economics exposing (..)
import Data.Unit as Unit
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
            [ Economics.computeNonPhysicalDurabilityIndex
                { business = SmallBusiness
                , numberOfReferences = 20000
                , price = priceFromFloat 100
                , repairCost = priceFromFloat 10
                }
                |> Unit.nonPhysicalDurabilityToFloat
                |> Expect.within (Expect.Absolute 0.01) 0.98
                |> asTest "should compute durability index"
            ]
        , describe "computeNumberOfReferencesIndex"
            ([ ( 1, 1 )
             , ( 500, 1 )
             , ( 750, 1 )
             , ( 1000, 1 )
             , ( 2000, 0.91 )
             , ( 3000, 0.83 )
             , ( 4500, 0.7 )
             , ( 7000, 0.5 )
             , ( 11500, 0.25 )
             , ( 16000, 0 )
             , ( 50000, 0 )
             , ( 100000, 0 )
             ]
                |> List.map
                    (\( n, expectedIndex ) ->
                        Economics.computeNumberOfReferencesIndex n
                            |> expectRatioEqual expectedIndex
                            |> asTest ("should compute n=" ++ String.fromInt n)
                    )
            )
        , describe "computeRepairCostIndex"
            [ describe "for TPE/PME"
                [ computeRepairCostIndex SmallBusiness (priceFromFloat 100) (priceFromFloat 90)
                    |> expectRatioEqual 0.054
                    |> asTest "should compute lowest ratio"
                , computeRepairCostIndex SmallBusiness (priceFromFloat 100) (priceFromFloat 41.5)
                    |> expectRatioEqual 0.69
                    |> asTest "should compute average ratio"
                , computeRepairCostIndex SmallBusiness (priceFromFloat 100) (priceFromFloat 10)
                    |> expectRatioEqual 1
                    |> asTest "should compute highest ratio"
                ]
            , describe "for large businesses with service offerings"
                [ computeRepairCostIndex LargeBusinessWithServices (priceFromFloat 100) (priceFromFloat 90)
                    |> expectRatioEqual 0.36
                    |> asTest "should compute lowest ratio"
                , computeRepairCostIndex LargeBusinessWithServices (priceFromFloat 100) (priceFromFloat 41.5)
                    |> expectRatioEqual 0.795
                    |> asTest "should compute average ratio"
                , computeRepairCostIndex LargeBusinessWithServices (priceFromFloat 100) (priceFromFloat 10)
                    |> expectRatioEqual 1
                    |> asTest "should compute highest ratio"
                ]
            , describe "for large businesses with no service offerings"
                [ computeRepairCostIndex LargeBusinessWithoutServices (priceFromFloat 100) (priceFromFloat 90)
                    |> expectRatioEqual 0.03
                    |> asTest "should compute lowest ratio"
                , computeRepairCostIndex LargeBusinessWithoutServices (priceFromFloat 100) (priceFromFloat 41.5)
                    |> expectRatioEqual 0.46
                    |> asTest "should compute average ratio"
                , computeRepairCostIndex LargeBusinessWithoutServices (priceFromFloat 100) (priceFromFloat 10)
                    |> expectRatioEqual 0.67
                    |> asTest "should compute highest ratio"
                ]
            ]
        ]
