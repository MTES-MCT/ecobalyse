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
            [ { wearsPerCycle = 20, useDefaultNbCycles = 5 }
                |> Product.customDaysOfWear (Just 10)
                |> Expect.equal (Duration.days 200)
                |> asTest "should compute custom number of days of wear"
            , { wearsPerCycle = 20, useDefaultNbCycles = 5 }
                |> Product.customDaysOfWear (Just 0)
                |> Expect.equal (Duration.days 20)
                |> asTest "should compute custom number of days of wear when custom use cycles is 0"
            ]
        ]
