module Data.Object.Simulator exposing
    ( availableComponents
    , compute
    , toStepsImpacts
    )

import Data.Component as Component exposing (Component, Results)
import Data.Impact as Impact exposing (noStepsImpacts)
import Data.Impact.Definition as Definition
import Data.Object.Query exposing (Query)
import Result.Extra as RE
import Static.Db exposing (Db)


availableComponents : Db -> Query -> List Component
availableComponents { object } query =
    object.components
        |> List.filter
            (\{ id } ->
                query.components
                    |> List.map .id
                    |> List.member id
                    |> not
            )
        |> List.sortBy .name


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
