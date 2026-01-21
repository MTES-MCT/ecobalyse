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
    -- FIXME: we should have Impact.mapStagesMaybe or eq.
    { noStagesImpacts
        | endOfLife = stagesImpacts.endOfLife |> Maybe.map (Impact.getImpact trigram)
        , materials = stagesImpacts.materials |> Maybe.map (Impact.getImpact trigram)
        , transform = stagesImpacts.transform |> Maybe.map (Impact.getImpact trigram)
        , transports = stagesImpacts.transports |> Maybe.map (Impact.getImpact trigram)
        , usage = stagesImpacts.usage |> Maybe.map (Impact.getImpact trigram)
    }
