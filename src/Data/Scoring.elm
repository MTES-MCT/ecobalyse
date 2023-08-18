module Data.Scoring exposing (Scoring, compute)

import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Unit as Unit
import Quantity


type alias Scoring =
    { all : Unit.Impact
    , allWithoutComplements : Unit.Impact
    , complements : Unit.Impact
    , climate : Unit.Impact
    , biodiversity : Unit.Impact
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
    , complements = totalComplementsImpactPerKg
    , climate = subScores.climate
    , biodiversity = subScores.biodiversity
    , health = subScores.health
    , resources = subScores.resources
    }
