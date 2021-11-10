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
                    |> expectCo2 5.231201384993548
                    |> asTest "should compute co2 score for tShirtCotonFrance"
                , tShirtCotonEurope
                    |> expectCo2 8.275810631768893
                    |> asTest "should compute co2 score for tShirtCotonEurope"
                , tShirtCotonAsie
                    |> expectCo2 9.560762353559358
                    |> asTest "should compute co2 score for tShirtCotonAsie"
                , jupeCircuitAsie
                    |> expectCo2 33.16138385430519
                    |> asTest "should compute co2 score for jupeCircuitAsie"
                , manteauCircuitEurope
                    |> expectCo2 2068.4385835709104
                    |> asTest "should compute co2 score for manteauCircuitEurope"
                , pantalonCircuitEurope
                    |> expectCo2 25.228602127735577
                    |> asTest "should compute co2 score for pantalonCircuitEurope"
                , robeCircuitBangladesh
                    |> expectCo2 39.82171491582047
                    |> asTest "should compute co2 score for robeCircuitBangladesh"
                ]
            , describe "custom dyeing weighting"
                [ { tShirtCotonFrance | dyeingWeighting = Just 0.5 }
                    |> expectCo2 5.695092683843548
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom dyeing weighting"
                , { tShirtCotonEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 7.090266647102227
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom dyeing weighting"
                , { tShirtCotonAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 8.160289235559356
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom dyeing weighting"
                , { jupeCircuitAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 30.535496758055192
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom dyeing weighting"
                , { manteauCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 2061.399416161952
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom dyeing weighting"
                , { pantalonCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 22.13646090211057
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom dyeing weighting"
                , { robeCircuitBangladesh | dyeingWeighting = Just 0.5 }
                    |> expectCo2 42.429288768737145
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom dyeing weighting"
                ]
            , describe "custom air transport ratio"
                [ { tShirtCotonFrance | airTransportRatio = Just 0.5 }
                    |> expectCo2 5.275966847493548
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom air transport ratio"
                , { tShirtCotonEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 8.378638399445993
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom air transport ratio"
                , { tShirtCotonAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 9.817287513103118
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom air transport ratio"
                , { jupeCircuitAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 33.61407531232359
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom air transport ratio"
                , { manteauCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 2069.0132093314587
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom air transport ratio"
                , { pantalonCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 25.406537309666476
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom air transport ratio"
                , { robeCircuitBangladesh | airTransportRatio = Just 0.5 }
                    |> expectCo2 40.22279738067047
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom air transport ratio"
                ]
            , describe "custom recycled ratio"
                [ { tShirtCotonFrance | recycledRatio = Just 0 }
                    |> expectCo2 5.231201384993548
                    |> asTest "should compute co2 score for tShirtCotonFrance using no recycled ratio"
                , { tShirtCotonFrance | recycledRatio = Just 0.5 }
                    |> expectCo2 3.4545956055533633
                    |> asTest "should compute co2 score for tShirtCotonFrance using half recycled ratio"
                , { tShirtCotonFrance | recycledRatio = Just 1 }
                    |> expectCo2 1.48543991839824
                    |> asTest "should compute co2 score for tShirtCotonFrance using full recycled ratio"
                , { tShirtCotonEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 6.4992048523287105
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom recycled ratio"
                , { tShirtCotonAsie | recycledRatio = Just 0.5 }
                    |> expectCo2 7.784156574119172
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom recycled ratio"
                , { jupeCircuitAsie | recycledRatio = Just 0.5 }
                    |> expectCo2 31.109978958668865
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom recycled ratio"
                , { manteauCircuitEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 2068.4385835709104
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom recycled ratio"
                , { pantalonCircuitEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 25.228602127735577
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom recycled ratio"
                , { robeCircuitBangladesh | recycledRatio = Just 0.5 }
                    |> expectCo2 39.82171491582047
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom recycled ratio"
                ]
            , describe "custom country mix"
                [ describe "at the WeavingKnitting step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0))
                        |> expectCo2 5.192166584993548
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 5.432166584993548
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 6.008166584993548
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at the Dyeing step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0))
                        |> expectCo2 5.192166584993548
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 5.397974589160214
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 5.875974589160214
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at the Making step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0))
                        |> expectCo2 5.223069134993548
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 5.2730691349935475
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 5.393069134993548
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at multiple step levels"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0))
                        |> expectCo2 5.151640872493548
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0.5))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0.5))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 5.640807539160215
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 6.814807539160215
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                ]
            ]
        ]
