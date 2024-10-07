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
    , livestockDensity : a
    , permanentPasture : a
    , plotSize : a
    }


coefficients : Coefficients
coefficients =
    { cropDiversity = Unit.ratio 1.5
    , hedges = Unit.ratio 3
    , livestockDensity = Unit.ratio 3000
    , permanentPasture = Unit.ratio 7
    , plotSize = Unit.ratio 4
    }


decode : Decoder EcosystemicServices
decode =
    Decode.succeed AbstractEcosystemicServices
        |> Pipe.optional "cropDiversity" Unit.decodeImpact (Unit.impact 0)
        |> Pipe.optional "hedges" Unit.decodeImpact (Unit.impact 0)
        |> Pipe.optional "livestockDensity" Unit.decodeImpact (Unit.impact 0)
        |> Pipe.optional "permanentPasture" Unit.decodeImpact (Unit.impact 0)
        |> Pipe.optional "plotSize" Unit.decodeImpact (Unit.impact 0)


empty : EcosystemicServices
empty =
    { cropDiversity = Unit.impact 0
    , hedges = Unit.impact 0
    , livestockDensity = Unit.impact 0
    , permanentPasture = Unit.impact 0
    , plotSize = Unit.impact 0
    }


labels : Labels
labels =
    { cropDiversity = "Diversité culturale"
    , hedges = "Haies"
    , livestockDensity = "Chargement territorial"
    , permanentPasture = "Prairies permanentes"
    , plotSize = "Taille de parcelles"
    }
