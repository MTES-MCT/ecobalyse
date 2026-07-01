module Data.Component.Config exposing
    ( Config
    , EndOfLifeConfig
    , EndOfLifeStrategies
    , EndOfLifeStrategiesConfig
    , EndOfLifeStrategy
    , decode
    , default
    , getDocLink
    , parse
    , scopeEnabled
    )

import Data.Common.DecodeUtils as DU
import Data.Country as Country exposing (Country)
import Data.Impact as Impact exposing (Impacts)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (MaterialDict)
import Data.Scope as Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.Transport as Transport exposing (Transport)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode


type alias Config =
    { distribution : DistributionConfig
    , docLinks : DocLinks
    , durability : DurabilityConfig
    , endOfLife : EndOfLifeConfig
    , production : ProductionConfig
    , transports : TransportConfig
    , use : UseConfig
    }


{-| A Db-like interface holding countries and processes
-}
type alias DataContainer db =
    { db
        | countries : List Country
        , processes : List Process
    }


type alias DistributionConfig =
    { country : Country
    , defaultProcess : Scope.Dict (Maybe Process)
    }


type alias DocLinks =
    { default : Dict String String
    , rootUrl : String
    , scoped : Scope.Dict (Dict String String)
    }


type alias DurabilityConfig =
    { enabled : Scope.Dict Bool }


type alias EndOfLifeConfig =
    { enabled : Scope.Dict Bool
    , scopeCollectionRates : Scope.Dict Split
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


type alias ProductionConfig =
    { defaultElecProcess : Process
    , defaultHeatProcess : Process
    }


type alias TransportConfig =
    { defaultDistance : Transport
    , modeProcesses : Transport.ModeProcesses
    }


type alias UseConfig =
    { defaultElecProcess : Process
    , defaultHeatProcess : Process
    }


decode : { db | countries : List Country, processes : List Process } -> Decoder Config
decode { countries, processes } =
    Decode.succeed Config
        |> Decode.required "distribution" (decodeDistributionConfig processes countries)
        |> Decode.required "docLinks" decodeDocLinks
        |> Decode.required "durability" decodeDurabilityConfig
        |> Decode.required "endOfLife" (decodeEndOfLifeConfig processes)
        |> Decode.required "production" (decodeProductionConfig processes)
        |> Decode.required "transports" (decodeTransportConfig processes)
        |> Decode.required "use" (decodeUseConfig processes)


decodeDistributionConfig : List Process -> List Country -> Decoder DistributionConfig
decodeDistributionConfig processes countries =
    Decode.succeed DistributionConfig
        |> Decode.required "country" (Country.decodeFromCode countries)
        |> Decode.required "defaultProcess" (decodeScopedMaybeProcess processes)


decodeDocLinks : Decoder DocLinks
decodeDocLinks =
    Decode.succeed DocLinks
        |> Decode.required "default" (Decode.dict Decode.string)
        |> Decode.required "rootUrl" Decode.string
        |> Decode.required "scoped" (Scope.decodeDict (Decode.dict Decode.string))


decodeScopedMaybeProcess : List Process -> Decoder (Scope.Dict (Maybe Process))
decodeScopedMaybeProcess processes =
    Scope.decodeDict (Decode.maybe (Process.decodeFromId processes))


decodeDurabilityConfig : Decoder DurabilityConfig
decodeDurabilityConfig =
    Decode.succeed DurabilityConfig
        |> Decode.required "enabled" (Scope.decodeDict Decode.bool)


decodeEndOfLifeConfig : List Process -> Decoder EndOfLifeConfig
decodeEndOfLifeConfig processes =
    Decode.succeed EndOfLifeConfig
        |> Decode.required "enabled" (Scope.decodeDict Decode.bool)
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


decodeProductionConfig : List Process -> Decoder ProductionConfig
decodeProductionConfig processes =
    Decode.succeed ProductionConfig
        |> Decode.requiredAt [ "defaultProcesses", "elec" ] (Process.decodeFromId processes)
        |> Decode.requiredAt [ "defaultProcesses", "heat" ] (Process.decodeFromId processes)


decodeTransportConfig : List Process -> Decoder TransportConfig
decodeTransportConfig processes =
    Decode.succeed TransportConfig
        |> Decode.required "defaultDistance" Transport.decode
        |> Decode.required "modeProcesses" (Transport.decodeModeProcesses processes)


decodeUseConfig : List Process -> Decoder UseConfig
decodeUseConfig processes =
    Decode.succeed UseConfig
        |> Decode.requiredAt [ "defaultProcesses", "elec" ] (Process.decodeFromId processes)
        |> Decode.requiredAt [ "defaultProcesses", "heat" ] (Process.decodeFromId processes)


default : DataContainer db -> Result String Config
default db =
    parse db <|
        """
        {
            "production": {
                "defaultProcesses": {
                    "elec": "ed6d177e-44bb-5ba4-beec-d683dc21be9f",
                    "heat": "3561ace1-f710-50ce-a69c-9cf842e729e4"
                }
            },
            "distribution": {
                "country": "FR",
                "defaultProcess": {
                    "food2": "29118025-efa0-47bb-94e2-f5ccba31a903"
                }
            },
            "docLinks": {
                "default": {},
                "rootUrl": "https://fabrique-numerique.gitbook.io/ecobalyse/",
                "scoped": {}
            },
            "durability": {
                "enabled": {
                    "food2": false,
                    "object": true,
                    "veli": true
                }
            },
            "endOfLife": {
                "enabled": {
                    "food2": false,
                    "object": true,
                    "veli": true
                },
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
                    "plane": "326369d9-792a-5ab5-8276-c54108c80cb1"
                }
            },
            "use": {
              "defaultProcesses": {
                "elec": "931c9bb0-619a-5f75-b41b-ab8061e2ad92",
                "heat": "6cbd45fb-83ff-5852-97a7-87fffecc20f5"
              }
            }
        }
        """


getDocLink : Config -> Scope -> String -> Maybe String
getDocLink { docLinks } scope key =
    case docLinks.scoped |> Scope.dictGet scope |> Maybe.andThen (Dict.get key) of
        Just link ->
            Just <| docLinks.rootUrl ++ link

        Nothing ->
            docLinks.default |> Dict.get key |> Maybe.map ((++) docLinks.rootUrl)


parse : DataContainer db -> String -> Result String Config
parse db json =
    json
        |> Decode.decodeString (decode db)
        |> Result.mapError Decode.errorToString


scopeEnabled : Scope -> { a | enabled : Scope.Dict Bool } -> Bool
scopeEnabled scope =
    .enabled
        >> Scope.dictGet scope
        >> Maybe.withDefault False
