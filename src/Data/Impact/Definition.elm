module Data.Impact.Definition exposing (AggregatedScoreData, Definition, Definitions, Quality(..), Source, Trigram(..), decode, forScope, get, isAggregate, toString, toTrigram, trigrams)

import Data.Scope as Scope exposing (Scope)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe



---- Types


type alias Source =
    { label : String, url : String }


type Quality
    = AverageQuality
    | BadQuality
    | GoodQuality
    | NotFinished
    | UnknownQuality


type alias AggregatedScoreData =
    { color : String
    , normalization : Unit.Impact
    , weighting : Unit.Ratio
    }


type Trigram
    = Acd
    | Bvi
    | Cch
    | Ecs
    | Etf
    | EtfC
    | Fru
    | Fwe
    | Htc
    | HtcC
    | Htn
    | HtnC
    | Ior
    | Ldu
    | Mru
    | Ozd
    | Pco
    | Pef
    | Pma
    | Swe
    | Tre
    | Wtu


type alias Definition =
    { trigramString : String
    , trigram : Trigram
    , source : Source
    , label : String
    , description : String
    , unit : String
    , decimals : Int
    , quality : Quality
    , pefData : Maybe AggregatedScoreData
    , ecoscoreData : Maybe AggregatedScoreData
    , scopes : List Scope
    }


type alias Definitions =
    { acd : Definition
    , bvi : Definition
    , cch : Definition
    , ecs : Definition
    , etf : Definition
    , etfc : Definition
    , fru : Definition
    , fwe : Definition
    , htc : Definition
    , htcc : Definition
    , htn : Definition
    , htnc : Definition
    , ior : Definition
    , ldu : Definition
    , mru : Definition
    , ozd : Definition
    , pco : Definition
    , pef : Definition
    , pma : Definition
    , swe : Definition
    , tre : Definition
    , wtu : Definition
    }



---- Helpers


trigrams : List Trigram
trigrams =
    [ Acd
    , Bvi
    , Cch
    , Ecs
    , Etf
    , EtfC
    , Fru
    , Fwe
    , Htc
    , HtcC
    , Htn
    , HtnC
    , Ior
    , Ldu
    , Mru
    , Ozd
    , Pco
    , Pef
    , Pma
    , Swe
    , Tre
    , Wtu
    ]


get : Definitions -> Trigram -> Definition
get definitions trigram =
    case trigram of
        Acd ->
            definitions.acd

        Bvi ->
            definitions.bvi

        Cch ->
            definitions.cch

        Ecs ->
            definitions.ecs

        Etf ->
            definitions.etf

        EtfC ->
            definitions.etfc

        Fru ->
            definitions.fru

        Fwe ->
            definitions.fwe

        Htc ->
            definitions.htc

        HtcC ->
            definitions.htcc

        Htn ->
            definitions.htn

        HtnC ->
            definitions.htnc

        Ior ->
            definitions.ior

        Ldu ->
            definitions.ldu

        Mru ->
            definitions.mru

        Ozd ->
            definitions.ozd

        Pco ->
            definitions.pco

        Pef ->
            definitions.pef

        Pma ->
            definitions.pma

        Swe ->
            definitions.swe

        Tre ->
            definitions.tre

        Wtu ->
            definitions.wtu


toString : Trigram -> String
toString trigram =
    case trigram of
        Acd ->
            "acd"

        Bvi ->
            "bvi"

        Cch ->
            "cch"

        Ecs ->
            "ecs"

        Etf ->
            "etf"

        EtfC ->
            "etf-c"

        Fru ->
            "fru"

        Fwe ->
            "fwe"

        Htc ->
            "htc"

        HtcC ->
            "htc-c"

        Htn ->
            "htn"

        HtnC ->
            "htn-c"

        Ior ->
            "ior"

        Ldu ->
            "ldu"

        Mru ->
            "mru"

        Ozd ->
            "ozd"

        Pco ->
            "pco"

        Pef ->
            "pef"

        Pma ->
            "pma"

        Swe ->
            "swe"

        Tre ->
            "tre"

        Wtu ->
            "wtu"


