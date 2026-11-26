module Data.Component.Config exposing
    ( Bounds
    , Config
    , EndOfLifeConfig
    , EndOfLifeStrategies
    , EndOfLifeStrategiesConfig
    , EndOfLifeStrategy
    , durabilityBounds
    , getDocLink
    , parse
    , sectorEnabled
    , validateDurability
    )

import Data.Common.DecodeUtils as DU
import Data.Country as Country exposing (Country)
import Data.Impact as Impact exposing (Impacts)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (MaterialDict)
import Data.Sector as Sector exposing (Sector)
import Data.Split as Split exposing (Split)
import Data.Transport as Transport exposing (Transport)
import Data.Unit as Unit
import Data.Uuid as Uuid exposing (Uuid)
import Data.Validation as Validation
import Dict exposing (Dict)
import Dict.Any as AnyDict
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode


type alias Config =
    { defaultExamples : Sector.Dict Uuid
    , distribution : DistributionConfig
    , docLinks : DocLinksConfig
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
    , defaultProcess : Sector.Dict (Maybe Process)
    }


type alias DocLinksConfig =
    { default : Dict String String
    , sectored : Sector.Dict (Dict String String)
    }


type alias Bounds =
    { min : Unit.Ratio
    , max : Unit.Ratio
    }


type alias DurabilityBoundsConfig =
    { default : Bounds
    , sectored : Sector.Dict Bounds
    }


type alias DurabilityConfig =
    { bounds : DurabilityBoundsConfig
    , enabled : Sector.Dict Bool
    }


type alias EndOfLifeConfig =
    { enabled : Sector.Dict Bool
    , sectorCollectionRates : Sector.Dict Split
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
        |> DU.strictOptionalWithDefault "defaultExamples" (Sector.decodeDict Uuid.decoder) (AnyDict.empty Sector.toString)
        |> Decode.required "distribution" (decodeDistributionConfig processes countries)
        |> Decode.required "docLinks" decodeDocLinksConfig
        |> Decode.required "durability" decodeDurabilityConfig
        |> Decode.required "endOfLife" (decodeEndOfLifeConfig processes)
        |> Decode.required "production" (decodeProductionConfig processes)
        |> Decode.required "transports" (decodeTransportConfig processes)
        |> Decode.required "use" (decodeUseConfig processes)


decodeDistributionConfig : List Process -> List Country -> Decoder DistributionConfig
decodeDistributionConfig processes countries =
    Decode.succeed DistributionConfig
        |> Decode.required "country" (Country.decodeFromCode countries)
        |> Decode.required "defaultProcess" (decodeSectoredMaybeProcess processes)


decodeDocLinksConfig : Decoder DocLinksConfig
decodeDocLinksConfig =
    Decode.succeed DocLinksConfig
        |> Decode.required "default" (Decode.dict Decode.string)
        |> Decode.required "sectored" (Sector.decodeDict (Decode.dict Decode.string))


decodeDurabilityBounds : Decoder Bounds
decodeDurabilityBounds =
    Decode.succeed Bounds
        |> Decode.required "min" Unit.decodeRatio
        |> Decode.required "max" Unit.decodeRatio
        |> Decode.andThen validateDurabilityBounds


decodeDurabilityBoundsConfig : Decoder DurabilityBoundsConfig
decodeDurabilityBoundsConfig =
    Decode.succeed DurabilityBoundsConfig
        |> Decode.required "default" decodeDurabilityBounds
        |> Decode.required "sectored" (Sector.decodeDict decodeDurabilityBounds)


decodeDurabilityConfig : Decoder DurabilityConfig
decodeDurabilityConfig =
    Decode.succeed DurabilityConfig
        |> Decode.required "bounds" decodeDurabilityBoundsConfig
        |> Decode.required "enabled" (Sector.decodeDict Decode.bool)


decodeEndOfLifeConfig : List Process -> Decoder EndOfLifeConfig
decodeEndOfLifeConfig processes =
    Decode.succeed EndOfLifeConfig
        |> Decode.required "enabled" (Sector.decodeDict Decode.bool)
        |> Decode.required "scopeCollectionRates" (Sector.decodeDict Split.decodePercent)
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


decodeSectoredMaybeProcess : List Process -> Decoder (Sector.Dict (Maybe Process))
decodeSectoredMaybeProcess processes =
    Sector.decodeDict (Decode.maybe (Process.decodeFromId processes))


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


durabilityBounds : Sector -> DurabilityConfig -> Bounds
durabilityBounds sector { bounds } =
    bounds.sectored
        |> Sector.dictGet sector
        |> Maybe.withDefault bounds.default


getDocLink : Config -> Sector -> String -> Maybe String
getDocLink { docLinks } sector key =
    case docLinks.sectored |> Sector.dictGet sector |> Maybe.andThen (Dict.get key) of
        Just link ->
            Just link

        Nothing ->
            docLinks.default |> Dict.get key


parse : DataContainer db -> String -> Result String Config
parse db =
    Decode.decodeString (decode db)
        >> Result.mapError Decode.errorToString


sectorEnabled : Sector -> { a | enabled : Sector.Dict Bool } -> Bool
sectorEnabled sector =
    .enabled
        >> Sector.dictGet sector
        >> Maybe.withDefault False


validateDurability : Bounds -> Unit.Ratio -> Result String Unit.Ratio
validateDurability bounds =
    Validation.validateWithin "Le coefficient de durabilité"
        { max = bounds.max
        , min = bounds.min
        , toNumber = Unit.ratioToFloat
        , toString = Unit.ratioToFloat >> String.fromFloat
        }


validateDurabilityBounds : Bounds -> Decoder Bounds
validateDurabilityBounds ({ min, max } as bounds) =
    let
        minFloat =
            Unit.ratioToFloat min

        maxFloat =
            Unit.ratioToFloat max
    in
    if minFloat <= 0 then
        Decode.fail "La borne minimale de durabilité doit être strictement positive"

    else if minFloat >= maxFloat then
        Decode.fail "La borne minimale de durabilité doit être strictement inférieure à la borne maximale"

    else
        Decode.succeed bounds
