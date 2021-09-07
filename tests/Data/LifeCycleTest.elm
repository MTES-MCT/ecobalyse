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
                        |> LifeCycle.computeTransportSummaries
                        |> LifeCycle.computeTransportSummary
                        |> Expect.equal
                            { air = 0, road = 4000, sea = 25548, co2 = 0 }
            , test "should compute custom distances" <|
                \_ ->
                    LifeCycle.default
                        |> LifeCycle.updateStepCountry Step.Ennoblement India
                        |> LifeCycle.computeTransportSummaries
                        |> LifeCycle.computeTransportSummary
                        |> Expect.equal
                            { air = 0, road = 3000, sea = 49468, co2 = 0 }
            ]
        ]
