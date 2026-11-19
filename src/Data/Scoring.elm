module Data.Scoring exposing
    ( Scoring
    , compute
    , empty
    )

import Data.Impact as Impact exposing (Impact)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Impacts as Impacts exposing (Impacts)
import Quantity


type alias Scoring =
    { all : Impact
    , allWithoutComplements : Impact
    , biodiversity : Impact
    , climate : Impact
    , complements : Impact
    , health : Impact
    , resources : Impact
    }


compute : Definitions -> Impact -> Impacts -> Scoring
compute definitions totalComplementsImpactPerKg perKgWithoutComplements =
    let
        ecsPerKgWithoutComplements =
            perKgWithoutComplements
                |> Impacts.getImpact Definition.Ecs

        subScores =
            perKgWithoutComplements
                |> Impacts.toProtectionAreas definitions
    in
    { all =
        -- Reminder: complements are stored using the same convention as impacts and therefore must be **added** not substracted
        -- `value < 0` -> decreased environmental impact
        -- `value > 0` -> increased environmental impact
        Quantity.plus ecsPerKgWithoutComplements totalComplementsImpactPerKg
    , allWithoutComplements = ecsPerKgWithoutComplements
    , biodiversity = subScores.biodiversity
    , climate = subScores.climate
    , complements = totalComplementsImpactPerKg
    , health = subScores.health
    , resources = subScores.resources
    }


empty : Scoring
empty =
    { all = Impact.noImpacts
    , allWithoutComplements = Impact.noImpacts
    , biodiversity = Impact.noImpacts
    , climate = Impact.noImpacts
    , complements = Impact.noImpacts
    , health = Impact.noImpacts
    , resources = Impact.noImpacts
    }
