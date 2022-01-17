module Data.Sample exposing (..)

import Data.Inputs as Inputs exposing (..)
import Data.Unit as Unit exposing (Ratio(..))


type alias SampleData =
    { query : Query
    , cch : Unit.Impact
    , fwe : Unit.Impact
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
            , cch = Unit.impact 4.946829140043935
            , fwe = Unit.impact 0.0003521486305115451
            }
        , sample "impacts for tShirtPolyamideFrance"
            { query = tShirtPolyamideFrance
            , cch = Unit.impact 4.1723091266175
            , fwe = Unit.impact 0.00008881966487864669
            }
        , sample "impacts for tShirtCotonEurope"
            { query = tShirtCotonEurope
            , cch = Unit.impact 8.18170806893928
            , fwe = Unit.impact 0.0006161214340873961
            }
        , sample "impacts for tShirtCotonAsie"
            { query = tShirtCotonAsie
            , cch = Unit.impact 9.666813108609741
            , fwe = Unit.impact 0.0006163020477764167
            }
        , sample "impacts for jupeCircuitAsie"
            { query = jupeCircuitAsie
            , cch = Unit.impact 32.62862391875218
            , fwe = Unit.impact 0.0006626107681986996
            }
        , sample "impacts for manteauCircuitEurope"
            { query = manteauCircuitEurope
            , cch = Unit.impact 513.4321194700901
            , fwe = Unit.impact 0.0028863508114862564
            }
        , sample "impacts for pantalonCircuitEurope"
            { query = pantalonCircuitEurope
            , cch = Unit.impact 23.829019614621544
            , fwe = Unit.impact 0.001538902892541837
            }
        , sample "impacts for robeCircuitBangladesh"
            { query = robeCircuitBangladesh
            , cch = Unit.impact 40.349197073796105
            , fwe = Unit.impact 0.0002608076513636336
            }
        ]
    , section "Majoration de teinture personnalisée"
        [ sample "impacts for tShirtCotonFrance using custom dyeing weighting"
            { query = { tShirtCotonFrance | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 5.410720438893935
            , fwe = Unit.impact 0.00048420985564356846
            }
        , sample "impacts for tShirtPolyamideFrance using custom dyeing weighting"
            { query = { tShirtPolyamideFrance | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 4.636200425467502
            , fwe = Unit.impact 0.00022088089001067005
            }
        , sample "impacts for tShirtCotonEurope using custom dyeing weighting"
            { query = { tShirtCotonEurope | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 6.996164084272613
            , fwe = Unit.impact 0.00048408368308020954
            }
        , sample "impacts for tShirtCotonAsie using custom dyeing weighting"
            { query = { tShirtCotonAsie | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 8.266339990609742
            , fwe = Unit.impact 0.0004842569335390633
            }
        , sample "impacts for jupeCircuitAsie using custom dyeing weighting"
            { query = { jupeCircuitAsie | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 30.00273682250218
            , fwe = Unit.impact 0.00041502617900366224
            }
        , sample "impacts for manteauCircuitEurope using custom dyeing weighting"
            { query = { manteauCircuitEurope | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 506.3929520611319
            , fwe = Unit.impact 0.002102376664881086
            }
        , sample "impacts for pantalonCircuitEurope using custom dyeing weighting"
            { query = { pantalonCircuitEurope | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 20.736878388996537
            , fwe = Unit.impact 0.0011675520699323278
            }
        , sample "impacts for robeCircuitBangladesh using custom dyeing weighting"
            { query = { robeCircuitBangladesh | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 42.95677092671277
            , fwe = Unit.impact 0.0006734506677003212
            }
        ]
    , section "Transport aérien personnalisé"
        [ sample "impacts for tShirtCotonFrance using custom air transport ratio"
            { query = { tShirtCotonFrance | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 4.991594602543935
            , fwe = Unit.impact 0.0003521474420415451
            }
        , sample "impacts for tShirtPolyamideFrance using custom air transport ratio"
            { query = { tShirtPolyamideFrance | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 4.2170745891175
            , fwe = Unit.impact 0.00008881847640864668
            }
        , sample "impacts for tShirtCotonEurope using custom air transport ratio"
            { query = { tShirtCotonEurope | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 8.28453583661638
            , fwe = Unit.impact 0.0006161245568596139
            }
        , sample "impacts for tShirtCotonAsie using custom air transport ratio"
            { query = { tShirtCotonAsie | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 9.9233382681535
            , fwe = Unit.impact 0.0006163353667731165
            }
        , sample "impacts for jupeCircuitAsie using custom air transport ratio"
            { query = { jupeCircuitAsie | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 33.081315376770576
            , fwe = Unit.impact 0.0006626695664281698
            }
        , sample "impacts for manteauCircuitEurope using custom air transport ratio"
            { query = { manteauCircuitEurope | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 514.0067452306386
            , fwe = Unit.impact 0.0028863682622721795
            }
        , sample "impacts for pantalonCircuitEurope using custom air transport ratio"
            { query = { pantalonCircuitEurope | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 24.006954796552442
            , fwe = Unit.impact 0.0015389172940433644
            }
        , sample "impacts for robeCircuitBangladesh using custom air transport ratio"
            { query = { robeCircuitBangladesh | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 40.750279538646105
            , fwe = Unit.impact 0.0002608599404572461
            }
        ]
    , section "Part de matière recyclée personnalisée"
        [ sample "impacts for tShirtCotonFrance using no recycled ratio"
            { query = { tShirtCotonFrance | recycledRatio = Just (Ratio 0) }
            , cch = Unit.impact 4.946829140043935
            , fwe = Unit.impact 0.0003521486305115451
            }
        , sample "impacts for tShirtCotonFrance using half recycled ratio"
            { query = { tShirtCotonFrance | recycledRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 3.3659466392439326
            , fwe = Unit.impact 0.00022337969643154514
            }
        , sample "impacts for tShirtCotonFrance using full recycled ratio"
            { query = { tShirtCotonFrance | recycledRatio = Just (Ratio 1) }
            , cch = Unit.impact 1.7850641384439323
            , fwe = Unit.impact 0.00009461076235154518
            }
        , sample "impacts for tShirtPolyamideFrance using custom recycled ratio"
            { query = { tShirtPolyamideFrance | recycledRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 3.2817771410175007
            , fwe = Unit.impact 0.00011238870391864669
            }
        , sample "impacts for tShirtCotonEurope using custom recycled ratio"
            { query = { tShirtCotonEurope | recycledRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 6.60082556813928
            , fwe = Unit.impact 0.0004873525000073962
            }
        , sample "impacts for tShirtCotonAsie using custom recycled ratio"
            { query = { tShirtCotonAsie | recycledRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 8.085930607809741
            , fwe = Unit.impact 0.00048753311369641655
            }
        , sample "impacts for jupeCircuitAsie using custom recycled ratio"
            { query = { jupeCircuitAsie | recycledRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 30.255819770939677
            , fwe = Unit.impact 0.0007102758576861996
            }
        , sample "impacts for manteauCircuitEurope using custom recycled ratio"
            { query = { manteauCircuitEurope | recycledRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 513.4321194700901
            , fwe = Unit.impact 0.0028863508114862564
            }
        , sample "impacts for pantalonCircuitEurope using custom recycled ratio"
            { query = { pantalonCircuitEurope | recycledRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 23.829019614621544
            , fwe = Unit.impact 0.001538902892541837
            }
        , sample "impacts for robeCircuitBangladesh using custom recycled ratio"
            { query = { robeCircuitBangladesh | recycledRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 40.349197073796105
            , fwe = Unit.impact 0.0002608076513636336
            }
        ]
    , section "Mix énergétique personnalisé"
        [ Section "À l'étape Tissage/Tricotage"
            [ sample "impacts for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.impact 0))
                , cch = Unit.impact 4.907794340043934
                , fwe = Unit.impact 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.impact 0.5))
                , cch = Unit.impact 5.1477943400439345
                , fwe = Unit.impact 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.impact 1.7))
                , cch = Unit.impact 5.723794340043934
                , fwe = Unit.impact 0.0003521486305115451
                }
            ]
        , section "À l'étape de Teinture"
            [ sample "impacts for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.impact 0))
                , cch = Unit.impact 4.914435677543935
                , fwe = Unit.impact 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.impact 0.5))
                , cch = Unit.impact 5.113602344210602
                , fwe = Unit.impact 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.impact 1.7))
                , cch = Unit.impact 5.591602344210601
                , fwe = Unit.impact 0.0003521486305115451
                }
            ]
        , section "À l'étape de Confection"
            [ sample "impacts for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.impact 0))
                , cch = Unit.impact 4.9061678900439345
                , fwe = Unit.impact 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.impact 0.5))
                , cch = Unit.impact 5.1561678900439345
                , fwe = Unit.impact 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.impact 1.7))
                , cch = Unit.impact 5.756167890043934
                , fwe = Unit.impact 0.0003521486305115451
                }
            ]
        , section "À toutes les étapes"
            [ sample "impacts for tShirtCotonFrance using custom country mix of 0"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.impact 0))
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.impact 0))
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.impact 0))
                , cch = Unit.impact 4.834739627543934
                , fwe = Unit.impact 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 0.5"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.impact 0.5))
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.impact 0.5))
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.impact 0.5))
                , cch = Unit.impact 5.523906294210601
                , fwe = Unit.impact 0.0003521486305115451
                }
            , sample "impacts for tShirtCotonFrance using custom country mix of 1.7"
                { query =
                    tShirtCotonFrance
                        |> Inputs.setCustomCountryMix 1 (Just (Unit.impact 1.7))
                        |> Inputs.setCustomCountryMix 2 (Just (Unit.impact 1.7))
                        |> Inputs.setCustomCountryMix 3 (Just (Unit.impact 1.7))
                , cch = Unit.impact 7.1779062942106
                , fwe = Unit.impact 0.0003521486305115451
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
