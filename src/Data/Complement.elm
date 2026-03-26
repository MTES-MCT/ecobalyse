module Data.Complement exposing
    ( AbstractComplements
    , ComplementsImpacts
    , ComplementsResultsImpacts
    , addComplementsImpacts
    , allComplementsToList
    , applyComplementsToImpacts
    , complementsImpactAsChartEntries
    , decodeComplementsImpacts
    , divideComplementsImpactsBy
    , emptyComplementsResultsImpacts
    , encodeComplementsImpacts
    , getTotalComplementsImpacts
    , impactsWithComplements
    , labels
    , mapComplements
    , mergeComplementsResultsImpacts
    , noComplementsImpacts
    , sumComplementsResultsImpacts
    , sumEcosystemicImpacts
    , totalComplementsImpactAsChartEntry
    )

import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity



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


type alias ComplementsLabels =
    AbstractComplements String


type alias ComplementsIdentifiers =
    AbstractComplements String


type alias ComplementsResultsImpacts =
    AbstractComplements (Maybe Impacts)


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
    mapComplements2 addComplement a b


allComplementsFields : List (AbstractComplements a -> a)
allComplementsFields =
    [ .cropDiversity
    , .forest
    , .hedges
    , .livestockDensity
    , .microfibers
    , .outOfEuropeEOL
    , .permanentPasture
    , .plotSize
    ]


allComplementsToList : AbstractComplements a -> List a
allComplementsToList complements =
    allComplementsFields
        |> List.map (\fn -> fn complements)


applyComplementsToImpacts : Unit.Impact -> Impacts -> Impacts
applyComplementsToImpacts complement impacts =
    let
        ecoScore =
            Impact.getImpact Definition.Ecs impacts
    in
    impacts
        |> Impact.insertWithoutAggregateComputation Definition.Ecs
            (Quantity.difference ecoScore complement)


