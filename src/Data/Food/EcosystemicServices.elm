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
        |> Pipe.optional "cropDiversity" Impact.decodeAndNegateImpact Impact.none
        |> Pipe.optional "hedges" Impact.decodeAndNegateImpact Impact.none
        |> Pipe.optional "permanentPasture" Impact.decodeAndNegateImpact Impact.none
        |> Pipe.optional "plotSize" Impact.decodeAndNegateImpact Impact.none


empty : EcosystemicServices
empty =
    { cropDiversity = Impact.none
    , hedges = Impact.none
    , permanentPasture = Impact.none
    , plotSize = Impact.none
    }


labels : Labels
labels =
    { cropDiversity = "Diversité culturale"
    , hedges = "Haies"
    , permanentPasture = "Prairies permanentes"
    , plotSize = "Taille de parcelles"
    }
