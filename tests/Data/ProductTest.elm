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
            [ { daysOfWear = Duration.days 100, useDefaultNbCycles = 20 }
                |> Product.customDaysOfWear (Just (Unit.quality 1))
                |> Expect.equal
                    { daysOfWear = Duration.days 100
                    , useNbCycles = 5
                    }
                |> asTest "should compute custom number of days of wear"
            , { daysOfWear = Duration.days 100, useDefaultNbCycles = 20 }
                |> Product.customDaysOfWear (Just (Unit.quality 0.8))
                |> Expect.equal
                    { daysOfWear = Duration.days 80
                    , useNbCycles = 4
                    }
                |> asTest "should compute custom number of days of wear when custom quality is 0.8"
            ]
        ]
