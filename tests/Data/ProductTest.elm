module Data.ProductTest exposing (..)

import Data.Product as Product
import Data.Unit as Unit
import Duration
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Product"
        [ describe "customDaysOfWear"
            [ { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                |> Product.customDaysOfWear (Just (Unit.quality 1)) Nothing
                |> Expect.equal
                    { daysOfWear = Duration.days 100
                    , useNbCycles = 5
                    }
                |> asTest "should compute custom number of days of wear"
            , { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                |> Product.customDaysOfWear (Just (Unit.quality 0.8)) Nothing
                |> Expect.equal
                    { daysOfWear = Duration.days 80
                    , useNbCycles = 4
                    }
                |> asTest "should compute custom number of days of wear with custom quality"
            , { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                |> Product.customDaysOfWear Nothing (Just (Unit.reparability 1.2))
                |> Expect.equal
                    { daysOfWear = Duration.days 120
                    , useNbCycles = 6
                    }
                |> asTest "should compute custom number of days of wear with custom reparability"
            , { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                |> Product.customDaysOfWear (Just (Unit.quality 1.2)) (Just (Unit.reparability 1.2))
                |> Expect.equal
                    { daysOfWear = Duration.days 144
                    , useNbCycles = 7
                    }
                |> asTest "should compute custom number of days of wear with custom quality & reparability"
            ]
        ]
