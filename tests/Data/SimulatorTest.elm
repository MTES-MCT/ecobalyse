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
                    |> expectCo2 4.380278341466434
                    |> asTest "should compute co2 score for tShirtCotonFrance"
                , tShirtCotonEurope
                    |> expectCo2 7.419090380741781
                    |> asTest "should compute co2 score for tShirtCotonEurope"
                , tShirtCotonAsie
                    |> expectCo2 8.695198447532242
                    |> asTest "should compute co2 score for tShirtCotonAsie"
                , jupeCircuitAsie
                    |> expectCo2 31.77093357812159
                    |> asTest "should compute co2 score for jupeCircuitAsie"
                , manteauCircuitEurope
                    |> expectCo2 512.9321580027356
                    |> asTest "should compute co2 score for manteauCircuitEurope"
                , pantalonCircuitEurope
                    |> expectCo2 22.86914170321154
                    |> asTest "should compute co2 score for pantalonCircuitEurope"
                , robeCircuitBangladesh
                    |> expectCo2 38.02720960859548
                    |> asTest "should compute co2 score for robeCircuitBangladesh"
                ]
            , describe "custom dyeing weighting"
                [ { tShirtCotonFrance | dyeingWeighting = Just 0.5 }
                    |> expectCo2 4.8441696403164345
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom dyeing weighting"
                , { tShirtCotonEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 6.233546396075114
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom dyeing weighting"
                , { tShirtCotonAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 7.294725329532242
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom dyeing weighting"
                , { jupeCircuitAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 29.145046481871592
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom dyeing weighting"
                , { manteauCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 505.89299059377737
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom dyeing weighting"
                , { pantalonCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 19.77700047758654
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom dyeing weighting"
                , { robeCircuitBangladesh | dyeingWeighting = Just 0.5 }
                    |> expectCo2 40.63478346151215
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom dyeing weighting"
                ]
            , describe "custom air transport ratio"
                [ { tShirtCotonFrance | airTransportRatio = Just 0.5 }
                    |> expectCo2 4.425043803966434
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom air transport ratio"
                , { tShirtCotonEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 7.521918148418881
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom air transport ratio"
                , { tShirtCotonAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 8.951723607076001
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom air transport ratio"
                , { jupeCircuitAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 32.22362503613999
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom air transport ratio"
                , { manteauCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 513.506783763284
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom air transport ratio"
                , { pantalonCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 23.04707688514244
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom air transport ratio"
                , { robeCircuitBangladesh | airTransportRatio = Just 0.5 }
                    |> expectCo2 38.428292073445476
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom air transport ratio"
                ]
            , describe "custom recycled ratio"
                [ { tShirtCotonFrance | recycledRatio = Just 0 }
                    |> expectCo2 4.380278341466434
                    |> asTest "should compute co2 score for tShirtCotonFrance using no recycled ratio"
                , { tShirtCotonFrance | recycledRatio = Just 0.5 }
                    |> expectCo2 2.799395840666433
                    |> asTest "should compute co2 score for tShirtCotonFrance using half recycled ratio"
                , { tShirtCotonFrance | recycledRatio = Just 1 }
                    |> expectCo2 1.218513339866432
                    |> asTest "should compute co2 score for tShirtCotonFrance using full recycled ratio"
                , { tShirtCotonEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 5.83820787994178
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom recycled ratio"
                , { tShirtCotonAsie | recycledRatio = Just 0.5 }
                    |> expectCo2 7.114315946732241
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom recycled ratio"
                , { jupeCircuitAsie | recycledRatio = Just 0.5 }
                    |> expectCo2 29.39812943030909
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom recycled ratio"
                , { manteauCircuitEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 512.9321580027356
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom recycled ratio"
                , { pantalonCircuitEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 22.86914170321154
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom recycled ratio"
                , { robeCircuitBangladesh | recycledRatio = Just 0.5 }
                    |> expectCo2 38.02720960859548
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom recycled ratio"
                ]
            , describe "custom country mix"
                [ describe "at the WeavingKnitting step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.341243541466434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.581243541466434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 5.157243541466434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at the Dyeing step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.347884878966434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.547051545633101
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 5.025051545633101
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at the Making step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.373365928966434
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.415865928966435
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 4.517865928966434
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
                        |> expectCo2 4.783604333133101
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 5.9396043331331
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                ]
            ]
        ]
