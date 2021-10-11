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
                    |> expectCo2 5.28
                    |> asTest "should compute co2 score for tShirtCotonFrance"
                , tShirtCotonEurope
                    |> expectCo2 8.36
                    |> asTest "should compute co2 score for tShirtCotonEurope"
                , tShirtCotonAsie
                    |> expectCo2 9.68
                    |> asTest "should compute co2 score for tShirtCotonAsie"
                , jupeCircuitAsie
                    |> expectCo2 33.46
                    |> asTest "should compute co2 score for jupeCircuitAsie"
                , manteauCircuitEurope
                    |> expectCo2 2071.94
                    |> asTest "should compute co2 score for manteauCircuitEurope"
                , pantalonCircuitEurope
                    |> expectCo2 25.44
                    |> asTest "should compute co2 score for pantalonCircuitEurope"
                , robeCircuitBangladesh
                    |> expectCo2 39.98
                    |> asTest "should compute co2 score for robeCircuitBangladesh"
                ]
            , describe "custom dyeing weighting"
                [ { tShirtCotonFrance | dyeingWeighting = Just 0.5 }
                    |> expectCo2 5.74
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom dyeing weighting"
                , { tShirtCotonEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 7.18
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom dyeing weighting"
                , { tShirtCotonAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 8.28
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom dyeing weighting"
                , { jupeCircuitAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 30.84
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom dyeing weighting"
                , { manteauCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 2064.89
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom dyeing weighting"
                , { pantalonCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 22.34
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom dyeing weighting"
                , { robeCircuitBangladesh | dyeingWeighting = Just 0.5 }
                    |> expectCo2 42.59
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom dyeing weighting"
                ]
            , describe "custom air transport ratio"
                [ { tShirtCotonFrance | airTransportRatio = Just 0.5 }
                    |> expectCo2 5.33
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom air transport ratio"
                , { tShirtCotonEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 8.49
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom air transport ratio"
                , { tShirtCotonAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 9.99
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom air transport ratio"
                , { jupeCircuitAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 34.02
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom air transport ratio"
                , { manteauCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 2072.66
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom air transport ratio"
                , { pantalonCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 25.65
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom air transport ratio"
                , { robeCircuitBangladesh | airTransportRatio = Just 0.5 }
                    |> expectCo2 40.48
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom air transport ratio"
                ]
            ]
        ]
