module Data.Textile.ProductTest exposing (..)

import Data.Textile.Inputs as Inputs
import Data.Textile.Product as Product
import Data.Unit as Unit
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
            [ { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                |> Product.customDaysOfWear (Just (Unit.durability 1))
                |> Expect.equal
                    { daysOfWear = Duration.days 100
                    , useNbCycles = 5
                    }
                |> asTest "should compute custom number of days of wear"
            , { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                |> Product.customDaysOfWear (Just (Unit.durability 0.8))
                |> Expect.equal
                    { daysOfWear = Duration.days 80
                    , useNbCycles = 4
                    }
                |> asTest "should compute custom number of days of wear with custom quality"
            ]
        ]
