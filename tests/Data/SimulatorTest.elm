module Data.SimulatorTest exposing (..)

import Data.Inputs exposing (..)
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
            [ describe "default dyeing weighting"
                [ tShirtCotonFrance
                    |> expectCo2 5.26
                    |> asTest "should compute co2 score for tShirtCotonFrance"
                , tShirtCotonEurope
                    |> expectCo2 8.33
                    |> asTest "should compute co2 score for tShirtCotonEurope"
                , tShirtCotonAsie
                    |> expectCo2 9.73
                    |> asTest "should compute co2 score for tShirtCotonAsie"
                , jupeCircuitAsie
                    |> expectCo2 33.55
                    |> asTest "should compute co2 score for jupeCircuitAsie"
                , manteauCircuitEurope
                    |> expectCo2 2071.72
                    |> asTest "should compute co2 score for manteauCircuitEurope"
                , pantalonCircuitEurope
                    |> expectCo2 25.44
                    |> asTest "should compute co2 score for pantalonCircuitEurope"
                , robeCircuitBangladesh
                    |> expectCo2 39.72
                    |> asTest "should compute co2 score for robeCircuitBangladesh"
                ]
            , describe "custom dyeing weighting"
                [ { tShirtCotonFrance | dyeingWeighting = Just 0.5 }
                    |> expectCo2 5.72
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom dyeing weighting"
                , { tShirtCotonEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 7.14
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom dyeing weighting"
                , { tShirtCotonAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 8.33
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom dyeing weighting"
                , { jupeCircuitAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 30.93
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom dyeing weighting"
                , { manteauCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 2064.69
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom dyeing weighting"
                , { pantalonCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 22.34
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom dyeing weighting"
                , { robeCircuitBangladesh | dyeingWeighting = Just 0.5 }
                    |> expectCo2 42.32
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom dyeing weighting"
                ]
            ]
        ]
