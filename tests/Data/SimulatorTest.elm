module Data.SimulatorTest exposing (..)

import Data.Country as Country
import Data.Inputs as Inputs exposing (Inputs)
import Data.Material as Material
import Data.Product as Product
import Data.Simulator as Simulator
import Expect exposing (Expectation)
import Route exposing (Route(..))
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


expectCo2 : Float -> Inputs -> Expectation
expectCo2 co2 =
    Simulator.fromInputs >> .co2 >> Expect.within (Expect.Absolute 0.01) co2


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
                |> expectCo2 23.57
                |> asTest "should compute co2 score for jupeCircuitAsie"
            , Inputs.manteauCircuitEurope
                |> expectCo2 2072.58
                |> asTest "should compute co2 score for manteauCircuitEurope"
            , Inputs.pantalonCircuitEurope
                |> expectCo2 24.35
                |> asTest "should compute co2 score for pantalonCircuitEurope"
            ]
        ]
