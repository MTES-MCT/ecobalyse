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
                            { road = 2000, air = 8200, sea = 21548 }
            , test "should compute custom distances" <|
                \_ ->
                    Process.default
                        |> Process.updateCountryAt "p3" India
                        |> Process.computeTransportSummary
                        |> Expect.equal
                            { road = 1000, air = 21400, sea = 45468 }
            ]
        ]
