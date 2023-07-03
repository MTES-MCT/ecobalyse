module Data.Impact.Definition exposing
    ( AggregatedScoreData
    , Definition
    , Definitions
    , DefinitionsBase
    , Quality(..)
    , Source
    , Trigram(..)
    , decode
    , decodeBase
    , encodeBase
    , filter
    , foldl
    , forScope
    , get
    , init
    , isAggregate
    , map
    , toString
    , toTrigram
    , trigrams
    , update
    )

import Data.Scope as Scope exposing (Scope)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode



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
    { trigram : Trigram
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


type alias DefinitionsBase a =
    {- We use a type variable here because this type is used for both
       * impact definitions (Definition.Definition)
       * processes impacts (Data.Impacts)
    -}
    { acd : a
    , bvi : a
    , cch : a
    , ecs : a
    , etf : a
    , etfc : a
    , fru : a
    , fwe : a
    , htc : a
    , htcc : a
    , htn : a
    , htnc : a
    , ior : a
    , ldu : a
    , mru : a
    , ozd : a
    , pco : a
    , pef : a
    , pma : a
    , swe : a
    , tre : a
    , wtu : a
    }


type alias Definitions =
    DefinitionsBase Definition



---- Helpers


init : a -> DefinitionsBase a
init a =
    { acd = a
    , bvi = a
    , cch = a
    , ecs = a
    , etf = a
    , etfc = a
    , fru = a
    , fwe = a
    , htc = a
    , htcc = a
    , htn = a
    , htnc = a
    , ior = a
    , ldu = a
    , mru = a
    , ozd = a
    , pco = a
    , pef = a
    , pma = a
    , swe = a
    , tre = a
    , wtu = a
    }


update : Trigram -> (a -> a) -> DefinitionsBase a -> DefinitionsBase a
update trigram updateFunc definitions =
    case trigram of
        Acd ->
            { definitions | acd = updateFunc definitions.acd }

        Bvi ->
            { definitions | bvi = updateFunc definitions.bvi }

        Cch ->
            { definitions | cch = updateFunc definitions.cch }

        Ecs ->
            { definitions | ecs = updateFunc definitions.ecs }

        Etf ->
            { definitions | etf = updateFunc definitions.etf }

        EtfC ->
            { definitions | etfc = updateFunc definitions.etfc }

        Fru ->
            { definitions | fru = updateFunc definitions.fru }

        Fwe ->
            { definitions | fwe = updateFunc definitions.fwe }

        Htc ->
            { definitions | htc = updateFunc definitions.htc }

        HtcC ->
            { definitions | htcc = updateFunc definitions.htcc }

        Htn ->
            { definitions | htn = updateFunc definitions.htn }

        HtnC ->
            { definitions | htnc = updateFunc definitions.htnc }

        Ior ->
            { definitions | ior = updateFunc definitions.ior }

        Ldu ->
            { definitions | ldu = updateFunc definitions.ldu }

        Mru ->
            { definitions | mru = updateFunc definitions.mru }

        Ozd ->
            { definitions | ozd = updateFunc definitions.ozd }

        Pco ->
            { definitions | pco = updateFunc definitions.pco }

        Pef ->
            { definitions | pef = updateFunc definitions.pef }

        Pma ->
            { definitions | pma = updateFunc definitions.pma }

        Swe ->
            { definitions | swe = updateFunc definitions.swe }

        Tre ->
            { definitions | tre = updateFunc definitions.tre }

        Wtu ->
            { definitions | wtu = updateFunc definitions.wtu }


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


get : Trigram -> DefinitionsBase a -> a
get trigram definitions =
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


map : (Trigram -> a -> b) -> DefinitionsBase a -> DefinitionsBase b
map func definitions =
    { acd = func Acd definitions.acd
    , bvi = func Bvi definitions.bvi
    , cch = func Cch definitions.cch
    , ecs = func Ecs definitions.ecs
    , etf = func Etf definitions.etf
    , etfc = func EtfC definitions.etfc
    , fru = func Fru definitions.fru
    , fwe = func Fwe definitions.fwe
    , htc = func Htc definitions.htc
    , htcc = func HtcC definitions.htcc
    , htn = func Htn definitions.htn
    , htnc = func HtnC definitions.htnc
    , ior = func Ior definitions.ior
    , ldu = func Ldu definitions.ldu
    , mru = func Mru definitions.mru
    , ozd = func Ozd definitions.ozd
    , pco = func Pco definitions.pco
    , pef = func Pef definitions.pef
    , pma = func Pma definitions.pma
    , swe = func Swe definitions.swe
    , tre = func Tre definitions.tre
    , wtu = func Wtu definitions.wtu
    }


filter : (Trigram -> Bool) -> (a -> a) -> DefinitionsBase a -> DefinitionsBase a
filter func zero base =
    -- Use the "zero-ing" function to "filter out" the fields that don't return True
    trigrams
        |> List.foldl
            (\trigram acc ->
                if func trigram then
                    acc

                else
                    update trigram zero acc
            )
            base


foldl : (Trigram -> a -> b -> b) -> b -> DefinitionsBase a -> b
foldl func acc base =
    trigrams
        |> List.foldl
            (\trigram acc_ ->
                func trigram (get trigram base) acc_
            )
            acc


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
            Ok Acd

        "bvi" ->
            Ok Bvi

        "cch" ->
            Ok Cch

        "ecs" ->
            Ok Ecs

        "etf" ->
            Ok Etf

        "etf-c" ->
            Ok EtfC

        "fru" ->
            Ok Fru

        "fwe" ->
            Ok Fwe

        "htc" ->
            Ok Htc

        "htc-c" ->
            Ok HtcC

        "htn" ->
            Ok Htn

        "htn-c" ->
            Ok HtnC

        "ior" ->
            Ok Ior

        "ldu" ->
            Ok Ldu

        "mru" ->
            Ok Mru

        "ozd" ->
            Ok Ozd

        "pco" ->
            Ok Pco

        "pef" ->
            Ok Pef

        "pma" ->
            Ok Pma

        "swe" ->
            Ok Swe

        "tre" ->
            Ok Tre

        "wtu" ->
            Ok Wtu

        _ ->
            Err <| "Trigramme d'impact inconnu: " ++ str


forScope : Definitions -> Scope -> List Definition
forScope definitions scope =
    trigrams |> List.map (\trigram -> get trigram definitions) |> List.filter (.scopes >> List.member scope)


isAggregate : Trigram -> Bool
isAggregate trigram =
    trigram == Pef || trigram == Ecs



---- Decoders


decodeBase : (String -> Decoder a) -> Decoder (DefinitionsBase a)
decodeBase decoder =
    Decode.succeed DefinitionsBase
        |> Pipe.required "acd" (decoder "acd")
        |> Pipe.required "bvi" (decoder "bvi")
        |> Pipe.required "cch" (decoder "cch")
        |> Pipe.required "ecs" (decoder "ecs")
        |> Pipe.required "etf" (decoder "etf")
        |> Pipe.required "etf-c" (decoder "etf-c")
        |> Pipe.required "fru" (decoder "fru")
        |> Pipe.required "fwe" (decoder "fwe")
        |> Pipe.required "htc" (decoder "htc")
        |> Pipe.required "htc-c" (decoder "htc-c")
        |> Pipe.required "htn" (decoder "htn")
        |> Pipe.required "htn-c" (decoder "htn-c")
        |> Pipe.required "ior" (decoder "ior")
        |> Pipe.required "ldu" (decoder "ldu")
        |> Pipe.required "mru" (decoder "mru")
        |> Pipe.required "ozd" (decoder "ozd")
        |> Pipe.required "pco" (decoder "pco")
        |> Pipe.required "pef" (decoder "pef")
        |> Pipe.required "pma" (decoder "pma")
        |> Pipe.required "swe" (decoder "swe")
        |> Pipe.required "tre" (decoder "tre")
        |> Pipe.required "wtu" (decoder "wtu")


decode : Decoder Definitions
decode =
    decodeBase decodeDefinition


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



---- Encoders


encodeBase : Definitions -> Scope -> (a -> Encode.Value) -> DefinitionsBase a -> Encode.Value
encodeBase definitions scope encoder base =
    forScope definitions scope
        |> List.map .trigram
        |> List.map
            (\trigram ->
                ( toString trigram, encoder (get trigram base) )
            )
        |> Encode.object
