module Data.ProcessTest exposing (..)

import Data.Country exposing (..)
import Data.Process as Process
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Data.Process"
        [ describe "computeTransportSummary"
            [ test "should compute default distances" <|
                \_ ->
                    Process.default
                        |> Process.computeTransportSummary
                        |> Expect.equal
                            { air = 2706, road = 2000, sea = 21548 }
            , test "should compute custom distances" <|
                \_ ->
                    Process.default
                        |> Process.updateCountryAt "p3" India
                        |> Process.computeTransportSummary
                        |> Expect.equal
                            { air = 3432, road = 1500, sea = 23234 }
            ]
        ]
