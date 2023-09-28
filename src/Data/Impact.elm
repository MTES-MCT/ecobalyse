module Data.Impact exposing
    ( ComplementsImpacts
    , Impacts
    , StepsImpacts
    , addComplementsImpacts
    , applyComplements
    , complementsImpactAsChartEntries
    , decodeImpacts
    , default
    , empty
    , encode
    , encodeAggregatedScoreChartEntry
    , encodeComplementsImpacts
    , encodeSingleImpact
    , getAggregatedScoreData
    , getImpact
    , getTotalComplementsImpacts
    , impactsWithComplements
    , mapImpacts
    , noComplementsImpacts
    , noStepsImpacts
    , parseTrigram
    , perKg
    , stepsImpactsAsChartEntries
    , sumImpacts
    , toProtectionAreas
    , totalComplementsImpactAsChartEntry
    , updateImpact
    )

import Data.Color as Color
import Data.Impact.Definition as Definition exposing (Base, Definition, Definitions, Trigram)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Url.Parser as Parser exposing (Parser)



-- Complements impacts


type alias ComplementsImpacts =
    -- Note: these are always expressed in ecoscore (ecs) µPt
    { agroDiversity : Unit.Impact
    , agroEcology : Unit.Impact
    , animalWelfare : Unit.Impact
    , microfibers : Unit.Impact
    , outOfEuropeEOL : Unit.Impact
    }


addComplementsImpacts : ComplementsImpacts -> ComplementsImpacts -> ComplementsImpacts
addComplementsImpacts a b =
    { agroDiversity = Quantity.plus a.agroDiversity b.agroDiversity
    , agroEcology = Quantity.plus a.agroEcology b.agroEcology
    , animalWelfare = Quantity.plus a.animalWelfare b.animalWelfare
    , microfibers = Quantity.plus a.microfibers b.microfibers
    , outOfEuropeEOL = Quantity.plus a.outOfEuropeEOL b.outOfEuropeEOL
    }


applyComplements : Unit.Impact -> Impacts -> Impacts
applyComplements complement impacts =
    let
        ecoScore =
            getImpact Definition.Ecs impacts
    in
    impacts
        |> insertWithoutAggregateComputation Definition.Ecs
            (Quantity.difference ecoScore complement)


noComplementsImpacts : ComplementsImpacts
noComplementsImpacts =
    { agroDiversity = Unit.impact 0
    , agroEcology = Unit.impact 0
    , animalWelfare = Unit.impact 0
    , microfibers = Unit.impact 0
    , outOfEuropeEOL = Unit.impact 0
    }


getTotalComplementsImpacts : ComplementsImpacts -> Unit.Impact
getTotalComplementsImpacts complementsImpacts =
    Quantity.sum
        [ complementsImpacts.agroDiversity
        , complementsImpacts.agroEcology
        , complementsImpacts.animalWelfare
        , complementsImpacts.microfibers
        , complementsImpacts.outOfEuropeEOL
        ]


impactsWithComplements : ComplementsImpacts -> Impacts -> Impacts
impactsWithComplements complementsImpacts impacts =
    let
        complementsImpact =
            getTotalComplementsImpacts complementsImpacts

        ecsWithComplements =
            getImpact Definition.Ecs impacts
                -- Reminder: substracting a malus — a.k.a negative complement — adds to the total impact
                |> Quantity.minus complementsImpact
    in
    impacts
        |> insertWithoutAggregateComputation Definition.Ecs ecsWithComplements


complementsImpactAsChartEntries : ComplementsImpacts -> List { name : String, value : Float, color : String }
complementsImpactAsChartEntries { agroDiversity, agroEcology, animalWelfare, outOfEuropeEOL } =
    -- We want those complements/bonuses to appear as negative values on the chart
    [ { name = "Complément diversité agricole", value = -(Unit.impactToFloat agroDiversity), color = "#808080" }
    , { name = "Complément infrastructures agro-écologiques", value = -(Unit.impactToFloat agroEcology), color = "#a0a0a0" }
    , { name = "Complément conditions d'élevage", value = -(Unit.impactToFloat animalWelfare), color = "#c0c0c0" }
    , { name = "Complément fin de vie hors-Europe", value = -(Unit.impactToFloat outOfEuropeEOL), color = "#e0e0e0" }
    ]


totalComplementsImpactAsChartEntry : ComplementsImpacts -> { name : String, value : Float, color : String }
totalComplementsImpactAsChartEntry complementsImpacts =
    -- We want bonuses to appear as negative values on the chart, maluses as positive ones
    { name = "Compléments"
    , value = -(Unit.impactToFloat (getTotalComplementsImpacts complementsImpacts))
    , color = "#808080"
    }



-- Steps impacts


type alias StepsImpacts =
    { materials : Maybe Unit.Impact
    , transform : Maybe Unit.Impact
    , packaging : Maybe Unit.Impact
    , transports : Maybe Unit.Impact
    , distribution : Maybe Unit.Impact
    , usage : Maybe Unit.Impact
    , endOfLife : Maybe Unit.Impact
    }


noStepsImpacts : StepsImpacts
noStepsImpacts =
    { materials = Nothing
    , transform = Nothing
    , packaging = Nothing
    , transports = Nothing
    , distribution = Nothing
    , usage = Nothing
    , endOfLife = Nothing
    }


