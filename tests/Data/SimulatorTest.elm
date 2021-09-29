module Data.SimulatorTest exposing (..)

import Data.Inputs as Inputs exposing (Inputs)
import Data.Simulator as Simulator
import Expect exposing (Expectation)
import Route exposing (Route(..))
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


expectCo2 : Float -> Inputs -> Expectation
expectCo2 co2 =
    Simulator.compute >> .co2 >> Expect.within (Expect.Absolute 0.01) co2


suite : Test
suite =
    describe "Data.Simulator"
        [ describe "compute"
            [ Inputs.tShirtCotonFrance
                |> expectCo2 5.26
                |> asTest "should compute co2 score for tShirtCotonFrance"
            , Inputs.tShirtCotonEurope
                |> expectCo2 8.33
                |> asTest "should compute co2 score for tShirtCotonEurope"
            , Inputs.tShirtCotonAsie
                |> expectCo2 9.73
                |> asTest "should compute co2 score for tShirtCotonAsie"
            , Inputs.jupeCircuitAsie
                |> expectCo2 33.55
                |> asTest "should compute co2 score for jupeCircuitAsie"
            , Inputs.manteauCircuitEurope
                |> expectCo2 2071.72
                |> asTest "should compute co2 score for manteauCircuitEurope"
            , Inputs.pantalonCircuitEurope
                |> expectCo2 25.49
                |> asTest "should compute co2 score for pantalonCircuitEurope"
            , Inputs.robeCircuitBangladesh
                |> expectCo2 39.72
                |> asTest "should compute co2 score for robeCircuitBangladesh"
            ]
        ]
