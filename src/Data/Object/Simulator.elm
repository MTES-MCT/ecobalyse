module Data.Object.Simulator exposing
    ( compute
    , toStepsImpacts
    )

import Data.Component as Component exposing (Results)
import Data.Impact as Impact exposing (noStepsImpacts)
import Data.Impact.Definition as Definition
import Data.Object.Query exposing (Query)
import Result.Extra as RE
import Static.Db exposing (Db)


compute : Db -> Query -> Result String Results
compute { object } query =
    query.components
        |> List.map (Component.computeComponentItemResults object.components object.processes)
        |> RE.combine
        |> Result.map (List.foldr Component.addResults Component.emptyResults)


toStepsImpacts : Definition.Trigram -> Results -> Impact.StepsImpacts
toStepsImpacts trigram results =
    { noStepsImpacts
      -- FIXME: for now, as we only have materials, assign everything to the material step
        | materials =
            Component.extractImpacts results
                |> Impact.getImpact trigram
                |> Just
    }
