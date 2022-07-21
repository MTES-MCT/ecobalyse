module Data.Country exposing
    ( Code(..)
    , Country
    , codeCodec
    , codeFromString
    , codeToString
    , codec
    , findByCode
    , listCodec
    )

import Codec exposing (Codec)
import Data.Textile.Process as Process exposing (Process)
import Data.Unit as Unit


type Code
    = Code String


type alias Country =
    { code : Code
    , name : String
    , electricityProcess : Process
    , heatProcess : Process
    , dyeingWeighting : Unit.Ratio
    , airTransportRatio : Unit.Ratio
    }


codeFromString : String -> Code
codeFromString =
    Code


codeToString : Code -> String
codeToString (Code string) =
    string


codeCodec : Codec Code
codeCodec =
    Codec.string
        |> Codec.map codeFromString codeToString


findByCode : Code -> List Country -> Result String Country
findByCode code =
    List.filter (.code >> (==) code)
        >> List.head
        >> Result.fromMaybe ("Code pays invalide: " ++ codeToString code ++ ".")


codec : List Process -> Codec Country
codec processes =
    Codec.object Country
        |> Codec.field "code" .code codeCodec
        |> Codec.field "name" .name Codec.string
        |> Codec.field "electricityProcessUuid" .electricityProcess (Process.processUuidCodec processes)
        |> Codec.field "heatProcessUuid" .heatProcess (Process.processUuidCodec processes)
        |> Codec.field "dyeingWeighting" .dyeingWeighting Unit.ratioCodec
        |> Codec.field "airTransportRatio" .airTransportRatio Unit.ratioCodec
        |> Codec.buildObject


listCodec : List Process -> Codec (List Country)
listCodec processes =
    Codec.list (codec processes)
