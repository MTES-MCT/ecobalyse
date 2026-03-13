module Data.Impact exposing
    ( ComplementsImpacts
    , ComplementsResultsImpacts
    , Impacts
    , StagesImpacts
    , addComplementsImpacts
    , applyComplements
    , complementsImpactAsChartEntries
    , complementsLabels
    , decodeComplementsImpacts
    , decodeImpacts
    , default
    , divideBy
    , divideComplementsImpactsBy
    , divideStagesImpactsBy
    , empty
    , emptyComplementsResultsImpacts
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
    , mergeComplementsResultsImpacts
    , multiplyBy
    , noComplementsImpacts
    , noStagesImpacts
    , parseTrigram
    , per100grams
    , perKg
    , stagesColors
    , stagesImpactsAsChartEntries
    , sumComplementsResultsImpacts
    , sumEcosystemicImpacts
    , sumImpacts
    , toProtectionAreas
    , totalComplementsImpactAsChartEntry
    , updateImpact
    )

import Data.Color as Color
import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Impact.Definition as Definition exposing (Definition, Definitions, Trigram, Trigrams)
import Data.Stages as Stages exposing (Stages)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Mass exposing (Mass)
import Quantity
import Url.Parser as Parser exposing (Parser)



-- Complements impacts


type alias AbstractComplements a =
    { cropDiversity : a
    , forest : a
    , hedges : a
    , livestockDensity : a
    , microfibers : a
    , outOfEuropeEOL : a
    , permanentPasture : a
    , plotSize : a
    }


type alias ComplementsImpacts =
    AbstractComplements (Maybe Unit.Impact)


type alias ComplementsResultsImpacts =
    AbstractComplements (Maybe Impacts)


type alias ComplementsLabels =
    AbstractComplements String


complementsLabels : ComplementsLabels
complementsLabels =
    { cropDiversity = "Diversité culturale"
    , forest = "Forêt"
    , hedges = "Haies"
    , livestockDensity = "Chargement territorial"
    , microfibers = "Microfibres"
    , outOfEuropeEOL = "Export hors-Europe"
    , permanentPasture = "Prairies permanentes"
    , plotSize = "Taille de parcelles"
    }


emptyComplementsResultsImpacts : ComplementsResultsImpacts
emptyComplementsResultsImpacts =
    { cropDiversity = Nothing
    , forest = Nothing
    , hedges = Nothing
    , livestockDensity = Nothing
    , microfibers = Nothing
    , outOfEuropeEOL = Nothing
    , permanentPasture = Nothing
    , plotSize = Nothing
    }


