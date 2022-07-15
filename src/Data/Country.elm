module Data.Country exposing
    ( Code(..)
    , Country
    , codeCodec
    , codeFromString
    , codeToString
    , decodeCode
    , decodeList
    , encode
    , encodeCode
    , findByCode
    )

import Codec exposing (Codec)
import Data.Textile.Process as Process exposing (Process)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


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


decode : List Process -> Decoder Country
decode processes =
    Decode.map6 Country
        (Decode.field "code" decodeCode)
        (Decode.field "name" Decode.string)
        (Decode.field "electricityProcessUuid" (Process.decodeFromUuid processes))
        (Decode.field "heatProcessUuid" (Process.decodeFromUuid processes))
        (Decode.field "dyeingWeighting" Unit.decodeRatio)
        (Decode.field "airTransportRatio" Unit.decodeRatio)


decodeCode : Decoder Code
decodeCode =
    Decode.map Code Decode.string


decodeList : List Process -> Decoder (List Country)
decodeList processes =
    Decode.list (decode processes)


encode : Country -> Encode.Value
encode v =
    Encode.object
        [ ( "code", encodeCode v.code )
        , ( "name", Encode.string v.name )
        , ( "electricityProcessUuid", v.electricityProcess.uuid |> Process.uuidToString |> Encode.string )
        , ( "heatProcessUuid", v.heatProcess.uuid |> Process.uuidToString |> Encode.string )
        , ( "dyeingWeighting", Unit.encodeRatio v.dyeingWeighting )
        , ( "airTransportRatio", Unit.encodeRatio v.airTransportRatio )
        ]


encodeCode : Code -> Encode.Value
encodeCode =
    codeToString >> Encode.string
