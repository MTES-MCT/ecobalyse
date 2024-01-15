module Data.Textile.ProductTest exposing (..)

import Data.Textile.Inputs as Inputs
import Data.Textile.Product as Product
import Duration
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


sampleQuery : Inputs.Query
sampleQuery =
    Inputs.tShirtCotonAsie


suite : Test
suite =
    describe "Data.Product"
        [ describe "customDaysOfWear"
            [ Product.customDaysOfWear { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                |> Expect.equal 5
                |> asTest "should compute custom number of days of wear"
            ]
        ]
