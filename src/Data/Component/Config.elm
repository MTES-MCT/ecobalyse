module Data.Component.Config exposing
    ( Config
    , EndOfLifeConfig
    , EndOfLifeStrategies
    , EndOfLifeStrategiesConfig
    , EndOfLifeStrategy
    , decode
    , default
    , parse
    )

import Data.Common.DecodeUtils as DU
import Data.Impact as Impact exposing (Impacts)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (MaterialDict)
import Data.Scope as Scope
import Data.Split as Split exposing (Split)
import Data.Transport as Transport exposing (Transport)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode


type alias Config =
    { endOfLife : EndOfLifeConfig
    , transports : TransportConfig
    }


type alias EndOfLifeConfig =
    { scopeCollectionRates : Scope.Dict Split
    , strategies : EndOfLifeStrategiesConfig
    }


type alias EndOfLifeStrategiesConfig =
    { default : EndOfLifeStrategies
    , collected : MaterialDict EndOfLifeStrategies
    , nonCollected : MaterialDict EndOfLifeStrategies
    }


type alias EndOfLifeStrategies =
    { incinerating : EndOfLifeStrategy
    , landfilling : EndOfLifeStrategy
    , recycling : EndOfLifeStrategy
    }


type alias EndOfLifeStrategy =
    { impacts : Impacts
    , process : Maybe Process
    , split : Split
    }


type alias TransportConfig =
    { defaultDistance : Transport
    , modeProcesses : Transport.ModeProcesses
    }


decode : List Process -> Decoder Config
decode processes =
    Decode.succeed Config
        |> Decode.required "endOfLife" (decodeEndOfLifeConfig processes)
        |> Decode.required "transports" (decodeTransportConfig processes)


decodeEndOfLifeConfig : List Process -> Decoder EndOfLifeConfig
decodeEndOfLifeConfig processes =
    Decode.succeed EndOfLifeConfig
        |> Decode.required "scopeCollectionRates" (Scope.decodeDict Split.decodePercent)
        |> Decode.required "strategies" (decodeEndOfLifeStrategiesConfig processes)


decodeEndOfLifeStrategiesConfig : List Process -> Decoder EndOfLifeStrategiesConfig
decodeEndOfLifeStrategiesConfig processes =
    Decode.succeed EndOfLifeStrategiesConfig
        |> Decode.required "default" (decodeEndOfLifeStrategies processes)
        |> Decode.required "collected" (Category.decodeMaterialDict (decodeEndOfLifeStrategies processes))
        |> Decode.required "nonCollected" (Category.decodeMaterialDict (decodeEndOfLifeStrategies processes))


decodeEndOfLifeStrategies : List Process -> Decoder EndOfLifeStrategies
decodeEndOfLifeStrategies processes =
    let
        noStrategy =
            { impacts = Impact.empty, process = Nothing, split = Split.zero }
    in
    Decode.succeed EndOfLifeStrategies
        |> DU.strictOptionalWithDefault "incinerating" (decodeEndOfLifeStrategy processes) noStrategy
        |> DU.strictOptionalWithDefault "landfilling" (decodeEndOfLifeStrategy processes) noStrategy
        |> DU.strictOptionalWithDefault "recycling" (decodeEndOfLifeStrategy processes) noStrategy
        |> Decode.andThen validateEndOfLifeStrategies


validateEndOfLifeStrategies : EndOfLifeStrategies -> Decoder EndOfLifeStrategies
validateEndOfLifeStrategies ({ incinerating, landfilling, recycling } as strategy) =
    case
        [ incinerating, landfilling, recycling ]
            |> List.map .split
            |> Split.assemble
    of
        Err err ->
            Decode.fail <| "Stratégies de fin de vie invalides\u{00A0}: " ++ err

        Ok _ ->
            Decode.succeed strategy


decodeEndOfLifeStrategy : List Process -> Decoder EndOfLifeStrategy
decodeEndOfLifeStrategy processes =
    Decode.succeed EndOfLifeStrategy
        |> Decode.hardcoded Impact.empty
        |> DU.strictOptional "processId" (Process.decodeFromId processes)
        |> Decode.required "percent" Split.decodePercent


decodeTransportConfig : List Process -> Decoder TransportConfig
decodeTransportConfig processes =
    Decode.succeed TransportConfig
        |> Decode.required "defaultDistance" Transport.decode
        |> Decode.required "modeProcesses" (Transport.decodeModeProcesses processes)


default : List Process -> Result String Config
default processes =
    parse processes
        """
        {
            "endOfLife": {
                "scopeCollectionRates": {},
                "strategies": {
                    "default": {
                        "incinerating": null,
                        "landfilling": null,
                        "recycling": { "percent": 100 }
                    },
                    "collected": {},
                    "nonCollected": {}
                }
            },
            "transports": {
                "defaultDistance": {
                    "air": 0,
                    "road": 0,
                    "sea": 0
                },
                "modeProcesses": {
                    "boat": "20a62b2c-a543-5076-83aa-c5b7d340206a",
                    "boatCooling": "3cb99d44-24f6-5f6e-a8f8-f754fe44d641",
                    "lorry": "46e96f29-9ca5-5475-bb3c-6397f43b7a5b",
                    "lorryCooling": "219b986c-9751-58cf-977e-7ba8f0b4ae2b",
                    "plane": "3364ef93-b936-531a-8f5a-432349aef398"
                }
            }
        }
        """


parse : List Process -> String -> Result String Config
parse processes json =
    json
        |> Decode.decodeString (decode processes)
        |> Result.mapError Decode.errorToString
