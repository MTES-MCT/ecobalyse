module Data.Food.EcosystemicServices exposing
    ( EcosystemicServices
    , decode
    )

import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe


type alias EcosystemicServices =
    { hedges : Unit.Impact
    , plotSize : Unit.Impact
    , cropDiversity : Unit.Impact
    , permanentPasture : Unit.Impact
    , livestockDensity : Unit.Impact
    , selfSufficiency : Unit.Impact
    }


decode : Decoder EcosystemicServices
decode =
    Decode.succeed EcosystemicServices
        |> Pipe.required "hedges" Unit.decodeImpact
        |> Pipe.required "plotSize" Unit.decodeImpact
        |> Pipe.required "cropDiversity" Unit.decodeImpact
        |> Pipe.required "permanentPasture" Unit.decodeImpact
        |> Pipe.required "livestockDensity" Unit.decodeImpact
        |> Pipe.required "selfSufficiency" Unit.decodeImpact
