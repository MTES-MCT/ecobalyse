module Data.Stages exposing (Stages, map)


type alias Stages a =
    { distribution : a
    , endOfLife : a
    , materials : a
    , packaging : a
    , transform : a
    , transports : a
    , trims : a
    , usage : a
    }


map : (a -> b) -> Stages a -> Stages b
map fn stages =
    { distribution = fn stages.distribution
    , endOfLife = fn stages.endOfLife
    , materials = fn stages.materials
    , packaging = fn stages.packaging
    , transform = fn stages.transform
    , transports = fn stages.transports
    , trims = fn stages.trims
    , usage = fn stages.usage
    }
