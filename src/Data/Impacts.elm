module Data.Impacts exposing
    ( Impacts
    , StagesImpacts
    , decodeImpacts
    , default
    , divideBy
    , divideStagesImpactsBy
    , empty
    , encode
    , encodeExcept
    , encodeSingleImpact
    , getAggregatedScoreData
    , getImpact
    , insertWithoutAggregateComputation
    , mapImpacts
    , multiplyBy
    , noStagesImpacts
    , parseTrigram
    , per100grams
    , perKg
    , stagesColors
    , stagesImpactsAsChartEntries
    , sumImpacts
    , toProtectionAreas
    , update
    )

import Data.Color as Color
import Data.Impact as Impact exposing (Impact)
import Data.Impact.Definition as Definition exposing (Definition, Definitions, Trigram, Trigrams)
import Data.Stages as Stages exposing (Stages)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Url.Parser as Parser exposing (Parser)



-- Lifecycle stages abstraction


type alias StagesImpacts =
    Stages (Maybe Impact)


noStagesImpacts : StagesImpacts
noStagesImpacts =
    { assembly = Nothing
    , distribution = Nothing
    , endOfLife = Nothing
    , materials = Nothing
    , packaging = Nothing
    , transform = Nothing
    , transports = Nothing
    , trims = Nothing
    , usage = Nothing
    }


divideStagesImpactsBy : Float -> StagesImpacts -> StagesImpacts
divideStagesImpactsBy n =
    Stages.map (Maybe.map (Quantity.divideBy n))


type alias StagesColors =
    Stages String


stagesColors : StagesColors
stagesColors =
    { assembly = Color.orange
    , distribution = Color.red
    , endOfLife = Color.turquoise
    , materials = Color.purple
    , packaging = Color.blue
    , transform = Color.pink
    , transports = Color.green
    , trims = Color.grey
    , usage = Color.yellow
    }


stagesImpactsAsChartEntries : StagesImpacts -> List { color : String, name : String, value : Float }
stagesImpactsAsChartEntries stagesImpacts =
    [ ( "Accessoires", stagesImpacts.trims, stagesColors.trims )
    , ( "Matières premières", stagesImpacts.materials, stagesColors.materials )
    , ( "Transformation", stagesImpacts.transform, stagesColors.transform )
    , ( "Assemblage", stagesImpacts.assembly, stagesColors.assembly )
    , ( "Emballage", stagesImpacts.packaging, stagesColors.packaging )
    , ( "Transports", stagesImpacts.transports, stagesColors.transports )
    , ( "Distribution", stagesImpacts.distribution, stagesColors.distribution )
    , ( "Utilisation", stagesImpacts.usage, stagesColors.usage )
    , ( "Fin de vie", stagesImpacts.endOfLife, stagesColors.endOfLife )
    ]
        |> List.map
            (\( label, maybeValue, color ) ->
                { color = color
                , name = label
                , value =
                    -- All categories MUST be filled in order to allow comparing Food and Textile simulations
                    -- So, when we don't have a value for a given stage, we fallback to zero
                    maybeValue
                        |> Maybe.map Impact.toFloat
                        |> Maybe.withDefault 0
                }
            )



-- Protection areas


type alias ProtectionAreas =
    -- Protection Areas is basically scientific slang for subscores
    { biodiversity : Impact -- Biodiversité
    , climate : Impact -- Climat
    , health : Impact -- Santé environnementale
    , resources : Impact -- Ressources
    }


toProtectionAreas : Definitions -> Impacts -> ProtectionAreas
toProtectionAreas definitions (Impacts impactsPerKgWithoutComplements) =
    let
        pick trigrams =
            impactsPerKgWithoutComplements
                |> Definition.filter (\t -> List.member t trigrams) (always Quantity.zero)
                |> Impacts
                |> computeAggregatedScore definitions .ecoscoreData
    in
    { biodiversity =
        pick
            [ Definition.Acd -- Acidification
            , Definition.Tre -- Terrestrial eutrophication
            , Definition.Fwe -- Freshwater Eutrophication
            , Definition.Swe -- Marine eutrophication
            , Definition.EtfC -- Ecotoxicity: freshwater
            , Definition.Ldu -- Land use
            ]
    , climate =
        pick
            [ Definition.Cch -- Climate change
            ]
    , health =
        pick
            [ Definition.Ozd -- Ozone depletion
            , Definition.Ior -- Ionising radiation
            , Definition.Pco -- Photochemical ozone formation
            , Definition.HtnC -- Human toxicity: non-carcinogenic
            , Definition.HtcC -- Human toxicity: carcinogenic
            , Definition.Pma -- Particulate matter
            ]
    , resources =
        pick
            [ Definition.Wtu -- Water use
            , Definition.Fru -- Fossile resource use
            , Definition.Mru -- Minerals and metal resource use
            ]
    }



-- Impact data & scores


type Impacts
    = Impacts (Trigrams Impact)


default : Definition.Trigram
default =
    Definition.Ecs


divideBy : Float -> Impacts -> Impacts
divideBy n =
    mapImpacts (\_ -> Quantity.divideBy n)


multiplyBy : Float -> Impacts -> Impacts
multiplyBy n =
    mapImpacts (\_ -> Quantity.multiplyBy n)


empty : Impacts
empty =
    Impacts (Definition.init Quantity.zero)


