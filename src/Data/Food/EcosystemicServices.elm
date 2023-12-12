module Data.Food.EcosystemicServices exposing
    ( EcosystemicServices
    , coefficients
    , decode
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
    , selfSufficiency : a
    }


coefficients : Coefficients
coefficients =
    { hedges = Unit.ratio 7
    , plotSize = Unit.ratio 4
    , cropDiversity = Unit.ratio 2
    , permanentPasture = Unit.ratio 10.5
    , livestockDensity = Unit.ratio 1
    , selfSufficiency = Unit.ratio 1
    }


labels : Labels
labels =
    { hedges = "Haies"
    , plotSize = "Taille de parcelles"
    , cropDiversity = "Diversité culturale"
    , permanentPasture = "Prairies permanentes"
    , livestockDensity = "Chargement territorial"
    , selfSufficiency = "Autonomie territoriale"
    }


decode : Decoder EcosystemicServices
decode =
    Decode.succeed AbstractEcosystemicServices
        |> Pipe.required "hedges" Unit.decodeImpact
        |> Pipe.required "plotSize" Unit.decodeImpact
        |> Pipe.required "cropDiversity" Unit.decodeImpact
        |> Pipe.required "permanentPasture" Unit.decodeImpact
        |> Pipe.required "livestockDensity" Unit.decodeImpact
        |> Pipe.required "selfSufficiency" Unit.decodeImpact
