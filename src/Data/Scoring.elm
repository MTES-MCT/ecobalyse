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
    { all = Unit.impact 0
    , allWithoutComplements = Unit.impact 0
    , biodiversity = Unit.impact 0
    , climate = Unit.impact 0
    , complements = Unit.impact 0
    , health = Unit.impact 0
    , resources = Unit.impact 0
    }
