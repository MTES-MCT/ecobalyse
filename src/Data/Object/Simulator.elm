module Data.Object.Simulator exposing
    ( compute
    , toStagesImpacts
    )

import Data.Component as Component exposing (LifeCycle)
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Stages as Stages
import Static.Db exposing (Db)


compute : Component.Requirements Db -> Component.Query -> Result String LifeCycle
compute requirements =
    Component.compute requirements


toStagesImpacts : Definition.Trigram -> LifeCycle -> Impact.StagesImpacts
toStagesImpacts trigram =
    Component.stagesImpacts
        >> Stages.map (Maybe.map (Impact.getImpact trigram))
