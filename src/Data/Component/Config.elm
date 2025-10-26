module Data.Component.Config exposing
    ( Config
    , EndOfLifeConfig
    , EndOfLifeStrategies
    , EndOfLifeStrategy
    , config
    )

import Data.Common.DecodeUtils as DU
import Data.Impact as Impact exposing (Impacts)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode


{-| Holds a dict where keys are material types
TODO: move to Data.Process.Category?
-}
type alias MaterialDict a =
    AnyDict String Category.Material a


{-| Holds a dict where keys are scopes
TODO: move to Data.Scope?
-}
type alias ScopeDict a =
    AnyDict String Scope a


type alias Config =
    { endOfLife : EndOfLifeConfig
    }


type alias EndOfLifeConfig =
    { scopeCollectionRates : ScopeDict Split
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
        |> Decode.required "scopeCollectionRates" decodeScopeCollectionRates
        |> Decode.required "strategies" (decodeEndOfLifeStrategiesConfig processes)


decodeScopeCollectionRates : Decoder (ScopeDict Split)
decodeScopeCollectionRates =
    AnyDict.decode_
        (\key _ -> Scope.fromString key)
        Scope.toString
        Split.decodePercent


decodeEndOfLifeStrategiesConfig : List Process -> Decoder EndOfLifeStrategiesConfig
decodeEndOfLifeStrategiesConfig processes =
    Decode.succeed EndOfLifeStrategiesConfig
        |> Decode.required "default" (decodeEndOfLifeStrategies processes)
        |> Decode.required "collected" (decodeMaterialStrategies processes)
        |> Decode.required "nonCollected" (decodeMaterialStrategies processes)


decodeMaterialStrategies : List Process -> Decoder (MaterialDict EndOfLifeStrategies)
decodeMaterialStrategies processes =
    AnyDict.decode_
        (\key _ -> Category.materialTypeFromString key)
        Category.materialTypeToString
        (decodeEndOfLifeStrategies processes)


decodeEndOfLifeStrategies : List Process -> Decoder EndOfLifeStrategies
decodeEndOfLifeStrategies processes =
    Decode.succeed EndOfLifeStrategies
        |> Decode.required "incinerating" (decodeEndOfLifeStrategy processes)
        |> Decode.required "landfilling" (decodeEndOfLifeStrategy processes)
        |> Decode.required "recycling" (decodeEndOfLifeStrategy processes)
        |> Decode.andThen
            (\({ incinerating, landfilling, recycling } as strategy) ->
                case [ incinerating, landfilling, recycling ] |> List.map .split |> Split.sum of
                    Err err ->
                        Decode.fail err

                    Ok _ ->
                        Decode.succeed strategy
            )


decodeEndOfLifeStrategy : List Process -> Decoder EndOfLifeStrategy
decodeEndOfLifeStrategy processes =
    Decode.succeed EndOfLifeStrategy
        |> Decode.hardcoded Impact.empty
        |> DU.strictOptional "process" (Process.decodeFromId processes)
        |> Decode.required "share" Split.decodePercent


jsonConfig : String
jsonConfig =
    """
    {
        "endOfLife": {
            "scopeCollectionRates": {
              "object": 70
            },
            "strategies": {
                "default": {
                    "incinerating": { "process": "6fad4e70-5736-552d-a686-97e4fb627c37", "share": 82 },
                    "landfilling": { "process": "d4954f69-e647-531d-aa32-c34be5556736", "share": 18 },
                    "recycling": null
                },
                "collected": {
                    "metal": {
                        "incinerating": null,
                        "landfilling": null,
                        "recycling": { "share": 100 }
                    },
                    "plastic": {
                        "incinerating": { "process": "17986210-aeb8-5f4f-99fd-cbecb5439fde", "share": 8 },
                        "landfilling": null,
                        "recycling": { "share": 92 }
                    },
                    "upholstery": {
                        "incinerating": { "process": "3fe5a5b1-c1b2-5c17-8b59-0e37b09f1037", "share": 94 },
                        "landfilling": { "process": "d4954f69-e647-531d-aa32-c34be5556736", "share": 2 },
                        "recycling": { "share": 4 }
                    },
                    "wood": {
                        "incinerating": { "process": "316be695-bf3e-5562-9f09-77f213c3ec67", "share": 31 },
                        "landfilling": null,
                        "recycling": { "share": 69 }
                    }
                },
                "nonCollected": {
                    "metal": {
                        "incinerating": { "process": "5719f399-c2a3-5268-84e2-894aba588f1b", "share": 5 },
                        "landfilling": { "process": "d4954f69-e647-531d-aa32-c34be5556736", "share": 5 },
                        "recycling": { "share": 90 }
                    }
                }
            }
        }
    }
    """


config : List Process -> Result String Config
config processes =
    jsonConfig
        |> Decode.decodeString (decodeConfig processes)
        |> Result.mapError Decode.errorToString
