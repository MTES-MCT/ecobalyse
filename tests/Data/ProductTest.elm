module Data.ProductTest exposing (..)

import Data.Product as Product
import Duration
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


suite : List Test
suite =
    [ describe "customDaysOfWear"
        [ { daysOfWear = Duration.days 100, useDefaultNbCycles = 5 }
            |> Product.customDaysOfWear 10
            |> Expect.equal 200
            |> asTest "should compute custom number of days of wear"
        ]
    ]
