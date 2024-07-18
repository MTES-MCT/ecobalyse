module Data.Textile.EconomicsTest exposing (..)

import Data.Split as Split
import Data.Textile.Economics as Economics exposing (..)
import Data.Textile.Material.Origin exposing (defaultShares)
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
            [ Economics.computeDurabilityIndex defaultShares
                { business = SmallBusiness
                , numberOfReferences = 20000
                , price = priceFromFloat 100
                , repairCost = priceFromFloat 10
                , traceability = False
                }
                |> Unit.durabilityToFloat
                |> Expect.within (Expect.Absolute 0.01) 0.8
                |> asTest "should compute durability index"
            ]
        , describe "computeMaterialsOriginIndex"
            [ Economics.computeMaterialsOriginIndex { defaultShares | synthetic = Split.full }
                |> Tuple.first
                |> expectRatioEqual 0
                |> asTest "should compute lowest ratio"
            , Economics.computeMaterialsOriginIndex { defaultShares | naturalFromVegetal = Split.full }
                |> Tuple.first
                |> expectRatioEqual 0.5
                |> asTest "should compute average ratio"
            , Economics.computeMaterialsOriginIndex { defaultShares | naturalFromAnimal = Split.full }
                |> Tuple.first
                |> expectRatioEqual 1
                |> asTest "should compute highest ratio"
            ]
        , describe "computeNumberOfReferencesIndex"
            ([ ( 1, 1 )
             , ( 3000, 1 )
             , ( 3001, 0.999 )
             , ( 4500, 0.9 )
             , ( 5999, 0.801 )
             , ( 6000, 0.8 )
             , ( 7500, 0.525 )
             , ( 8000, 0.433 )
             , ( 9000, 0.25 )
             , ( 10500, 0.125 )
             , ( 11500, 0.041 )
             , ( 12000, 0 )
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
                    |> expectRatioEqual 0.33
                    |> asTest "should compute lowest ratio"
                , computeRepairCostIndex LargeBusinessWithServices (priceFromFloat 100) (priceFromFloat 41.5)
                    |> expectRatioEqual 0.665
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
