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
    let
        stagesImpacts =
            Component.stagesImpacts lifeCycle
    in
    { noStepsImpacts
        | endOfLife =
            stagesImpacts.endOfLife
                |> Impact.getImpact trigram
                |> Just
        , materials =
            stagesImpacts.material
                |> Impact.getImpact trigram
                |> Just
        , transform =
            stagesImpacts.transformation
                |> Impact.getImpact trigram
                |> Just
        , transports =
            stagesImpacts.transports
                |> Impact.getImpact trigram
                |> Just
        , usage =
            stagesImpacts.use
                |> Impact.getImpact trigram
                |> Just
    }
