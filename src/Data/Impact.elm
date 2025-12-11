module Data.Impact exposing
    ( ComplementsImpacts
    , Impacts
    , StepsImpacts
    , addComplementsImpacts
    , applyComplements
    , complementsImpactAsChartEntries
    , decodeImpacts
    , default
    , divideBy
    , divideComplementsImpactsBy
    , divideStepsImpactsBy
    , empty
    , encode
    , encodeAggregatedScoreChartEntry
    , encodeComplementsImpacts
    , encodeSingleImpact
    , getAggregatedScoreData
    , getImpact
    , getTotalComplementsImpacts
    , impactsWithComplements
    , insertWithoutAggregateComputation
    , mapComplementsImpacts
    , mapImpacts
    , multiplyBy
    , noComplementsImpacts
    , noStepsImpacts
    , parseTrigram
    , per100grams
    , perKg
    , stepsColors
    , stepsImpactsAsChartEntries
    , sumEcosystemicImpacts
    , sumImpacts
    , toProtectionAreas
    , totalComplementsImpactAsChartEntry
    , updateImpact
    )

import Data.Color as Color
import Data.Impact.Definition as Definition exposing (Definition, Definitions, Trigram, Trigrams)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Url.Parser as Parser exposing (Parser)



-- Complements impacts


type alias ComplementsImpacts =
    -- Note: these are always expressed in ecoscore (ecs) Pts
    { -- Ecosystemic services impacts
      cropDiversity : Unit.Impact
    , hedges : Unit.Impact
    , livestockDensity : Unit.Impact
    , microfibers : Unit.Impact
    , outOfEuropeEOL : Unit.Impact
    , permanentPasture : Unit.Impact
    , plotSize : Unit.Impact
    }


