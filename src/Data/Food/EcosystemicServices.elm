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
    , culturalDiversity : Unit.Impact
    , permanentMeadows : Unit.Impact
    , territorialLoading : Unit.Impact
    , territorialAutonomy : Unit.Impact
    }


decode : Decoder EcosystemicServices
decode =
    Decode.succeed EcosystemicServices
        |> Pipe.required "hedges" Unit.decodeImpact
        |> Pipe.required "plotSize" Unit.decodeImpact
        |> Pipe.required "culturalDiversity" Unit.decodeImpact
        |> Pipe.required "permanentMeadows" Unit.decodeImpact
        |> Pipe.required "territorialLoading" Unit.decodeImpact
        |> Pipe.required "territorialAutonomy" Unit.decodeImpact
