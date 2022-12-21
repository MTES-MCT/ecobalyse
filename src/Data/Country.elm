module Data.Country exposing
    ( Code(..)
    , Country
    , codeFromString
    , codeToString
    , decodeCode
    , decodeList
    , encode
    , encodeCode
    , findByCode
    )

import Data.Scope as Scope exposing (Scope)
import Data.Textile.Process as Process exposing (Process)
import Data.Unit as Unit
import Data.Zone as Zone exposing (Zone)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type Code
    = Code String


type alias Country =
    { code : Code
    , name : String
    , zone : Zone
    , electricityProcess : Process
    , heatProcess : Process
    , airTransportRatio : Unit.Ratio
    , scopes : List Scope
    }


codeFromString : String -> Code
codeFromString =
    Code


codeToString : Code -> String
codeToString (Code string) =
    string


findByCode : Code -> List Country -> Result String Country
findByCode code =
    List.filter (.code >> (==) code)
        >> List.head
        >> Result.fromMaybe ("Code pays invalide: " ++ codeToString code ++ ".")


decode : List Process -> Decoder Country
decode processes =
    Decode.succeed Country
        |> Pipe.required "code" decodeCode
        |> Pipe.required "name" Decode.string
        |> Pipe.required "zone" Zone.decode
        |> Pipe.required "electricityProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "heatProcessUuid" (Process.decodeFromUuid processes)
        |> Pipe.required "airTransportRatio" Unit.decodeRatio
        |> Pipe.optional "scopes" (Decode.list Scope.decode) [ Scope.Food, Scope.Textile ]


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
        , ( "airTransportRatio", Unit.encodeRatio v.airTransportRatio )
        , ( "scopes", v.scopes |> Encode.list Scope.encode )
        ]


encodeCode : Code -> Encode.Value
encodeCode =
    codeToString >> Encode.string
