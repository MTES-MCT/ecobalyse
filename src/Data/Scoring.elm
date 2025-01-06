module Data.Scoring exposing
    ( Scoring
    , compute
    , empty
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Unit as Unit
import Quantity


type alias Scoring =
    { all : Unit.Impact
    , allWithoutComplements : Unit.Impact
    , biodiversity : Unit.Impact
    , climate : Unit.Impact
    , complements : Unit.Impact
    , health : Unit.Impact
    , resources : Unit.Impact
    }


compute : Definitions -> Unit.Impact -> Impacts -> Scoring
compute definitions totalComplementsImpactPerKg perKgWithoutComplements =
    let
        ecsPerKgWithoutComplements =
            perKgWithoutComplements
                |> Impact.getImpact Definition.Ecs

        subScores =
            perKgWithoutComplements
                |> Impact.toProtectionAreas definitions
    in
    { all = Quantity.difference ecsPerKgWithoutComplements totalComplementsImpactPerKg
    , allWithoutComplements = ecsPerKgWithoutComplements
    , biodiversity = subScores.biodiversity
    , climate = subScores.climate
    , complements = totalComplementsImpactPerKg
    , health = subScores.health
    , resources = subScores.resources
    }


empty : Scoring
empty =
    { all = Unit.noImpacts
    , allWithoutComplements = Unit.noImpacts
    , biodiversity = Unit.noImpacts
    , climate = Unit.noImpacts
    , complements = Unit.noImpacts
    , health = Unit.noImpacts
    , resources = Unit.noImpacts
    }
