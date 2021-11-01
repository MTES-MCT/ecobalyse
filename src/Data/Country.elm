module Data.Country exposing (..)

import Data.Process as Process exposing (Process)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Result.Extra as RE


type Code
    = Code String


type alias Country =
    { code : Code
    , name : String
    , electricity : Process
    , heat : Process
    , dyeingWeighting : Float
    , airTransportRatio : Float
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
        >> Result.fromMaybe ("Pays non trouvé code=" ++ codeToString code)


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
        (Decode.field "electricity" (Process.decodeFromUuid processes))
        (Decode.field "heat" (Process.decodeFromUuid processes))
        (Decode.field "dyeingWeighting" Decode.float)
        (Decode.field "airTransportRatio" Decode.float)


decodeList : List Process -> Decoder (List Country)
decodeList processes =
    Decode.list (decode processes)


encode : Country -> Encode.Value
encode v =
    Encode.object
        [ ( "code", v.code |> codeToString |> Encode.string )
        , ( "name", Encode.string v.name )
        , ( "electricity", v.electricity.uuid |> Process.uuidToString |> Encode.string )
        , ( "heat", v.heat.uuid |> Process.uuidToString |> Encode.string )
        , ( "dyeingWeighting", Encode.float v.dyeingWeighting )
        , ( "airTransportRatio", Encode.float v.airTransportRatio )
        ]


encodeAll : List Country -> String
encodeAll =
    Encode.list encode >> Encode.encode 0
