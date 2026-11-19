module Data.Food.EcosystemicServices exposing
    ( EcosystemicServices
    , decode
    , empty
    , labels
    )

import Data.Impact as Impact exposing (Impact)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe


type alias EcosystemicServices =
    AbstractEcosystemicServices Impact


type alias Labels =
    AbstractEcosystemicServices String


type alias AbstractEcosystemicServices a =
    { cropDiversity : a
    , hedges : a
    , permanentPasture : a
    , plotSize : a
    }


decode : Decoder EcosystemicServices
decode =
    Decode.succeed AbstractEcosystemicServices
        -- We need to negate the complements to stay backward compatible as the old format in ingredients.json was not accurate
        -- see https://github.com/MTES-MCT/ecobalyse-data/pull/263
        |> Pipe.optional "cropDiversity" Impact.decodeAndNegateImpact Impact.noImpacts
        |> Pipe.optional "hedges" Impact.decodeAndNegateImpact Impact.noImpacts
        |> Pipe.optional "permanentPasture" Impact.decodeAndNegateImpact Impact.noImpacts
        |> Pipe.optional "plotSize" Impact.decodeAndNegateImpact Impact.noImpacts


empty : EcosystemicServices
empty =
    { cropDiversity = Impact.noImpacts
    , hedges = Impact.noImpacts
    , permanentPasture = Impact.noImpacts
    , plotSize = Impact.noImpacts
    }


labels : Labels
labels =
    { cropDiversity = "Diversité culturale"
    , hedges = "Haies"
    , permanentPasture = "Prairies permanentes"
    , plotSize = "Taille de parcelles"
    }