addComplementsImpacts : ComplementsImpacts -> ComplementsImpacts -> ComplementsImpacts
addComplementsImpacts a b =
    { -- Ecosystemic services impacts
      cropDiversity = Quantity.plus a.cropDiversity b.cropDiversity
    , hedges = Quantity.plus a.hedges b.hedges
    , livestockDensity = Quantity.plus a.livestockDensity b.livestockDensity
    , microfibers = Quantity.plus a.microfibers b.microfibers
    , outOfEuropeEOL = Quantity.plus a.outOfEuropeEOL b.outOfEuropeEOL
    , permanentPasture = Quantity.plus a.permanentPasture b.permanentPasture
    , plotSize = Quantity.plus a.plotSize b.plotSize
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


divideComplementsImpactsBy : Float -> ComplementsImpacts -> ComplementsImpacts
divideComplementsImpactsBy n =
    mapComplementsImpacts (Quantity.divideBy n)


encodeComplementsImpacts : ComplementsImpacts -> Encode.Value
encodeComplementsImpacts complementsImpact =
    let
        negated =
            negateComplementsImpacts complementsImpact
    in
    Encode.object
        [ ( "cropDiversity", Unit.encodeImpact negated.cropDiversity )
        , ( "hedges", Unit.encodeImpact negated.hedges )
        , ( "livestockDensity", Unit.encodeImpact negated.livestockDensity )
        , ( "microfibers", Unit.encodeImpact negated.microfibers )
        , ( "outOfEuropeEOL", Unit.encodeImpact negated.outOfEuropeEOL )
        , ( "permanentPasture", Unit.encodeImpact negated.permanentPasture )
        , ( "plotSize", Unit.encodeImpact negated.plotSize )
        ]


getTotalComplementsImpacts : ComplementsImpacts -> Unit.Impact
getTotalComplementsImpacts complementsImpacts =
    Quantity.sum
        [ complementsImpacts.cropDiversity
        , complementsImpacts.hedges
        , complementsImpacts.livestockDensity
        , complementsImpacts.microfibers
        , complementsImpacts.outOfEuropeEOL
        , complementsImpacts.permanentPasture
        , complementsImpacts.plotSize
        ]


mapComplementsImpacts : (Unit.Impact -> Unit.Impact) -> ComplementsImpacts -> ComplementsImpacts
mapComplementsImpacts fn ci =
    { cropDiversity = fn ci.cropDiversity
    , hedges = fn ci.hedges
    , livestockDensity = fn ci.livestockDensity
    , microfibers = fn ci.microfibers
    , outOfEuropeEOL = fn ci.outOfEuropeEOL
    , permanentPasture = fn ci.permanentPasture
    , plotSize = fn ci.plotSize
    }


negateComplementsImpacts : ComplementsImpacts -> ComplementsImpacts
negateComplementsImpacts =
    mapComplementsImpacts (Unit.impactToFloat >> negate >> Unit.impact)


noComplementsImpacts : ComplementsImpacts
noComplementsImpacts =
    { cropDiversity = Unit.noImpacts
    , hedges = Unit.noImpacts
    , livestockDensity = Unit.noImpacts
    , microfibers = Unit.noImpacts
    , outOfEuropeEOL = Unit.noImpacts
    , permanentPasture = Unit.noImpacts
    , plotSize = Unit.noImpacts
    }


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


sumEcosystemicImpacts : ComplementsImpacts -> Unit.Impact
sumEcosystemicImpacts c =
    Quantity.sum
        [ c.cropDiversity
        , c.hedges
        , c.livestockDensity
        , c.permanentPasture
        , c.plotSize
        ]


complementsImpactAsChartEntries : ComplementsImpacts -> List { color : String, name : String, value : Float }
complementsImpactAsChartEntries c =
    -- Notes:
    -- - We want those complements/bonuses to appear as negative values on the chart
    -- - We want to sum ecosystemic service components impacts to only have a single entry in the charts
    [ { color = "#606060", name = "Services écosystémiques", value = -(Unit.impactToFloat (sumEcosystemicImpacts c)) }
    , { color = "#c0c0c0", name = "Complément microfibres", value = -(Unit.impactToFloat c.microfibers) }
    , { color = "#e0e0e0", name = "Complément export hors-Europe", value = -(Unit.impactToFloat c.outOfEuropeEOL) }
    ]


totalComplementsImpactAsChartEntry : ComplementsImpacts -> { color : String, name : String, value : Float }
totalComplementsImpactAsChartEntry complementsImpacts =
    -- We want bonuses to appear as negative values on the chart, maluses as positive ones
    { color = "#808080"
    , name = "Compléments"
    , value = -(Unit.impactToFloat (getTotalComplementsImpacts complementsImpacts))
    }



-- Steps impacts


type alias Steps a =
    { distribution : a
    , endOfLife : a
    , materials : a
    , packaging : a
    , transform : a
    , transports : a
    , trims : a
    , usage : a
    }


type alias StepsImpacts =
    Steps (Maybe Unit.Impact)


mapSteps : (a -> a) -> Steps a -> Steps a
mapSteps fn steps =
    { distribution = fn steps.distribution
    , endOfLife = fn steps.endOfLife
    , materials = fn steps.materials
    , packaging = fn steps.packaging
    , transform = fn steps.transform
    , transports = fn steps.transports
    , trims = fn steps.trims
    , usage = fn steps.usage
    }


noStepsImpacts : StepsImpacts
noStepsImpacts =
    { distribution = Nothing
    , endOfLife = Nothing
    , materials = Nothing
    , packaging = Nothing
    , transform = Nothing
    , transports = Nothing
    , trims = Nothing
    , usage = Nothing
    }


divideStepsImpactsBy : Float -> StepsImpacts -> StepsImpacts
divideStepsImpactsBy n =
    mapSteps (Maybe.map (Quantity.divideBy n))


type alias StepsColors =
    Steps String


stepsColors : StepsColors
stepsColors =
    { distribution = Color.red
    , endOfLife = Color.turquoise
    , materials = Color.purple
    , packaging = Color.blue
    , transform = Color.pink
    , transports = Color.green
    , trims = Color.grey
    , usage = Color.yellow
    }


stepsImpactsAsChartEntries : StepsImpacts -> List { color : String, name : String, value : Float }
stepsImpactsAsChartEntries stepsImpacts =
    [ ( "Accessoires", stepsImpacts.trims, stepsColors.trims )
    , ( "Matières premières", stepsImpacts.materials, stepsColors.materials )
    , ( "Transformation", stepsImpacts.transform, stepsColors.transform )
    , ( "Emballage", stepsImpacts.packaging, stepsColors.packaging )
    , ( "Transports", stepsImpacts.transports, stepsColors.transports )
    , ( "Distribution", stepsImpacts.distribution, stepsColors.distribution )
    , ( "Utilisation", stepsImpacts.usage, stepsColors.usage )
    , ( "Fin de vie", stepsImpacts.endOfLife, stepsColors.endOfLife )
    ]
        |> List.map
            (\( label, maybeValue, color ) ->
                { color = color
                , name = label
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
    { biodiversity : Unit.Impact -- Biodiversité
    , climate : Unit.Impact -- Climat
    , health : Unit.Impact -- Santé environnementale
    , resources : Unit.Impact -- Ressources
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
    = Impacts (Trigrams Unit.Impact)


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


updateImpact : Definitions -> Trigram -> Unit.Impact -> Impacts -> Impacts
updateImpact definitions trigram value =
    insertWithoutAggregateComputation trigram value
        >> updateAggregatedScores definitions


decodeImpacts : Decoder Impacts
decodeImpacts =
    Definition.decodeBase (always Unit.decodeImpact)
        |> Decode.map Impacts


encode : Impacts -> Encode.Value
encode (Impacts impacts) =
    impacts
        |> Definition.encodeBase Unit.encodeImpact


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
                            |> Unit.impactAggregateScore normalization weighting
                            |> Unit.impactToFloat
                    }
                        :: acc

                Nothing ->
                    acc
        )
        []
        impacts


encodeAggregatedScoreChartEntry : { color : String, name : String, value : Float } -> Encode.Value
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
