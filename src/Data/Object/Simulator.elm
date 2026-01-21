module Data.Object.Simulator exposing
    ( compute
    , toStagesImpacts
    )

import Data.Component as Component exposing (LifeCycle)
import Data.Impact as Impact exposing (noStagesImpacts)
import Data.Impact.Definition as Definition
import Static.Db exposing (Db)


compute : Component.Requirements Db -> Component.Query -> Result String LifeCycle
compute requirements query =
    query
        |> Component.compute requirements


toStagesImpacts : Definition.Trigram -> LifeCycle -> Impact.StagesImpacts
toStagesImpacts trigram lifeCycle =
    let
        stagesImpacts =
            Component.stagesImpacts lifeCycle
    in
    { noStagesImpacts
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