insertWithoutAggregateComputation : Trigram -> Impact -> Impacts -> Impacts
insertWithoutAggregateComputation trigram impact (Impacts impacts) =
    Definition.update trigram (always impact) impacts
        |> Impacts


getImpact : Trigram -> Impacts -> Impact
getImpact trigram (Impacts impacts) =
    Definition.get trigram impacts


mapImpacts : (Trigram -> Impact -> Impact) -> Impacts -> Impacts
mapImpacts fn (Impacts impacts) =
    Definition.map fn impacts
        |> Impacts


per100grams : Mass -> Impacts -> Impacts
per100grams totalMass =
    perKg totalMass >> mapImpacts (\_ -> Quantity.divideBy 10)


perKg : Mass -> Impacts -> Impacts
perKg totalMass =
    mapImpacts (\_ -> Quantity.divideBy (Mass.inKilograms totalMass))


sumImpacts : List Impacts -> Impacts
sumImpacts =
    List.foldl
        (\impacts ->
            mapImpacts
                (\trigram impact ->
                    Quantity.sum [ getImpact trigram impacts, impact ]
                )
        )
        empty


update : Definitions -> Trigram -> Impact -> Impacts -> Impacts
update definitions trigram value =
    insertWithoutAggregateComputation trigram value
        >> updateAggregatedScores definitions


decodeImpacts : Decoder Impacts
decodeImpacts =
    [ -- Fully detailed process impacts
      Decode.succeed Trigrams
        |> Pipe.required "acd" Impact.decoder
        |> Pipe.required "cch" Impact.decoder
        |> Pipe.required "etf" Impact.decoder
        |> Pipe.required "etf-c" Impact.decoder
        |> Pipe.required "fru" Impact.decoder
        |> Pipe.required "fwe" Impact.decoder
        |> Pipe.required "htc" Impact.decoder
        |> Pipe.required "htc-c" Impact.decoder
        |> Pipe.required "htn" Impact.decoder
        |> Pipe.required "htn-c" Impact.decoder
        |> Pipe.required "ior" Impact.decoder
        |> Pipe.required "ldu" Impact.decoder
        |> Pipe.required "mru" Impact.decoder
        |> Pipe.required "ozd" Impact.decoder
        |> Pipe.required "pco" Impact.decoder
        |> Pipe.required "pma" Impact.decoder
        |> Pipe.required "swe" Impact.decoder
        |> Pipe.required "tre" Impact.decoder
        |> Pipe.required "wtu" Impact.decoder
        |> Pipe.required "ecs" Impact.decoder

    -- Non-detailed process impacts (featuring only ecs)
    , Decode.succeed Trigrams
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.hardcoded Impact.none
        |> Pipe.required "ecs" Impact.decoder
    ]
        |> Decode.oneOf
        |> Decode.map Impacts


encode : Impacts -> Encode.Value
encode (Impacts impacts) =
    impacts
        |> Definition.encodeBase Impact.encode


{-| Encode the impacts except the given trigram
-}
encodeExcept : List Trigram -> Impacts -> Encode.Value
encodeExcept excluded (Impacts impacts) =
    Definition.trigrams
        |> List.filter (\trigram -> not (List.member trigram excluded))
        |> List.map
            (\trigram ->
                ( Definition.toString trigram
                , Impact.encode (Definition.get trigram impacts)
                )
            )
        |> Encode.object


encodeSingleImpact : Impacts -> Trigram -> Encode.Value
encodeSingleImpact (Impacts impacts) trigram =
    Encode.object
        [ ( Definition.toString trigram, Impact.encode (Definition.get trigram impacts) )
        ]


updateAggregatedScores : Definitions -> Impacts -> Impacts
updateAggregatedScores definitions impacts =
    let
        aggregateScore getter trigram =
            impacts
                |> computeAggregatedScore definitions getter
                |> insertWithoutAggregateComputation trigram
    in
    impacts
        |> aggregateScore .ecoscoreData Definition.Ecs


getAggregatedScoreData :
    Definitions
    -> (Definition -> Maybe Definition.AggregatedScoreData)
    -> Impacts
    -> List { color : String, name : String, value : Float }
getAggregatedScoreData definitions getter (Impacts impacts) =
    Definition.foldl
        (\trigram impact acc ->
            let
                def =
                    Definition.get trigram definitions
            in
            case getter def of
                Just { normalization, weighting, color } ->
                    { color = color ++ "bb" -- pastelization through slight transparency
                    , name = def.label
                    , value =
                        impact
                            |> Impact.aggregateScore normalization weighting
                            |> Impact.toFloat
                    }
                        :: acc

                Nothing ->
                    acc
        )
        []
        impacts


computeAggregatedScore : Definitions -> (Definition -> Maybe Definition.AggregatedScoreData) -> Impacts -> Impact
computeAggregatedScore definitions getter (Impacts impacts) =
    impacts
        |> Definition.map
            (\trigram impact ->
                Definition.get trigram definitions
                    |> getter
                    |> Maybe.map
                        (\{ normalization, weighting } ->
                            impact
                                |> Impact.aggregateScore normalization weighting
                        )
                    |> Maybe.withDefault Quantity.zero
            )
        |> Definition.foldl (\_ -> Quantity.plus) Impact.none



-- Parser


parseTrigram : Parser (Trigram -> a) a
parseTrigram =
    Parser.custom "TRIGRAM" <|
        \trigram ->
            Definition.toTrigram trigram
                |> Result.toMaybe
