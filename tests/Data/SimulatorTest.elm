module Data.SimulatorTest exposing (..)

import Data.Co2 as Co2
import Data.Inputs as Inputs exposing (..)
import Data.Simulator as Simulator
import Expect exposing (Expectation)
import Route exposing (Route(..))
import Test exposing (..)
import TestDb exposing (testDb)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


expectCo2 : Float -> Inputs.Query -> Expectation
expectCo2 co2 query =
    case testDb |> Result.andThen (\db -> Simulator.compute db query) of
        Ok simulator ->
            simulator.co2
                |> Co2.inKgCo2e
                |> Expect.within (Expect.Absolute 0.01) co2

        Err error ->
            Expect.fail error


suite : Test
suite =
    describe "Data.Simulator"
        [ describe "compute"
            [ describe "default dyeing weighting"
                [ tShirtCotonFrance
                    |> expectCo2 4.4140271789664345
                    |> asTest "should compute co2 score for tShirtCotonFrance"
                , tShirtCotonEurope
                    |> expectCo2 7.6132286257417805
                    |> asTest "should compute co2 score for tShirtCotonEurope"
                , tShirtCotonAsie
                    |> expectCo2 9.134011147532242
                    |> asTest "should compute co2 score for tShirtCotonAsie"
                , jupeCircuitAsie
                    |> expectCo2 32.22983649812159
                    |> asTest "should compute co2 score for jupeCircuitAsie"
                , manteauCircuitEurope
                    |> expectCo2 512.9529752362356
                    |> asTest "should compute co2 score for manteauCircuitEurope"
                , pantalonCircuitEurope
                    |> expectCo2 23.110224611211542
                    |> asTest "should compute co2 score for pantalonCircuitEurope"
                , robeCircuitBangladesh
                    |> expectCo2 38.38642250859547
                    |> asTest "should compute co2 score for robeCircuitBangladesh"
                ]
            , describe "custom dyeing weighting"
                [ { tShirtCotonFrance | dyeingWeighting = Just 0.5 }
                    |> expectCo2 4.877918477816435
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom dyeing weighting"
                , { tShirtCotonEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 6.427684641075113
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom dyeing weighting"
                , { tShirtCotonAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 7.733538029532242
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom dyeing weighting"
                , { jupeCircuitAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 29.603949401871592
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom dyeing weighting"
                , { manteauCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 505.91380782727737
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom dyeing weighting"
                , { pantalonCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 20.018083385586536
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom dyeing weighting"
                , { robeCircuitBangladesh | dyeingWeighting = Just 0.5 }
                    |> expectCo2 40.993996361512146
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom dyeing weighting"
                ]
            , describe "custom air transport ratio"
                [ { tShirtCotonFrance | airTransportRatio = Just 0.5 }
                    |> expectCo2 4.4587926414664345
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom air transport ratio"
                , { tShirtCotonEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 7.716056393418881
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom air transport ratio"
                , { tShirtCotonAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 9.390536307076001
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom air transport ratio"
                , { jupeCircuitAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 32.68252795613999
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom air transport ratio"
                , { manteauCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 513.527600996784
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom air transport ratio"
                , { pantalonCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 23.28815979314244
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom air transport ratio"
                , { robeCircuitBangladesh | airTransportRatio = Just 0.5 }
                    |> expectCo2 38.78750497344547
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom air transport ratio"
                ]
            , describe "custom recycled ratio"
                [ { tShirtCotonFrance | recycledRatio = Just 0 }
                    |> expectCo2 4.4140271789664345
                    |> asTest "should compute co2 score for tShirtCotonFrance using no recycled ratio"
                , { tShirtCotonFrance | recycledRatio = Just 0.5 }
                    |> expectCo2 2.8331446781664327
                    |> asTest "should compute co2 score for tShirtCotonFrance using half recycled ratio"
                , { tShirtCotonFrance | recycledRatio = Just 1 }
                    |> expectCo2 1.2522621773664322
                    |> asTest "should compute co2 score for tShirtCotonFrance using full recycled ratio"
                , { tShirtCotonEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 6.03234612494178
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom recycled ratio"
                , { tShirtCotonAsie | recycledRatio = Just 0.5 }
                    |> expectCo2 7.553128646732241
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom recycled ratio"
                , { jupeCircuitAsie | recycledRatio = Just 0.5 }
                    |> expectCo2 29.85703235030909
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom recycled ratio"
                , { manteauCircuitEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 512.9529752362356
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom recycled ratio"
                , { pantalonCircuitEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 23.110224611211542
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom recycled ratio"
                , { robeCircuitBangladesh | recycledRatio = Just 0.5 }
                    |> expectCo2 38.38642250859547
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom recycled ratio"
                ]
            , describe "custom country mix"
                [ describe "at the WeavingKnitting step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.374992378966434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.614992378966434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 5.190992378966434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at the Dyeing step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.3816337164664345
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.580800383133101
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 5.058800383133101
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at the Making step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.373365928966434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.623365928966434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 5.223365928966434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at multiple step levels"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.301937666466434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0.5))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0.5))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.991104333133101
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 6.6451043331331
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                ]
            ]
        ]
