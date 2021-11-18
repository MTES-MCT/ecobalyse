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
                    |> expectCo2 4.5333107618347
                    |> asTest "should compute co2 score for tShirtCotonFrance"
                , tShirtCotonEurope
                    |> expectCo2 7.572122801110047
                    |> asTest "should compute co2 score for tShirtCotonEurope"
                , tShirtCotonAsie
                    |> expectCo2 8.848230867900508
                    |> asTest "should compute co2 score for tShirtCotonAsie"
                , jupeCircuitAsie
                    |> expectCo2 32.013781769787556
                    |> asTest "should compute co2 score for jupeCircuitAsie"
                , manteauCircuitEurope
                    |> expectCo2 516.1201240213679
                    |> asTest "should compute co2 score for manteauCircuitEurope"
                , pantalonCircuitEurope
                    |> expectCo2 23.29205058562033
                    |> asTest "should compute co2 score for pantalonCircuitEurope"
                , robeCircuitBangladesh
                    |> expectCo2 38.428758689945475
                    |> asTest "should compute co2 score for robeCircuitBangladesh"
                ]
            , describe "custom dyeing weighting"
                [ { tShirtCotonFrance | dyeingWeighting = Just 0.5 }
                    |> expectCo2 4.9972020606847005
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom dyeing weighting"
                , { tShirtCotonEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 6.38657881644338
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom dyeing weighting"
                , { tShirtCotonAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 7.447757749900509
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom dyeing weighting"
                , { jupeCircuitAsie | dyeingWeighting = Just 0.5 }
                    |> expectCo2 29.387894673537556
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom dyeing weighting"
                , { manteauCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 509.08095661240975
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom dyeing weighting"
                , { pantalonCircuitEurope | dyeingWeighting = Just 0.5 }
                    |> expectCo2 20.19990935999533
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom dyeing weighting"
                , { robeCircuitBangladesh | dyeingWeighting = Just 0.5 }
                    |> expectCo2 41.03633254286215
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom dyeing weighting"
                ]
            , describe "custom air transport ratio"
                [ { tShirtCotonFrance | airTransportRatio = Just 0.5 }
                    |> expectCo2 4.5780762243347
                    |> asTest "should compute co2 score for tShirtCotonFrance using custom air transport ratio"
                , { tShirtCotonEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 7.674950568787147
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom air transport ratio"
                , { tShirtCotonAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 9.104756027444267
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom air transport ratio"
                , { jupeCircuitAsie | airTransportRatio = Just 0.5 }
                    |> expectCo2 32.466473227805956
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom air transport ratio"
                , { manteauCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 516.6947497819164
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom air transport ratio"
                , { pantalonCircuitEurope | airTransportRatio = Just 0.5 }
                    |> expectCo2 23.469985767551233
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom air transport ratio"
                , { robeCircuitBangladesh | airTransportRatio = Just 0.5 }
                    |> expectCo2 38.829841154795474
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom air transport ratio"
                ]
            , describe "custom recycled ratio"
                [ { tShirtCotonFrance | recycledRatio = Just 0 }
                    |> expectCo2 4.5333107618347
                    |> asTest "should compute co2 score for tShirtCotonFrance using no recycled ratio"
                , { tShirtCotonFrance | recycledRatio = Just 0.5 }
                    |> expectCo2 2.96018682757287
                    |> asTest "should compute co2 score for tShirtCotonFrance using half recycled ratio"
                , { tShirtCotonFrance | recycledRatio = Just 1 }
                    |> expectCo2 1.38706289331104
                    |> asTest "should compute co2 score for tShirtCotonFrance using full recycled ratio"
                , { tShirtCotonEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 5.9989988668482175
                    |> asTest "should compute co2 score for tShirtCotonEurope using custom recycled ratio"
                , { tShirtCotonAsie | recycledRatio = Just 0.5 }
                    |> expectCo2 7.275106933638679
                    |> asTest "should compute co2 score for tShirtCotonAsie using custom recycled ratio"
                , { jupeCircuitAsie | recycledRatio = Just 0.5 }
                    |> expectCo2 29.656624433271027
                    |> asTest "should compute co2 score for jupeCircuitAsie using custom recycled ratio"
                , { manteauCircuitEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 516.1201240213679
                    |> asTest "should compute co2 score for manteauCircuitEurope using custom recycled ratio"
                , { pantalonCircuitEurope | recycledRatio = Just 0.5 }
                    |> expectCo2 23.29205058562033
                    |> asTest "should compute co2 score for pantalonCircuitEurope using custom recycled ratio"
                , { robeCircuitBangladesh | recycledRatio = Just 0.5 }
                    |> expectCo2 38.428758689945475
                    |> asTest "should compute co2 score for robeCircuitBangladesh using custom recycled ratio"
                ]
            , describe "custom country mix"
                [ describe "at the WeavingKnitting step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.494275961834701
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.7342759618347
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 5.310275961834701
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at the Dyeing step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.5009172993347
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.700083966001367
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 5.178083966001367
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at the Making step"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.5263983493347
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.568898349334701
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 4.6708983493347
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                , describe "at multiple step levels"
                    [ tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0))
                        |> expectCo2 4.454970086834701
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0.5))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0.5))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0.5))
                        |> expectCo2 4.936636753501367
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                    , tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 1.7))
                        |> expectCo2 6.092636753501368
                        |> asTest "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                    ]
                ]
            ]
        ]
