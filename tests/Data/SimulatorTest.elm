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
                    |> expectCo2 5.19
                    |> asTest "should compute co2 score for tShirtCotonFrance"
                , tShirtCotonEurope
                    |> expectCo2 8.28
                    |> asTest "should compute co2 score for tShirtCotonEurope"
                , tShirtCotonAsie
                    |> expectCo2 9.63
                    |> asTest "should compute co2 score for tShirtCotonAsie"
                , jupeCircuitAsie
                    |> expectCo2 33.35
                    |> asTest "should compute co2 score for jupeCircuitAsie"
                , manteauCircuitEurope
                    |> expectCo2 2070.73
                    |> asTest "should compute co2 score for manteauCircuitEurope"
                , pantalonCircuitEurope
                    |> expectCo2 25.24
                    |> asTest "should compute co2 score for pantalonCircuitEurope"
                , robeCircuitBangladesh
                    |> expectCo2 39.92
                    |> asTest "should compute co2 score for robeCircuitBangladesh"
                ]
            , describe "custom dyeing weighting"
                [ { tShirtCotonFrance | dyeingWeighting = Just 0.5 }
                    |> expectCo2 5.65
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom dyeing weighting"
                , { tShirtCotonEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 7.1
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom dyeing weighting"
                , { tShirtCotonAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 8.22
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom dyeing weighting"
                , { jupeCircuitAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 30.73
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom dyeing weighting"
                , { manteauCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 2063.69
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom dyeing weighting"
                , { pantalonCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 22.14
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom dyeing weighting"
                , { robeCircuitBangladesh | dyeingWeighting = Just 0.5 }
                    |> expectCo2 42.52
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom dyeing weighting"
                ]
            , describe "custom air transport ratio"
                [ { tShirtCotonFrance | airTransportRatio = Just 0.5 }
                    |> expectCo2 5.24
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom air transport ratio"
                , { tShirtCotonEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 8.41
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom air transport ratio"
                , { tShirtCotonAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 9.94
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom air transport ratio"
                , { jupeCircuitAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 33.94
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom air transport ratio"
                , { manteauCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 2071.46
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom air transport ratio"
                , { pantalonCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 25.46
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom air transport ratio"
                , { robeCircuitBangladesh | airTransportRatio = Just 0.5 }
                    |> expectCo2 40.43
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom air transport ratio"
                ]
            ]
        ]
