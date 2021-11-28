module Data.Sample exposing (..)

import Data.Co2 as Co2 exposing (Co2e)
import Data.Inputs as Inputs exposing (..)


type alias SampleData =
    { query : Query, expected : Co2e }


type SectionOrSample
    = Section String (List SectionOrSample)
    | Sample String SampleData


section : String -> List SectionOrSample -> SectionOrSample
section =
    Section


sample : String -> SampleData -> SectionOrSample
sample =
    Sample


samples : List SectionOrSample
samples =
    [ section "default dyeing weighting"
        [ sample "co2 score for tShirtCotonFrance"
            { query = tShirtCotonFrance
            , expected = Co2.kgCo2e 4.4140271789664345
            }
        , sample "co2 score for tShirtCotonEurope"
            { query = tShirtCotonEurope
            , expected = Co2.kgCo2e 7.6132286257417805
            }
        , sample "co2 score for tShirtCotonAsie"
            { query = tShirtCotonAsie
            , expected = Co2.kgCo2e 9.134011147532242
            }
        , sample "co2 score for jupeCircuitAsie"
            { query = jupeCircuitAsie
            , expected = Co2.kgCo2e 32.22983649812159
            }
        , sample "co2 score for manteauCircuitEurope"
            { query = manteauCircuitEurope
            , expected = Co2.kgCo2e 512.9529752362356
            }
        , sample "co2 score for pantalonCircuitEurope"
            { query = pantalonCircuitEurope
            , expected = Co2.kgCo2e 23.110224611211542
            }
        , sample "co2 score for robeCircuitBangladesh"
            { query = robeCircuitBangladesh
            , expected = Co2.kgCo2e 38.38642250859547
            }
        ]
    , section "custom dyeing weighting"
        [ sample "co2 score for tShirtCotonFrance using custom dyeing weighting"
            { query = { tShirtCotonFrance | dyeingWeighting = Just 0.5 }
            , expected = Co2.kgCo2e 4.877918477816435
            }
        , sample "co2 score for tShirtCotonEurope using custom dyeing weighting"
            { query = { tShirtCotonEurope | dyeingWeighting = Just 0.5 }
            , expected = Co2.kgCo2e 6.427684641075113
            }
        , sample "co2 score for tShirtCotonAsie using custom dyeing weighting"
            { query = { tShirtCotonAsie | dyeingWeighting = Just 0.5 }
            , expected = Co2.kgCo2e 7.733538029532242
            }
        , sample "co2 score for jupeCircuitAsie using custom dyeing weighting"
            { query = { jupeCircuitAsie | dyeingWeighting = Just 0.5 }
            , expected = Co2.kgCo2e 29.603949401871592
            }
        , sample "co2 score for manteauCircuitEurope using custom dyeing weighting"
            { query = { manteauCircuitEurope | dyeingWeighting = Just 0.5 }
            , expected = Co2.kgCo2e 505.91380782727737
            }
        , sample "co2 score for pantalonCircuitEurope using custom dyeing weighting"
            { query = { pantalonCircuitEurope | dyeingWeighting = Just 0.5 }
            , expected = Co2.kgCo2e 20.018083385586536
            }
        , sample "co2 score for robeCircuitBangladesh using custom dyeing weighting"
            { query = { robeCircuitBangladesh | dyeingWeighting = Just 0.5 }
            , expected = Co2.kgCo2e 40.993996361512146
            }
        ]
    , section "custom air transport ratio"
        [ sample "co2 score for tShirtCotonFrance using custom air transport ratio"
            { query = { tShirtCotonFrance | airTransportRatio = Just 0.5 }
            , expected = Co2.kgCo2e 4.4587926414664345
            }
        , sample "co2 score for tShirtCotonEurope using custom air transport ratio"
            { query = { tShirtCotonEurope | airTransportRatio = Just 0.5 }
            , expected = Co2.kgCo2e 7.716056393418881
            }
        , sample "co2 score for tShirtCotonAsie using custom air transport ratio"
            { query = { tShirtCotonAsie | airTransportRatio = Just 0.5 }
            , expected = Co2.kgCo2e 9.390536307076001
            }
        , sample "co2 score for jupeCircuitAsie using custom air transport ratio"
            { query = { jupeCircuitAsie | airTransportRatio = Just 0.5 }
            , expected = Co2.kgCo2e 32.68252795613999
            }
        , sample "co2 score for manteauCircuitEurope using custom air transport ratio"
            { query = { manteauCircuitEurope | airTransportRatio = Just 0.5 }
            , expected = Co2.kgCo2e 513.527600996784
            }
        , sample "co2 score for pantalonCircuitEurope using custom air transport ratio"
            { query = { pantalonCircuitEurope | airTransportRatio = Just 0.5 }
            , expected = Co2.kgCo2e 23.28815979314244
            }
        , sample "co2 score for robeCircuitBangladesh using custom air transport ratio"
            { query = { robeCircuitBangladesh | airTransportRatio = Just 0.5 }
            , expected = Co2.kgCo2e 38.78750497344547
            }
        ]
    , section "custom recycled ratio"
        [ sample "co2 score for tShirtCotonFrance using no recycled ratio"
            { query = { tShirtCotonFrance | recycledRatio = Just 0 }
            , expected = Co2.kgCo2e 4.4140271789664345
            }
        , sample "co2 score for tShirtCotonFrance using half recycled ratio"
            { query = { tShirtCotonFrance | recycledRatio = Just 0.5 }
            , expected = Co2.kgCo2e 2.8331446781664327
            }
        , sample "co2 score for tShirtCotonFrance using full recycled ratio"
            { query = { tShirtCotonFrance | recycledRatio = Just 1 }
            , expected = Co2.kgCo2e 1.2522621773664322
            }
        , sample "co2 score for tShirtCotonEurope using custom recycled ratio"
            { query = { tShirtCotonEurope | recycledRatio = Just 0.5 }
            , expected = Co2.kgCo2e 6.03234612494178
            }
        , sample "co2 score for tShirtCotonAsie using custom recycled ratio"
            { query = { tShirtCotonAsie | recycledRatio = Just 0.5 }
            , expected = Co2.kgCo2e 7.553128646732241
            }
        , sample "co2 score for jupeCircuitAsie using custom recycled ratio"
            { query = { jupeCircuitAsie | recycledRatio = Just 0.5 }
            , expected = Co2.kgCo2e 29.85703235030909
            }
        , sample "co2 score for manteauCircuitEurope using custom recycled ratio"
            { query = { manteauCircuitEurope | recycledRatio = Just 0.5 }
            , expected = Co2.kgCo2e 512.9529752362356
            }
        , sample "co2 score for pantalonCircuitEurope using custom recycled ratio"
            { query = { pantalonCircuitEurope | recycledRatio = Just 0.5 }
            , expected = Co2.kgCo2e 23.110224611211542
            }
        , sample "co2 score for robeCircuitBangladesh using custom recycled ratio"
            { query = { robeCircuitBangladesh | recycledRatio = Just 0.5 }
            , expected = Co2.kgCo2e 38.38642250859547
            }
        ]
    , section "custom country mix"
        [ Section "at the WeavingKnitting step"
            [ sample "co2 score for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0))
                , expected = Co2.kgCo2e 4.374992378966434
                }
            , sample "co2 score for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0.5))
                , expected = Co2.kgCo2e 4.614992378966434
                }
            , sample "co2 score for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 1.7))
                , expected = Co2.kgCo2e 5.190992378966434
                }
            ]
        , section "at the Dyeing step"
            [ sample "co2 score for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0))
                , expected = Co2.kgCo2e 4.3816337164664345
                }
            , sample "co2 score for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0.5))
                , expected = Co2.kgCo2e 4.580800383133101
                }
            , sample "co2 score for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 1.7))
                , expected = Co2.kgCo2e 5.058800383133101
                }
            ]
        , section "at the Making step"
            [ sample "co2 score for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0))
                , expected = Co2.kgCo2e 4.373365928966434
                }
            , sample "co2 score for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0.5))
                , expected = Co2.kgCo2e 4.623365928966434
                }
            , sample "co2 score for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 1.7))
                , expected = Co2.kgCo2e 5.223365928966434
                }
            ]
        , section "at multiple step levels"
            [ sample "should compute co2 score for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0))
                , expected = Co2.kgCo2e 4.301937666466434
                }
            , sample "should compute co2 score for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 0.5))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 0.5))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 0.5))
                , expected = Co2.kgCo2e 4.991104333133101
                }
            , sample "should compute co2 score for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Co2.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 2 (Just (Co2.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 3 (Just (Co2.kgCo2e 1.7))
                , expected = Co2.kgCo2e 6.6451043331331
                }
            ]
        ]
    ]
