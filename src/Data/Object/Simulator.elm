module Data.Object.Simulator exposing
    ( compute
    , toStepsImpacts
    )

import Data.Component as Component exposing (LifeCycle)
import Data.Impact as Impact exposing (noStepsImpacts)
import Data.Impact.Definition as Definition
import Static.Db exposing (Db)


compute : Component.Requirements Db -> Component.Query -> Result String LifeCycle
compute requirements query =
    query
        |> Component.compute requirements


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
        , transports =
            Component.getTotalTransportImpacts lifeCycle.transports
                |> Impact.getImpact trigram
                |> Just
        , usage =
            lifeCycle.use
                |> Impact.sumImpacts
                |> Impact.getImpact trigram
                |> Just
    }
