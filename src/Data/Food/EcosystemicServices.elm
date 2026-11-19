module Data.Food.EcosystemicServices exposing
    ( EcosystemicServices
    , decode
    , empty
    , labels
    )

import Data.Impact as Impact exposing (Impact)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Quantity


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
        |> Pipe.optional "cropDiversity" decodeAndNegateImpact Impact.none
        |> Pipe.optional "hedges" decodeAndNegateImpact Impact.none
        |> Pipe.optional "permanentPasture" decodeAndNegateImpact Impact.none
        |> Pipe.optional "plotSize" decodeAndNegateImpact Impact.none


decodeAndNegateImpact : Decoder Impact
decodeAndNegateImpact =
    Decode.map Quantity.negate Impact.decoder


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
