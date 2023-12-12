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
    AbstractEcosystemicServices Float


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
    { hedges = 7
    , plotSize = 4
    , cropDiversity = 2
    , permanentPasture = 10.5
    , livestockDensity = 1
    , selfSufficiency = 1
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


labels :
    List
        ( String
        , { a
            | hedges : b
            , plotSize : b
            , cropDiversity : b
            , permanentPasture : b
            , livestockDensity : b
            , selfSufficiency : b
          }
          -> b
        )
labels =
    [ ( "Haies", .hedges )
    , ( "Taille des parcelles", .plotSize )
    , ( "Diversité culturale", .cropDiversity )
    , ( "Prairies permanentes", .permanentPasture )
    , ( "Chargement territorial", .livestockDensity )
    , ( "Autonomie territoriale", .selfSufficiency )
    ]
