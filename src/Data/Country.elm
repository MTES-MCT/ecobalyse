module Data.Country exposing (..)

import Data.Process as Process exposing (Process)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Result.Extra as RE


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


codes : List Country -> List Code
codes =
    List.map .code


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


findByCodes : List Code -> List Country -> Result String (List Country)
findByCodes codes_ countries =
    codes_
        |> List.map (\code -> findByCode code countries)
        |> RE.combine


decode : List Process -> Decoder Country
decode processes =
    Decode.map6 Country
        (Decode.field "code" (Decode.map Code Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "electricityProcessUuid" (Process.decodeFromUuid processes))
        (Decode.field "heatProcessUuid" (Process.decodeFromUuid processes))
        (Decode.field "dyeingWeighting" Unit.decodeRatio)
        (Decode.field "airTransportRatio" Unit.decodeRatio)


decodeList : List Process -> Decoder (List Country)
decodeList processes =
    Decode.list (decode processes)


encode : Country -> Encode.Value
encode v =
    Encode.object
        [ ( "code", v.code |> codeToString |> Encode.string )
        , ( "name", Encode.string v.name )
        , ( "electricityProcessUuid", v.electricityProcess.uuid |> Process.uuidToString |> Encode.string )
        , ( "heatProcessUuid", v.heatProcess.uuid |> Process.uuidToString |> Encode.string )
        , ( "dyeingWeighting", Unit.encodeRatio v.dyeingWeighting )
        , ( "airTransportRatio", Unit.encodeRatio v.airTransportRatio )
        ]


encodeAll : List Country -> String
encodeAll =
    Encode.list encode >> Encode.encode 0
