module Data.Sample exposing (..)

import Data.Inputs as Inputs exposing (..)
import Data.Unit as Unit


type alias SampleData =
    { query : Query
    , co2 : Unit.Co2e
    , fwe : Unit.Pe
    }


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
    [ section "Aucun paramétrage personnalisé"
        [ sample "impacts for tShirtCotonFrance"
            { query = tShirtCotonFrance
            , co2 = Unit.kgCo2e 4.4140271789664345
            , fwe = Unit.kgPe 0.0003521486305115451
            }
        , sample "impacts for tShirtCotonEurope"
            { query = tShirtCotonEurope
            , co2 = Unit.kgCo2e 7.64890610786178
            , fwe = Unit.kgPe 0.0006161214340873961
            }
        , sample "impacts for tShirtCotonAsie"
            { query = tShirtCotonAsie
            , co2 = Unit.kgCo2e 9.134011147532242
            , fwe = Unit.kgPe 0.0006163020477764167
            }
        , sample "impacts for jupeCircuitAsie"
            { query = jupeCircuitAsie
            , co2 = Unit.kgCo2e 32.22983649812159
            , fwe = Unit.kgPe 0.0006626107681986996
            }
        , sample "impacts for manteauCircuitEurope"
            { query = manteauCircuitEurope
            , co2 = Unit.kgCo2e 513.1648102863231
            , fwe = Unit.kgPe 0.0028863508114862564
            }
        , sample "impacts for pantalonCircuitEurope"
            { query = pantalonCircuitEurope
            , co2 = Unit.kgCo2e 23.110224611211542
            , fwe = Unit.kgPe 0.001538902892541837
            }
        , sample "impacts for robeCircuitBangladesh"
            { query = robeCircuitBangladesh
            , co2 = Unit.kgCo2e 39.709802008995126
            , fwe = Unit.kgPe 0.0002608076513636336
            }
        ]
    , section "Majoration de teinture personnalisée"
        [ sample "impacts for tShirtCotonFrance using custom dyeing weighting"
            { query = { tShirtCotonFrance | dyeingWeighting = Just 0.5 }
            , co2 = Unit.kgCo2e 4.877918477816435
            , fwe = Unit.kgPe 0.00048420985564356846
            }
        , sample "impacts for tShirtCotonEurope using custom dyeing weighting"
            { query = { tShirtCotonEurope | dyeingWeighting = Just 0.5 }
            , co2 = Unit.kgCo2e 6.463362123195113
            , fwe = Unit.kgPe 0.00048408368308020954
            }
        , sample "impacts for tShirtCotonAsie using custom dyeing weighting"
            { query = { tShirtCotonAsie | dyeingWeighting = Just 0.5 }
            , co2 = Unit.kgCo2e 7.733538029532242
            , fwe = Unit.kgPe 0.0004842569335390633
            }
        , sample "impacts for jupeCircuitAsie using custom dyeing weighting"
            { query = { jupeCircuitAsie | dyeingWeighting = Just 0.5 }
            , co2 = Unit.kgCo2e 29.603949401871592
            , fwe = Unit.kgPe 0.00041502617900366224
            }
        , sample "impacts for manteauCircuitEurope using custom dyeing weighting"
            { query = { manteauCircuitEurope | dyeingWeighting = Just 0.5 }
            , co2 = Unit.kgCo2e 506.1256428773649
            , fwe = Unit.kgPe 0.002102376664881086
            }
        , sample "impacts for pantalonCircuitEurope using custom dyeing weighting"
            { query = { pantalonCircuitEurope | dyeingWeighting = Just 0.5 }
            , co2 = Unit.kgCo2e 20.018083385586536
            , fwe = Unit.kgPe 0.0011675520699323278
            }
        , sample "impacts for robeCircuitBangladesh using custom dyeing weighting"
            { query = { robeCircuitBangladesh | dyeingWeighting = Just 0.5 }
            , co2 = Unit.kgCo2e 42.31737586191179
            , fwe = Unit.kgPe 0.0006734506677003212
            }
        ]
    , section "Transport aérien personnalisé"
        [ sample "impacts for tShirtCotonFrance using custom air transport ratio"
            { query = { tShirtCotonFrance | airTransportRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 4.4587926414664345
            , fwe = Unit.kgPe 0.0003521474420415451
            }
        , sample "impacts for tShirtCotonEurope using custom air transport ratio"
            { query = { tShirtCotonEurope | airTransportRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 7.75173387553888
            , fwe = Unit.kgPe 0.0006161245568596139
            }
        , sample "impacts for tShirtCotonAsie using custom air transport ratio"
            { query = { tShirtCotonAsie | airTransportRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 9.390536307076001
            , fwe = Unit.kgPe 0.0006163353667731165
            }
        , sample "impacts for jupeCircuitAsie using custom air transport ratio"
            { query = { jupeCircuitAsie | airTransportRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 32.68252795613999
            , fwe = Unit.kgPe 0.0006626695664281698
            }
        , sample "impacts for manteauCircuitEurope using custom air transport ratio"
            { query = { manteauCircuitEurope | airTransportRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 513.7394360468716
            , fwe = Unit.kgPe 0.0028863682622721795
            }
        , sample "impacts for pantalonCircuitEurope using custom air transport ratio"
            { query = { pantalonCircuitEurope | airTransportRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 23.28815979314244
            , fwe = Unit.kgPe 0.0015389172940433644
            }
        , sample "impacts for robeCircuitBangladesh using custom air transport ratio"
            { query = { robeCircuitBangladesh | airTransportRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 40.110884473845125
            , fwe = Unit.kgPe 0.0002608599404572461
            }
        ]
    , section "Part de matière recyclée personnalisée"
        [ sample "impacts for tShirtCotonFrance using no recycled ratio"
            { query = { tShirtCotonFrance | recycledRatio = Just 0 }
            , co2 = Unit.kgCo2e 4.4140271789664345
            , fwe = Unit.kgPe 0.0003521486305115451
            }
        , sample "impacts for tShirtCotonFrance using half recycled ratio"
            { query = { tShirtCotonFrance | recycledRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 2.8331446781664327
            , fwe = Unit.kgPe 0.00022337969643154514
            }
        , sample "impacts for tShirtCotonFrance using full recycled ratio"
            { query = { tShirtCotonFrance | recycledRatio = Just 1 }
            , co2 = Unit.kgCo2e 1.2522621773664322
            , fwe = Unit.kgPe 0.00009461076235154518
            }
        , sample "impacts for tShirtCotonEurope using custom recycled ratio"
            { query = { tShirtCotonEurope | recycledRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 6.06802360706178
            , fwe = Unit.kgPe 0.0004873525000073962
            }
        , sample "impacts for tShirtCotonAsie using custom recycled ratio"
            { query = { tShirtCotonAsie | recycledRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 7.553128646732241
            , fwe = Unit.kgPe 0.00048753311369641655
            }
        , sample "impacts for jupeCircuitAsie using custom recycled ratio"
            { query = { jupeCircuitAsie | recycledRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 29.85703235030909
            , fwe = Unit.kgPe 0.0007102758576861996
            }
        , sample "impacts for manteauCircuitEurope using custom recycled ratio"
            { query = { manteauCircuitEurope | recycledRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 513.1648102863231
            , fwe = Unit.kgPe 0.0028863508114862564
            }
        , sample "impacts for pantalonCircuitEurope using custom recycled ratio"
            { query = { pantalonCircuitEurope | recycledRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 23.110224611211542
            , fwe = Unit.kgPe 0.001538902892541837
            }
        , sample "impacts for robeCircuitBangladesh using custom recycled ratio"
            { query = { robeCircuitBangladesh | recycledRatio = Just 0.5 }
            , co2 = Unit.kgCo2e 39.709802008995126
            , fwe = Unit.kgPe 0.0002608076513636336
            }
        ]
    , section "Mix énergétique personnalisé"
        [ Section "À l'étape Tissage/Tricotage"
            [ sample "impacts for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.kgCo2e 0))
                , co2 = Unit.kgCo2e 4.374992378966434
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.kgCo2e 0.5))
                , co2 = Unit.kgCo2e 4.614992378966434
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.kgCo2e 1.7))
                , co2 = Unit.kgCo2e 5.190992378966434
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            ]
        , section "À l'étape de Teinture"
            [ sample "impacts for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.kgCo2e 0))
                , co2 = Unit.kgCo2e 4.3816337164664345
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.kgCo2e 0.5))
                , co2 = Unit.kgCo2e 4.580800383133101
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.kgCo2e 1.7))
                , co2 = Unit.kgCo2e 5.058800383133101
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            ]
        , section "À l'étape de Confection"
            [ sample "impacts for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.kgCo2e 0))
                , co2 = Unit.kgCo2e 4.373365928966434
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.kgCo2e 0.5))
                , co2 = Unit.kgCo2e 4.623365928966434
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.kgCo2e 1.7))
                , co2 = Unit.kgCo2e 5.223365928966434
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            ]
        , section "À toutes les étapes"
            [ sample "impacts for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.kgCo2e 0))
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.kgCo2e 0))
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.kgCo2e 0))
                , co2 = Unit.kgCo2e 4.301937666466434
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.kgCo2e 0.5))
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.kgCo2e 0.5))
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.kgCo2e 0.5))
                , co2 = Unit.kgCo2e 4.991104333133101
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.kgCo2e 1.7))
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.kgCo2e 1.7))
                , co2 = Unit.kgCo2e 6.6451043331331
                , fwe = Unit.kgPe 0.0003521486305115451
                }
            ]
        ]
    ]


hasTests : List SectionOrSample -> Bool
hasTests sectionOrSamples =
    List.any
        (\s ->
            case s of
                Section _ _ ->
                    False

                Sample _ _ ->
                    True
        )
        sectionOrSamples
