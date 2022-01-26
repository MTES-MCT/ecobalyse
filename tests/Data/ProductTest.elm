module Data.ProductTest exposing (..)

import Data.Product as Product
import Duration
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Product"
        [ describe "customDaysOfWear"
            [ { daysOfWear = Duration.days 100, useDefaultNbCycles = 5 }
                |> Product.customDaysOfWear 10
                |> Expect.equal 200
                |> asTest "should compute custom number of days of wear"
            , { daysOfWear = Duration.days 100, useDefaultNbCycles = 0 }
                |> Product.customDaysOfWear 10
                |> Expect.within (Expect.Absolute 0.01) 1000
                |> asTest "should compute custom number of days of wear when custom use cycles is 0"
            ]
        ]
