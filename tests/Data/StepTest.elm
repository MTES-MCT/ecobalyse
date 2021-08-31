module Data.StepTest exposing (..)

import Data.Country exposing (..)
import Data.Step as Step
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Data.Step"
        [ describe "computeTransportSummary"
            [ test "should compute default distances" <|
                \_ ->
                    Step.default
                        |> Step.computeTransportSummary
                        |> Expect.equal
                            { air = 2706, road = 2000, sea = 21548 }
            , test "should compute custom distances" <|
                \_ ->
                    Step.default
                        |> Step.updateCountryAt "p3" India
                        |> Step.computeTransportSummary
                        |> Expect.equal
                            { air = 3432, road = 1500, sea = 23234 }
            ]
        ]