complementsImpactAsChartEntries : ComplementsImpacts -> List { color : String, name : String, value : Float }
complementsImpactAsChartEntries c =
    -- Notes:
    -- - We want those complements/bonuses to appear as negative values on the chart
    -- - We want to sum ecosystemic service components impacts to only have a single entry in the charts
    [ { color = "#606060", name = "Services écosystémiques", value = -(Unit.impactToFloat (sumEcosystemicImpacts c)) }
    , { color = "#c0c0c0", name = "Complément microfibres", value = -(c.microfibers |> Maybe.map Unit.impactToFloat |> Maybe.withDefault 0) }
    , { color = "#e0e0e0", name = "Complément export hors-Europe", value = -(c.outOfEuropeEOL |> Maybe.map Unit.impactToFloat |> Maybe.withDefault 0) }
    , { color = "#f1f1f1", name = "Complément " ++ labels.forest, value = -(c.forest |> Maybe.map Unit.impactToFloat |> Maybe.withDefault 0) }
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


divideComplementsImpactsBy : Float -> ComplementsImpacts -> ComplementsImpacts
divideComplementsImpactsBy n =
    mapComplements (Maybe.map (Quantity.divideBy n))


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


encodeComplementsImpacts : ComplementsImpacts -> Encode.Value
encodeComplementsImpacts =
    let
        encodeTuple label maybeComplement =
            ( label, maybeComplement |> Maybe.map Unit.encodeImpact )
    in
    negateComplementsImpacts
        >> allComplementsToList
        >> List.map2 encodeTuple (allComplementsToList identifiers)
        >> EU.optionalPropertiesObject


getTotalComplementsImpacts : ComplementsImpacts -> Unit.Impact
getTotalComplementsImpacts =
    allComplementsToList
        >> List.map (Maybe.withDefault Unit.noImpacts)
        >> Quantity.sum


impactsWithComplements : ComplementsImpacts -> Impacts -> Impacts
impactsWithComplements complementsImpacts impacts =
    let
        complementsImpact =
            getTotalComplementsImpacts complementsImpacts

        ecsWithComplements =
            Impact.getImpact Definition.Ecs impacts
                -- Reminder: substracting a malus — a.k.a negative complement — adds to the total impact
                |> Quantity.minus complementsImpact
    in
    impacts
        |> Impact.insertWithoutAggregateComputation Definition.Ecs ecsWithComplements


identifiers : ComplementsIdentifiers
identifiers =
    { cropDiversity = "cropDiversity"
    , forest = "forest"
    , hedges = "hedges"
    , livestockDensity = "livestockDensity"
    , microfibers = "microfibers"
    , outOfEuropeEOL = "outOfEuropeEOL"
    , permanentPasture = "permanentPasture"
    , plotSize = "plotSize"
    }


labels : ComplementsLabels
labels =
    { cropDiversity = "Diversité culturale"
    , forest = "Forêt"
    , hedges = "Haies"
    , livestockDensity = "Chargement territorial"
    , microfibers = "Microfibres"
    , outOfEuropeEOL = "Export hors-Europe"
    , permanentPasture = "Prairies permanentes"
    , plotSize = "Taille de parcelles"
    }


mapComplements : (a -> b) -> AbstractComplements a -> AbstractComplements b
mapComplements fn results =
    { cropDiversity = fn results.cropDiversity
    , forest = fn results.forest
    , hedges = fn results.hedges
    , livestockDensity = fn results.livestockDensity
    , microfibers = fn results.microfibers
    , outOfEuropeEOL = fn results.outOfEuropeEOL
    , permanentPasture = fn results.permanentPasture
    , plotSize = fn results.plotSize
    }


mapComplements2 : (a -> b -> c) -> AbstractComplements a -> AbstractComplements b -> AbstractComplements c
mapComplements2 fn a b =
    { cropDiversity = fn a.cropDiversity b.cropDiversity
    , forest = fn a.forest b.forest
    , hedges = fn a.hedges b.hedges
    , livestockDensity = fn a.livestockDensity b.livestockDensity
    , microfibers = fn a.microfibers b.microfibers
    , outOfEuropeEOL = fn a.outOfEuropeEOL b.outOfEuropeEOL
    , permanentPasture = fn a.permanentPasture b.permanentPasture
    , plotSize = fn a.plotSize b.plotSize
    }


mergeComplementsResultsImpacts : ComplementsResultsImpacts -> Impacts
mergeComplementsResultsImpacts =
    allComplementsToList
        >> List.filterMap identity
        >> Impact.sumImpacts


negateComplementsImpacts : ComplementsImpacts -> ComplementsImpacts
negateComplementsImpacts =
    mapComplements (Maybe.map (Unit.impactToFloat >> negate >> Unit.impact))


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


sumComplementsResultsImpacts : List ComplementsResultsImpacts -> ComplementsResultsImpacts
sumComplementsResultsImpacts =
    let
        sumImpacts complementsResultsImpacts complement =
            Impact.mapImpacts
                (\trigram impact ->
                    Quantity.sum
                        [ Impact.getImpact trigram (complementsResultsImpacts |> complement |> Maybe.withDefault Impact.empty)
                        , impact
                        ]
                )

        getNewImpact acc results complement =
            let
                newImpact =
                    acc
                        |> complement
                        |> Maybe.withDefault Impact.empty
                        |> sumImpacts results complement
            in
            if newImpact == Impact.empty then
                Nothing

            else
                Just newImpact
    in
    List.foldl
        (\acc complementsResultsImpacts ->
            { cropDiversity = getNewImpact acc complementsResultsImpacts .cropDiversity
            , forest = getNewImpact acc complementsResultsImpacts .forest
            , hedges = getNewImpact acc complementsResultsImpacts .hedges
            , livestockDensity = getNewImpact acc complementsResultsImpacts .livestockDensity
            , microfibers = getNewImpact acc complementsResultsImpacts .microfibers
            , outOfEuropeEOL = getNewImpact acc complementsResultsImpacts .outOfEuropeEOL
            , permanentPasture = getNewImpact acc complementsResultsImpacts .permanentPasture
            , plotSize = getNewImpact acc complementsResultsImpacts .plotSize
            }
        )
        emptyComplementsResultsImpacts


sumEcosystemicImpacts : ComplementsImpacts -> Unit.Impact
sumEcosystemicImpacts c =
    Quantity.sum
        [ c.cropDiversity |> Maybe.withDefault Unit.noImpacts
        , c.hedges |> Maybe.withDefault Unit.noImpacts
        , c.livestockDensity |> Maybe.withDefault Unit.noImpacts
        , c.permanentPasture |> Maybe.withDefault Unit.noImpacts
        , c.plotSize |> Maybe.withDefault Unit.noImpacts
        ]


totalComplementsImpactAsChartEntry : ComplementsImpacts -> { color : String, name : String, value : Float }
totalComplementsImpactAsChartEntry complementsImpacts =
    -- We want bonuses to appear as negative values on the chart, maluses as positive ones
    { color = "#808080"
    , name = "Compléments"
    , value = -(Unit.impactToFloat (getTotalComplementsImpacts complementsImpacts))
    }
