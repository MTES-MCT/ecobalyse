module Data.Food.EcosystemicServices exposing (EcosystemicServices)

import Data.Unit as Unit


type alias EcosystemicServices =
    { hedges : Unit.Impact
    , plotSize : Unit.Impact
    , culturalDiversity : Unit.Impact
    , permanentMeadows : Unit.Impact
    , territorialLoading : Unit.Impact
    , territorialAutonomy : Unit.Impact
    }
