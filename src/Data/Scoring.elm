module Data.Scoring exposing
    ( Scoring
    , compute
    , empty
    )

import Data.Impact as Impact exposing (Impact)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.ImpactSet as ImpactSet exposing (Impacts)
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
                |> ImpactSet.getImpact Definition.Ecs

        subScores =
            perKgWithoutComplements
                |> ImpactSet.toProtectionAreas definitions
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
    { all = Impact.none
    , allWithoutComplements = Impact.none
    , biodiversity = Impact.none
    , climate = Impact.none
    , complements = Impact.none
    , health = Impact.none
    , resources = Impact.none
    }