stepsImpactsAsChartEntries : StepsImpacts -> List { name : String, value : Float, color : String }
stepsImpactsAsChartEntries stepsImpacts =
    [ ( "Matières premières", stepsImpacts.materials, Color.purple )
    , ( "Transformation", stepsImpacts.transform, Color.pink )
    , ( "Emballage", stepsImpacts.packaging, Color.blue )
    , ( "Transports", stepsImpacts.transports, Color.green )
    , ( "Distribution", stepsImpacts.distribution, Color.red )
    , ( "Utilisation", stepsImpacts.usage, Color.yellow )
    , ( "Fin de vie", stepsImpacts.endOfLife, Color.turquoise )
    ]
        |> List.map
            (\( label, maybeValue, color ) ->
                { name = label
                , color = color
                , value =
                    -- All categories MUST be filled in order to allow comparing Food and Textile simulations
                    -- So, when we don't have a value for a given step, we fallback to zero
                    maybeValue
                        |> Maybe.map Unit.impactToFloat
                        |> Maybe.withDefault 0
                }
            )



-- Protection areas


type alias ProtectionAreas =
    -- Protection Areas is basically scientific slang for subscores
    { climate : Unit.Impact -- Climat
    , biodiversity : Unit.Impact -- Biodiversité
    , resources : Unit.Impact -- Ressources
    , health : Unit.Impact -- Santé environnementale
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
    { climate =
        pick
            [ Definition.Cch -- Climate change
            ]
    , biodiversity =
        pick
            [ Definition.Bvi -- Biodiversity impact
            , Definition.Acd -- Acidification
            , Definition.Tre -- Terrestrial eutrophication
            , Definition.Fwe -- Freshwater Eutrophication
            , Definition.Swe -- Marine eutrophication
            , Definition.EtfC -- Ecotoxicity: freshwater
            , Definition.Ldu -- Land use
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
    = Impacts (Base Unit.Impact)


default : Definition.Trigram
default =
    Definition.Ecs


empty : Impacts
empty =
    Impacts (Definition.init Quantity.zero)


insertWithoutAggregateComputation : Trigram -> Unit.Impact -> Impacts -> Impacts
insertWithoutAggregateComputation trigram impact (Impacts impacts) =
    Definition.update trigram (always impact) impacts
        |> Impacts


getImpact : Trigram -> Impacts -> Unit.Impact
getImpact trigram (Impacts impacts) =
    Definition.get trigram impacts


mapImpacts : (Trigram -> Unit.Impact -> Unit.Impact) -> Impacts -> Impacts
mapImpacts fn (Impacts impacts) =
    Definition.map fn impacts
        |> Impacts


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


updateImpact : Definitions -> Trigram -> Unit.Impact -> Impacts -> Impacts
updateImpact definitions trigram value =
    insertWithoutAggregateComputation trigram value
        >> updateAggregatedScores definitions


decodeImpacts : Definitions -> Decoder Impacts
decodeImpacts definitions =
    Definition.decodeWithoutAggregated (always Unit.decodeImpact)
        |> Pipe.hardcoded (Unit.impact 0)
        |> Pipe.hardcoded (Unit.impact 0)
        |> Decode.map Impacts
        -- Update the aggregated scores as soon as the impacts are decoded, then we never need to compute them again.
        |> Decode.map (updateAggregatedScores definitions)


encodeComplementsImpacts : ComplementsImpacts -> Encode.Value
encodeComplementsImpacts { agroDiversity, agroEcology, animalWelfare, outOfEuropeEOL } =
    Encode.object
        [ ( "agroDiversity", Unit.impactToFloat agroDiversity |> Encode.float )
        , ( "agroEcology", Unit.impactToFloat agroEcology |> Encode.float )
        , ( "animalWelfare", Unit.impactToFloat animalWelfare |> Encode.float )
        , ( "outOfEuropeEOL", Unit.impactToFloat outOfEuropeEOL |> Encode.float )
        ]


encode : Impacts -> Encode.Value
encode (Impacts impacts) =
    Definition.encodeBase
        Unit.encodeImpact
        impacts


encodeSingleImpact : Impacts -> Trigram -> Encode.Value
encodeSingleImpact (Impacts impacts) trigram =
    Encode.object
        [ ( Definition.toString trigram, Unit.encodeImpact (Definition.get trigram impacts) )
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
        |> aggregateScore .pefData Definition.Pef


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
                    { name = def.label
                    , value =
                        impact
                            |> Unit.impactAggregateScore normalization weighting
                            |> Unit.impactToFloat
                    , color = color ++ "bb" -- pastelization through slight transparency
                    }
                        :: acc

                Nothing ->
                    acc
        )
        []
        impacts


encodeAggregatedScoreChartEntry : { name : String, value : Float, color : String } -> Encode.Value
encodeAggregatedScoreChartEntry entry =
    -- This is to be easily used with Highcharts.js in a Web Component
    Encode.object
        [ ( "name", Encode.string entry.name )
        , ( "y", Encode.float entry.value )
        , ( "color", Encode.string entry.color )
        ]


computeAggregatedScore : Definitions -> (Definition -> Maybe Definition.AggregatedScoreData) -> Impacts -> Unit.Impact
computeAggregatedScore definitions getter (Impacts impacts) =
    impacts
        |> Definition.map
            (\trigram impact ->
                Definition.get trigram definitions
                    |> getter
                    |> Maybe.map
                        (\{ normalization, weighting } ->
                            impact
                                |> Unit.impactAggregateScore normalization weighting
                        )
                    |> Maybe.withDefault Quantity.zero
            )
        |> Definition.foldl (\_ -> Quantity.plus) Quantity.zero



-- Parser


parseTrigram : Parser (Trigram -> a) a
parseTrigram =
    Parser.custom "TRIGRAM" <|
        \trigram ->
            Definition.toTrigram trigram
                |> Result.toMaybe