toTrigram : String -> Result String Trigram
toTrigram str =
    case str of
        "acd" ->
            Result.Ok Acd

        "bvi" ->
            Result.Ok Bvi

        "cch" ->
            Result.Ok Cch

        "ecs" ->
            Result.Ok Ecs

        "etf" ->
            Result.Ok Etf

        "etf-c" ->
            Result.Ok EtfC

        "fru" ->
            Result.Ok Fru

        "fwe" ->
            Result.Ok Fwe

        "htc" ->
            Result.Ok Htc

        "htc-c" ->
            Result.Ok HtcC

        "htn" ->
            Result.Ok Htn

        "htn-c" ->
            Result.Ok HtnC

        "ior" ->
            Result.Ok Ior

        "ldu" ->
            Result.Ok Ldu

        "mru" ->
            Result.Ok Mru

        "ozd" ->
            Result.Ok Ozd

        "pco" ->
            Result.Ok Pco

        "pef" ->
            Result.Ok Pef

        "pma" ->
            Result.Ok Pma

        "swe" ->
            Result.Ok Swe

        "tre" ->
            Result.Ok Tre

        "wtu" ->
            Result.Ok Wtu

        _ ->
            Result.Err <| "Trigramme d'impact inconnu: " ++ str


forScope : Definitions -> Scope -> List Definition
forScope definitions scope =
    trigrams |> List.map (get definitions) |> List.filter (.scopes >> List.member scope)


isAggregate : Trigram -> Bool
isAggregate trigram =
    trigram == Pef || trigram == Ecs



---- Decoders


decode : Decoder Definitions
decode =
    Decode.succeed Definitions
        |> Pipe.required "acd" (decodeDefinition "acd")
        |> Pipe.required "bvi" (decodeDefinition "bvi")
        |> Pipe.required "cch" (decodeDefinition "cch")
        |> Pipe.required "ecs" (decodeDefinition "ecs")
        |> Pipe.required "etf" (decodeDefinition "etf")
        |> Pipe.required "etf-c" (decodeDefinition "etf-c")
        |> Pipe.required "fru" (decodeDefinition "fru")
        |> Pipe.required "fwe" (decodeDefinition "fwe")
        |> Pipe.required "htc" (decodeDefinition "htc")
        |> Pipe.required "htc-c" (decodeDefinition "htc-c")
        |> Pipe.required "htn" (decodeDefinition "htn")
        |> Pipe.required "htn-c" (decodeDefinition "htn-c")
        |> Pipe.required "ior" (decodeDefinition "ior")
        |> Pipe.required "ldu" (decodeDefinition "ldu")
        |> Pipe.required "mru" (decodeDefinition "mru")
        |> Pipe.required "ozd" (decodeDefinition "ozd")
        |> Pipe.required "pco" (decodeDefinition "pco")
        |> Pipe.required "pef" (decodeDefinition "pef")
        |> Pipe.required "pma" (decodeDefinition "pma")
        |> Pipe.required "swe" (decodeDefinition "swe")
        |> Pipe.required "tre" (decodeDefinition "tre")
        |> Pipe.required "wtu" (decodeDefinition "wtu")


decodeSource : Decoder Source
decodeSource =
    Decode.map2 Source
        (Decode.field "label" Decode.string)
        (Decode.field "url" Decode.string)


decodeAggregatedScoreData : Decoder AggregatedScoreData
decodeAggregatedScoreData =
    Decode.map3 AggregatedScoreData
        (Decode.field "color" Decode.string)
        (Decode.field "normalization" Unit.decodeImpact)
        (Decode.field "weighting" (Unit.decodeRatio { percentage = True }))


decodeQuality : Decoder Quality
decodeQuality =
    Decode.maybe Decode.int
        |> Decode.andThen
            (\maybeInt ->
                case maybeInt of
                    Just 0 ->
                        Decode.succeed NotFinished

                    Just 1 ->
                        Decode.succeed GoodQuality

                    Just 2 ->
                        Decode.succeed AverageQuality

                    Just 3 ->
                        Decode.succeed BadQuality

                    _ ->
                        Decode.succeed UnknownQuality
            )


decodeDefinition : String -> Decoder Definition
decodeDefinition trigram =
    Decode.succeed Definition
        |> Pipe.hardcoded trigram
        |> Pipe.custom (toTrigram trigram |> DE.fromResult)
        |> Pipe.required "source" decodeSource
        |> Pipe.required "label_fr" Decode.string
        |> Pipe.required "description_fr" Decode.string
        |> Pipe.required "short_unit" Decode.string
        |> Pipe.required "decimals" Decode.int
        |> Pipe.required "quality" decodeQuality
        |> Pipe.required "pef" (Decode.maybe decodeAggregatedScoreData)
        |> Pipe.required "ecoscore" (Decode.maybe decodeAggregatedScoreData)
        |> Pipe.required "scopes" (Decode.list Scope.decode)
