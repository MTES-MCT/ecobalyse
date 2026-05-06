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
    { cropDiversity = Unit.ratio 1.11
    , hedges = Unit.ratio 6.34
    , permanentPasture = Unit.ratio 7.28
    , plotSize = Unit.ratio 7.12
    }


decode : Decoder EcosystemicServices
decode =
    Decode.succeed AbstractEcosystemicServices
        |> Pipe.optional "cropDiversity" Unit.decodeImpact Unit.noImpacts
        |> Pipe.optional "hedges" Unit.decodeImpact Unit.noImpacts
        |> Pipe.optional "permanentPasture" Unit.decodeImpact Unit.noImpacts
        |> Pipe.optional "plotSize" Unit.decodeImpact Unit.noImpacts


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
