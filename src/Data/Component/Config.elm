module Data.Component.Config exposing
    ( Config
    , EndOfLifeConfig
    , EndOfLifeStrategies
    , EndOfLifeStrategiesConfig
    , EndOfLifeStrategy
    , decode
    , getDefaultExampleQuery
    , getDocLink
    , parse
    , scopeEnabled
    )

import Data.Common.DecodeUtils as DU
import Data.Country as Country exposing (Country)
import Data.Example as Example exposing (Example)
import Data.Impact as Impact exposing (Impacts)
import Data.Process as Process exposing (Process)
import Data.Process.Category as Category exposing (MaterialDict)
import Data.Scope as Scope exposing (GenericScope, Scope)
import Data.Split as Split exposing (Split)
import Data.Transport as Transport exposing (Transport)
import Data.Uuid as Uuid exposing (Uuid)
import Dict exposing (Dict)
import Dict.Any as AnyDict
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode


type alias Config =
    { defaultExamples : Scope.Dict Uuid
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
    , defaultProcess : Scope.Dict (Maybe Process)
    }


type alias DocLinksConfig =
    { default : Dict String String
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
        |> Decode.required "defaultExamples" decodeDefaultExamples
        |> Decode.required "distribution" (decodeDistributionConfig processes countries)
        |> Decode.required "docLinks" decodeDocLinksConfig
        |> Decode.required "durability" decodeDurabilityConfig
        |> Decode.required "endOfLife" (decodeEndOfLifeConfig processes)
        |> Decode.required "production" (decodeProductionConfig processes)
        |> Decode.required "transports" (decodeTransportConfig processes)
        |> Decode.required "use" (decodeUseConfig processes)


decodeDefaultExamples : Decoder (Scope.Dict Uuid)
decodeDefaultExamples =
    Decode.dict Uuid.decoder
        |> Decode.andThen validateDefaultExamples


decodeDistributionConfig : List Process -> List Country -> Decoder DistributionConfig
decodeDistributionConfig processes countries =
    Decode.succeed DistributionConfig
        |> Decode.required "country" (Country.decodeFromCode countries)
        |> Decode.required "defaultProcess" (decodeScopedMaybeProcess processes)


decodeDocLinksConfig : Decoder DocLinksConfig
decodeDocLinksConfig =
    Decode.succeed DocLinksConfig
        |> Decode.required "default" (Decode.dict Decode.string)
        |> Decode.required "scoped" (Scope.decodeDict (Decode.dict Decode.string))


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


decodeScopedMaybeProcess : List Process -> Decoder (Scope.Dict (Maybe Process))
decodeScopedMaybeProcess processes =
    Scope.decodeDict (Decode.maybe (Process.decodeFromId processes))


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


{-| Resolves the default example query for a generic scope from config `defaultExamples` UUIDs.
-}
getDefaultExampleQuery : List (Example query) -> GenericScope -> Config -> Result String query
getDefaultExampleQuery examples genericScope config =
    let
        scope =
            Scope.Generic genericScope
    in
    config.defaultExamples
        |> Scope.dictGet scope
        |> Result.fromMaybe ("Exemple par défaut introuvable pour " ++ Scope.toString scope)
        |> Result.andThen
            (\uuid ->
                examples
                    |> Example.findByUuid uuid
                    |> Result.andThen
                        (\example ->
                            if example.scope == scope then
                                Ok example.query

                            else
                                Err <|
                                    "Exemple par défaut "
                                        ++ Uuid.toString uuid
                                        ++ " n'appartient pas au scope "
                                        ++ Scope.toString scope
                        )
            )


getDocLink : Config -> Scope -> String -> Maybe String
getDocLink { docLinks } scope key =
    case docLinks.scoped |> Scope.dictGet scope |> Maybe.andThen (Dict.get key) of
        Just link ->
            Just link

        Nothing ->
            docLinks.default |> Dict.get key


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


validateDefaultExamples : Dict String Uuid -> Decoder (Scope.Dict Uuid)
validateDefaultExamples rawDict =
    let
        invalidKeys =
            Dict.keys rawDict
                |> List.filterMap
                    (\key ->
                        case Scope.fromStringGeneric key of
                            Err _ ->
                                Just key

                            Ok _ ->
                                Nothing
                    )

        missingScopes =
            Scope.genericScopes
                |> List.filter
                    (\genericScope ->
                        case Dict.get (Scope.toStringGeneric genericScope) rawDict of
                            Just _ ->
                                False

                            Nothing ->
                                True
                    )
                |> List.map Scope.toStringGeneric

        errors =
            List.map (\key -> "defaultExamples\u{00A0}: scope invalide `" ++ key ++ "`") invalidKeys
                ++ List.map (\scope -> "defaultExamples\u{00A0}: scope manquant `" ++ scope ++ "`") missingScopes
    in
    if not <| List.isEmpty errors then
        Decode.fail <| String.join "\n" errors

    else
        rawDict
            |> Dict.foldl
                (\key uuid acc ->
                    case Scope.fromStringGeneric key of
                        Err _ ->
                            acc

                        Ok genericScope ->
                            AnyDict.insert (Scope.Generic genericScope) uuid acc
                )
                (AnyDict.empty Scope.toString)
            |> Decode.succeed
