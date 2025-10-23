module Data.Object.Simulator exposing
    ( compute
    , toStepsImpacts
    )

import Data.Component as Component exposing (LifeCycle)
import Data.Impact as Impact exposing (noStepsImpacts)
import Data.Impact.Definition as Definition
import Data.Object.Query exposing (Query)
import Data.Scope exposing (Scope)
import Static.Db exposing (Db)


compute : Db -> Scope -> Query -> Result String LifeCycle
compute db scope query =
    query.components
        |> Component.compute db scope


toStepsImpacts : Definition.Trigram -> LifeCycle -> Impact.StepsImpacts
toStepsImpacts trigram lifeCycle =
    { noStepsImpacts
        | endOfLife =
            lifeCycle.endOfLife
                |> Impact.getImpact trigram
                |> Just
        , materials =
            Component.extractImpacts lifeCycle.production
                |> Impact.getImpact trigram
                |> Just
    }
