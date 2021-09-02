module Data.LifeCycleTest exposing (..)

import Data.Country exposing (..)
import Data.LifeCycle as LifeCycle
import Data.Step as Step
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Data.LifeCycle"
        [ describe "computeTransportSummary"
            [ test "should compute default distances" <|
                \_ ->
                    LifeCycle.default
                        |> LifeCycle.computeTransportSummary
                        |> Expect.equal
                            { air = 2706, road = 2000, sea = 21548 }
            , test "should compute custom distances" <|
                \_ ->
                    LifeCycle.default
                        |> LifeCycle.updateStepCountry Step.Ennoblement India
                        |> LifeCycle.computeTransportSummary
                        |> Expect.equal
                            { air = 3432, road = 1500, sea = 23234 }
            ]
        ]
