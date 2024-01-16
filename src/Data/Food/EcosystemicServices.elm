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
    { hedges : a
    , plotSize : a
    , cropDiversity : a
    , permanentPasture : a
    , livestockDensity : a
    }


coefficients : Coefficients
coefficients =
    { hedges = Unit.ratio 7
    , plotSize = Unit.ratio 4
    , cropDiversity = Unit.ratio 2
    , permanentPasture = Unit.ratio 10.5
    , livestockDensity = Unit.ratio 1
    }


decode : Decoder EcosystemicServices
decode =
    Decode.succeed AbstractEcosystemicServices
        |> Pipe.optional "hedges" Unit.decodeImpact (Unit.impact 0)
        |> Pipe.optional "plotSize" Unit.decodeImpact (Unit.impact 0)
        |> Pipe.optional "cropDiversity" Unit.decodeImpact (Unit.impact 0)
        |> Pipe.optional "permanentPasture" Unit.decodeImpact (Unit.impact 0)
        |> Pipe.optional "livestockDensity" Unit.decodeImpact (Unit.impact 0)


empty : EcosystemicServices
empty =
    { hedges = Unit.impact 0
    , plotSize = Unit.impact 0
    , cropDiversity = Unit.impact 0
    , permanentPasture = Unit.impact 0
    , livestockDensity = Unit.impact 0
    }


labels : Labels
labels =
    { hedges = "Haies"
    , plotSize = "Taille de parcelles"
    , cropDiversity = "Diversité culturale"
    , permanentPasture = "Prairies permanentes"
    , livestockDensity = "Chargement territorial"
    }
