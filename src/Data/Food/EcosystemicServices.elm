module Data.Food.EcosystemicServices exposing
    ( EcosystemicServices
    , coefficients
    , decode
    , empty
    , labels
    )

import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe


type alias EcosystemicServices =
    AbstractEcosystemicServices Unit.Impact


type alias Coefficients =
    AbstractEcosystemicServices Unit.Ratio


type alias Labels =
    AbstractEcosystemicServices String


type alias AbstractEcosystemicServices a =
    { cropDiversity : a
    , hedges : a
    , permanentPasture : a
    , plotSize : a
    }


coefficients : Coefficients
coefficients =
    { cropDiversity = Unit.ratio 1.5
    , hedges = Unit.ratio 3
    , permanentPasture = Unit.ratio 7
    , plotSize = Unit.ratio 4
    }


decode : Decoder EcosystemicServices
decode =
    Decode.succeed AbstractEcosystemicServices
        -- We need to negate the complements to stay backward compatible as the old format in ingredients.json was not accurate
        -- see https://github.com/MTES-MCT/ecobalyse-data/pull/263
        |> Pipe.optional "cropDiversity" Unit.decodeAndNegateImpact Unit.noImpacts
        |> Pipe.optional "hedges" Unit.decodeAndNegateImpact Unit.noImpacts
        |> Pipe.optional "permanentPasture" Unit.decodeAndNegateImpact Unit.noImpacts
        |> Pipe.optional "plotSize" Unit.decodeAndNegateImpact Unit.noImpacts


empty : EcosystemicServices
empty =
    { cropDiversity = Unit.noImpacts
    , hedges = Unit.noImpacts
    , permanentPasture = Unit.noImpacts
    , plotSize = Unit.noImpacts
    }


labels : Labels
labels =
    { cropDiversity = "Diversité culturale"
    , hedges = "Haies"
    , permanentPasture = "Prairies permanentes"
    , plotSize = "Taille de parcelles"
    }
