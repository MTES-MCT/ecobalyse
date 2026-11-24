module Data.Generic.Simulator exposing
    ( compute
    , toStagesImpacts
    )

import Data.Component as Component exposing (LifeCycle)
import Data.Db exposing (Db)
import Data.Impact.Definition as Definition
import Data.ImpactSet as ImpactSet
import Data.Stages as Stages


compute : Component.Requirements Db -> Component.Query -> Result String LifeCycle
compute requirements =
    Component.validateQuery requirements
        >> Result.andThen (Component.compute requirements)


toStagesImpacts : Definition.Trigram -> LifeCycle -> ImpactSet.StagesImpacts
toStagesImpacts trigram =
    Component.stagesImpacts
        >> Stages.map (Maybe.map (ImpactSet.getImpact trigram))
