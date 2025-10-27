module Data.Component.Config exposing
    ( Config
    , EndOfLifeConfig
    , EndOfLifeStrategies
    , EndOfLifeStrategiesConfig
    , EndOfLifeStrategy
    , default
    )

import Data.Common.DecodeUtils as DU
import Data.Impact as Impact exposing (Impacts)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (MaterialDict)
import Data.Scope as Scope
import Data.Split as Split exposing (Split)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode


type alias Config =
    { endOfLife : EndOfLifeConfig
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


decodeConfig : List Process -> Decoder Config
decodeConfig processes =
    Decode.succeed Config
        |> Decode.required "endOfLife" (decodeEndOfLifeConfig processes)


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


defaultJsonConfig : String
defaultJsonConfig =
    """
    {
        "endOfLife": {
            "scopeCollectionRates": {
              "object": 70
            },
            "strategies": {
                "default": {
                    "incinerating": { "processId": "6fad4e70-5736-552d-a686-97e4fb627c37", "percent": 82 },
                    "landfilling": { "processId": "d4954f69-e647-531d-aa32-c34be5556736", "percent": 18 },
                    "recycling": null
                },
                "collected": {
                    "metal": {
                        "incinerating": null,
                        "landfilling": null,
                        "recycling": { "percent": 100 }
                    },
                    "plastic": {
                        "incinerating": { "processId": "17986210-aeb8-5f4f-99fd-cbecb5439fde", "percent": 8 },
                        "landfilling": null,
                        "recycling": { "percent": 92 }
                    },
                    "upholstery": {
                        "incinerating": { "processId": "3fe5a5b1-c1b2-5c17-8b59-0e37b09f1037", "percent": 94 },
                        "landfilling": { "processId": "d4954f69-e647-531d-aa32-c34be5556736", "percent": 2 },
                        "recycling": { "percent": 4 }
                    },
                    "wood": {
                        "incinerating": { "processId": "316be695-bf3e-5562-9f09-77f213c3ec67", "percent": 31 },
                        "landfilling": null,
                        "recycling": { "percent": 69 }
                    }
                },
                "nonCollected": {
                    "metal": {
                        "incinerating": { "processId": "5719f399-c2a3-5268-84e2-894aba588f1b", "percent": 5 },
                        "landfilling": { "processId": "d4954f69-e647-531d-aa32-c34be5556736", "percent": 5 },
                        "recycling": { "percent": 90 }
                    }
                }
            }
        }
    }
    """


default : List Process -> Result String Config
default processes =
    defaultJsonConfig
        |> parse processes


parse : List Process -> String -> Result String Config
parse processes json =
    json
        |> Decode.decodeString (decodeConfig processes)
        |> Result.mapError Decode.errorToString