addComplementsImpacts : ComplementsImpacts -> ComplementsImpacts -> ComplementsImpacts
addComplementsImpacts a b =
    let
        addComplement maybeA maybeB =
            case ( maybeA, maybeB ) of
                ( Just justA, Just justB ) ->
                    Just <| Quantity.plus justA justB

                ( Nothing, Just justB ) ->
                    Just justB

                ( Just justA, Nothing ) ->
                    Just justA

                ( Nothing, Nothing ) ->
                    Nothing
    in
    { -- Ecosystemic services impacts
      cropDiversity = addComplement a.cropDiversity b.cropDiversity
    , forest = addComplement a.forest b.forest
    , hedges = addComplement a.hedges b.hedges
    , livestockDensity = addComplement a.livestockDensity b.livestockDensity
    , microfibers = addComplement a.microfibers b.microfibers
    , outOfEuropeEOL = addComplement a.outOfEuropeEOL b.outOfEuropeEOL
    , permanentPasture = addComplement a.permanentPasture b.permanentPasture
    , plotSize = addComplement a.plotSize b.plotSize
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
    EU.optionalPropertiesObject
        [ ( "cropDiversity", negated.cropDiversity |> Maybe.map Unit.encodeImpact )
        , ( "forest", negated.forest |> Maybe.map Unit.encodeImpact )
        , ( "hedges", negated.hedges |> Maybe.map Unit.encodeImpact )
        , ( "livestockDensity", negated.livestockDensity |> Maybe.map Unit.encodeImpact )
        , ( "microfibers", negated.microfibers |> Maybe.map Unit.encodeImpact )
        , ( "outOfEuropeEOL", negated.outOfEuropeEOL |> Maybe.map Unit.encodeImpact )
        , ( "permanentPasture", negated.permanentPasture |> Maybe.map Unit.encodeImpact )
        , ( "plotSize", negated.plotSize |> Maybe.map Unit.encodeImpact )
        ]


decodeComplementsImpacts : Decoder ComplementsImpacts
decodeComplementsImpacts =
    Decode.succeed AbstractComplements
        |> DU.strictOptional "cropDiversity" Unit.decodeImpact
        -- @FIXME: forest is a value that should be added but for now, legacy code substracts
        --  the values complements. So let’s be backward compatible for now
        |> DU.strictOptional "forest" (Decode.map Quantity.negate Unit.decodeImpact)
        |> DU.strictOptional "hedges" Unit.decodeImpact
        |> DU.strictOptional "livestockDensity" Unit.decodeImpact
        |> DU.strictOptional "microfibers" Unit.decodeImpact
        |> DU.strictOptional "outOfEuropeEOL" Unit.decodeImpact
        |> DU.strictOptional "permanentPasture" Unit.decodeImpact
        |> DU.strictOptional "plotSize" Unit.decodeImpact


getTotalComplementsImpacts : ComplementsImpacts -> Unit.Impact
getTotalComplementsImpacts complementsImpacts =
    Quantity.sum
        [ complementsImpacts.cropDiversity |> Maybe.withDefault Unit.noImpacts
        , complementsImpacts.forest |> Maybe.withDefault Unit.noImpacts
        , complementsImpacts.hedges |> Maybe.withDefault Unit.noImpacts
        , complementsImpacts.livestockDensity |> Maybe.withDefault Unit.noImpacts
        , complementsImpacts.microfibers |> Maybe.withDefault Unit.noImpacts
        , complementsImpacts.outOfEuropeEOL |> Maybe.withDefault Unit.noImpacts
        , complementsImpacts.permanentPasture |> Maybe.withDefault Unit.noImpacts
        , complementsImpacts.plotSize |> Maybe.withDefault Unit.noImpacts
        ]


mapComplementsImpacts : (Unit.Impact -> Unit.Impact) -> ComplementsImpacts -> ComplementsImpacts
mapComplementsImpacts fn ci =
    { cropDiversity = ci.cropDiversity |> Maybe.map fn
    , forest = ci.forest |> Maybe.map fn
    , hedges = ci.hedges |> Maybe.map fn
    , livestockDensity = ci.livestockDensity |> Maybe.map fn
    , microfibers = ci.microfibers |> Maybe.map fn
    , outOfEuropeEOL = ci.outOfEuropeEOL |> Maybe.map fn
    , permanentPasture = ci.permanentPasture |> Maybe.map fn
    , plotSize = ci.plotSize |> Maybe.map fn
    }


negateComplementsImpacts : ComplementsImpacts -> ComplementsImpacts
negateComplementsImpacts =
    mapComplementsImpacts (Unit.impactToFloat >> negate >> Unit.impact)


noComplementsImpacts : ComplementsImpacts
noComplementsImpacts =
    { cropDiversity = Nothing
    , forest = Nothing
    , hedges = Nothing
    , livestockDensity = Nothing
    , microfibers = Nothing
    , outOfEuropeEOL = Nothing
    , permanentPasture = Nothing
    , plotSize = Nothing
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
        [ c.cropDiversity |> Maybe.withDefault Unit.noImpacts
        , c.hedges |> Maybe.withDefault Unit.noImpacts
        , c.livestockDensity |> Maybe.withDefault Unit.noImpacts
        , c.permanentPasture |> Maybe.withDefault Unit.noImpacts
        , c.plotSize |> Maybe.withDefault Unit.noImpacts
        ]


complementsImpactAsChartEntries : ComplementsImpacts -> List { color : String, name : String, value : Float }
complementsImpactAsChartEntries c =
    -- Notes:
    -- - We want those complements/bonuses to appear as negative values on the chart
    -- - We want to sum ecosystemic service components impacts to only have a single entry in the charts
    [ { color = "#606060", name = "Services écosystémiques", value = -(Unit.impactToFloat (sumEcosystemicImpacts c)) }
    , { color = "#c0c0c0", name = "Complément microfibres", value = -(c.microfibers |> Maybe.map Unit.impactToFloat |> Maybe.withDefault 0) }
    , { color = "#e0e0e0", name = "Complément export hors-Europe", value = -(c.outOfEuropeEOL |> Maybe.map Unit.impactToFloat |> Maybe.withDefault 0) }
    ]


totalComplementsImpactAsChartEntry : ComplementsImpacts -> { color : String, name : String, value : Float }
totalComplementsImpactAsChartEntry complementsImpacts =
    -- We want bonuses to appear as negative values on the chart, maluses as positive ones
    { color = "#808080"
    , name = "Compléments"
    , value = -(Unit.impactToFloat (getTotalComplementsImpacts complementsImpacts))
    }



-- Lifecycle stages abstraction


type alias StagesImpacts =
    Stages (Maybe Unit.Impact)


noStagesImpacts : StagesImpacts
noStagesImpacts =
    { distribution = Nothing
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
    { distribution = Color.red
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


sumComplementsResultsImpacts : List ComplementsResultsImpacts -> ComplementsResultsImpacts
sumComplementsResultsImpacts =
    let
        mapComplementImpacts complementsResultsImpacts complement =
            mapImpacts
                (\trigram impact ->
                    Quantity.sum
                        [ getImpact trigram (complementsResultsImpacts |> complement |> Maybe.withDefault empty)
                        , impact
                        ]
                )
    in
    List.foldl
        (\acc complementsResultsImpacts ->
            { cropDiversity =
                acc.cropDiversity
                    |> Maybe.map (mapComplementImpacts complementsResultsImpacts .cropDiversity)
            , forest =
                acc.forest
                    |> Maybe.map (mapComplementImpacts complementsResultsImpacts .forest)
            , hedges =
                acc.hedges
                    |> Maybe.map (mapComplementImpacts complementsResultsImpacts .hedges)
            , livestockDensity =
                acc.livestockDensity
                    |> Maybe.map (mapComplementImpacts complementsResultsImpacts .livestockDensity)
            , microfibers =
                acc.microfibers
                    |> Maybe.map (mapComplementImpacts complementsResultsImpacts .microfibers)
            , outOfEuropeEOL =
                acc.outOfEuropeEOL
                    |> Maybe.map (mapComplementImpacts complementsResultsImpacts .outOfEuropeEOL)
            , permanentPasture =
                acc.permanentPasture
                    |> Maybe.map (mapComplementImpacts complementsResultsImpacts .permanentPasture)
            , plotSize =
                acc.plotSize
                    |> Maybe.map (mapComplementImpacts complementsResultsImpacts .plotSize)
            }
        )
        emptyComplementsResultsImpacts


mergeComplementsResultsImpacts : ComplementsResultsImpacts -> Impacts
mergeComplementsResultsImpacts complementsResultsImpacts =
    sumImpacts
        [ complementsResultsImpacts.cropDiversity |> Maybe.withDefault empty
        , complementsResultsImpacts.forest |> Maybe.withDefault empty
        , complementsResultsImpacts.hedges |> Maybe.withDefault empty
        , complementsResultsImpacts.livestockDensity |> Maybe.withDefault empty
        , complementsResultsImpacts.microfibers |> Maybe.withDefault empty
        , complementsResultsImpacts.outOfEuropeEOL |> Maybe.withDefault empty
        , complementsResultsImpacts.permanentPasture |> Maybe.withDefault empty
        , complementsResultsImpacts.plotSize |> Maybe.withDefault empty
        ]


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
