module Data.Sample exposing (SampleData, SectionOrSample(..), samples)

import Data.Inputs exposing (..)
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
            , cch = Unit.impact 5.086507233728058
            , fwe = Unit.impact 0.0003521486305115451
            }
        , sample "impacts for tShirtPolyamideFrance"
            { query = tShirtPolyamideFrance
            , cch = Unit.impact 4.328393994334148
            , fwe = Unit.impact 0.00008881966487864669
            }
        , sample "impacts for tShirtCotonEurope"
            { query = tShirtCotonEurope
            , cch = Unit.impact 8.169976591865057
            , fwe = Unit.impact 0.0006161214340873961
            }
        , sample "impacts for tShirtCotonAsie"
            { query = tShirtCotonAsie
            , cch = Unit.impact 9.572701879584555
            , fwe = Unit.impact 0.0006163020477764167
            }
        , sample "impacts for jupeCircuitAsie"
            { query = jupeCircuitAsie
            , cch = Unit.impact 33.019870387046595
            , fwe = Unit.impact 0.0006626107681986996
            }
        , sample "impacts for manteauCircuitEurope"
            { query = manteauCircuitEurope
            , cch = Unit.impact 514.5920039171044
            , fwe = Unit.impact 0.0028863508114862564
            }
        , sample "impacts for pantalonCircuitEurope"
            { query = pantalonCircuitEurope
            , cch = Unit.impact 24.397644117086543
            , fwe = Unit.impact 0.001538902892541837
            }
        , sample "impacts for robeCircuitBangladesh"
            { query = robeCircuitBangladesh
            , cch = Unit.impact 39.942898569095476
            , fwe = Unit.impact 0.0002608076513636336
            }
        ]
    , section "Majoration de teinture personnalisée"
        [ sample "impacts for tShirtCotonFrance using custom dyeing weighting"
            { query = { tShirtCotonFrance | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 5.5503985325780585
            , fwe = Unit.impact 0.00048420985564356846
            }
        , sample "impacts for tShirtPolyamideFrance using custom dyeing weighting"
            { query = { tShirtPolyamideFrance | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 4.792285293184148
            , fwe = Unit.impact 0.00022088089001067005
            }
        , sample "impacts for tShirtCotonEurope using custom dyeing weighting"
            { query = { tShirtCotonEurope | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 6.984432607198389
            , fwe = Unit.impact 0.00048408368308020954
            }
        , sample "impacts for tShirtCotonAsie using custom dyeing weighting"
            { query = { tShirtCotonAsie | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 8.172228761584554
            , fwe = Unit.impact 0.0004842569335390633
            }
        , sample "impacts for jupeCircuitAsie using custom dyeing weighting"
            { query = { jupeCircuitAsie | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 30.39398329079659
            , fwe = Unit.impact 0.00041502617900366224
            }
        , sample "impacts for manteauCircuitEurope using custom dyeing weighting"
            { query = { manteauCircuitEurope | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 507.55283650814613
            , fwe = Unit.impact 0.002102376664881086
            }
        , sample "impacts for pantalonCircuitEurope using custom dyeing weighting"
            { query = { pantalonCircuitEurope | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 21.305502891461536
            , fwe = Unit.impact 0.0011675520699323278
            }
        , sample "impacts for robeCircuitBangladesh using custom dyeing weighting"
            { query = { robeCircuitBangladesh | dyeingWeighting = Just (Ratio 0.5) }
            , cch = Unit.impact 42.73566172451214
            , fwe = Unit.impact 0.0006734506677003212
            }
        ]
    , section "Transport aérien personnalisé"
        [ sample "impacts for tShirtCotonFrance using custom air transport ratio"
            { query = { tShirtCotonFrance | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 5.131272696228058
            , fwe = Unit.impact 0.0003521474420415451
            }
        , sample "impacts for tShirtPolyamideFrance using custom air transport ratio"
            { query = { tShirtPolyamideFrance | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 4.373159456834148
            , fwe = Unit.impact 0.00008881847640864668
            }
        , sample "impacts for tShirtCotonEurope using custom air transport ratio"
            { query = { tShirtCotonEurope | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 8.272804359542157
            , fwe = Unit.impact 0.0006161245568596139
            }
        , sample "impacts for tShirtCotonAsie using custom air transport ratio"
            { query = { tShirtCotonAsie | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 9.829227039128314
            , fwe = Unit.impact 0.0006163353667731165
            }
        , sample "impacts for jupeCircuitAsie using custom air transport ratio"
            { query = { jupeCircuitAsie | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 33.472561845064995
            , fwe = Unit.impact 0.0006626695664281698
            }
        , sample "impacts for manteauCircuitEurope using custom air transport ratio"
            { query = { manteauCircuitEurope | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 515.1666296776528
            , fwe = Unit.impact 0.0028863682622721795
            }
        , sample "impacts for pantalonCircuitEurope using custom air transport ratio"
            { query = { pantalonCircuitEurope | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 24.57557929901744
            , fwe = Unit.impact 0.0015389172940433644
            }
        , sample "impacts for robeCircuitBangladesh using custom air transport ratio"
            { query = { robeCircuitBangladesh | airTransportRatio = Just (Ratio 0.5) }
            , cch = Unit.impact 40.34398103394547
            , fwe = Unit.impact 0.0002608599404572461
            }
        ]
    , section "Part de matière recyclée personnalisée"
        [ sample "impacts for tShirtCotonFrance using no recycled ratio"
            { query = tShirtCotonFrance |> updateMaterialRecycledRatio 0 (Ratio 0)
            , cch = Unit.impact 5.086507233728058
            , fwe = Unit.impact 0.0003521486305115451
            }
        , sample "impacts for tShirtCotonFrance using half recycled ratio"
            { query = tShirtCotonFrance |> updateMaterialRecycledRatio 0 (Ratio 0.5)
            , cch = Unit.impact 3.539112804911957
            , fwe = Unit.impact 0.00022337969643154514
            }
        , sample "impacts for tShirtCotonFrance using full recycled ratio"
            { query = tShirtCotonFrance |> updateMaterialRecycledRatio 0 (Ratio 1)
            , cch = Unit.impact 1.991718376095856
            , fwe = Unit.impact 0.00009461076235154518
            }
        , sample "impacts for tShirtPolyamideFrance using custom recycled ratio"
            { query = tShirtPolyamideFrance |> updateMaterialRecycledRatio 0 (Ratio 0.5)
            , cch = Unit.impact 3.4567262818364473
            , fwe = Unit.impact 0.00011238870391864669
            }
        , sample "impacts for tShirtCotonEurope using custom recycled ratio"
            { query = tShirtCotonEurope |> updateMaterialRecycledRatio 0 (Ratio 0.5)
            , cch = Unit.impact 6.622582163048957
            , fwe = Unit.impact 0.0004873525000073962
            }
        , sample "impacts for tShirtCotonAsie using custom recycled ratio"
            { query = tShirtCotonAsie |> updateMaterialRecycledRatio 0 (Ratio 0.5)
            , cch = Unit.impact 8.025307450768455
            , fwe = Unit.impact 0.00048753311369641655
            }
        , sample "impacts for jupeCircuitAsie using custom recycled ratio"
            { query = jupeCircuitAsie |> updateMaterialRecycledRatio 0 (Ratio 0.5)
            , cch = Unit.impact 30.64706623923409
            , fwe = Unit.impact 0.0007102758576861996
            }
        , sample "impacts for manteauCircuitEurope using custom recycled ratio"
            { query = manteauCircuitEurope |> updateMaterialRecycledRatio 0 (Ratio 0.5)
            , cch = Unit.impact 514.5920039171044
            , fwe = Unit.impact 0.0028863508114862564
            }
        , sample "impacts for pantalonCircuitEurope using custom recycled ratio"
            { query = pantalonCircuitEurope |> updateMaterialRecycledRatio 0 (Ratio 0.5)
            , cch = Unit.impact 24.397644117086543
            , fwe = Unit.impact 0.001538902892541837
            }
        , sample "impacts for robeCircuitBangladesh using custom recycled ratio"
            { query = robeCircuitBangladesh |> updateMaterialRecycledRatio 0 (Ratio 0.5)
            , cch = Unit.impact 39.942898569095476
            , fwe = Unit.impact 0.0002608076513636336
            }
        ]
    ]
