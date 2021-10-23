module Data.Country exposing (..)

import Data.Process as Process
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Result.Extra as RE


type Code
    = Code String


type alias Country2 =
    -- The big idea: replace static country type (eg. France) with country db ids (Code "FR")
    { code : Code
    , name : String
    , electricity : Process.Uuid -- IDEA: replace by process record
    , heat : Process.Uuid -- IDEA: replace by process record
    , dyeingWeighting : Float
    , airTransportRatio : Float
    }


codes : List Country2 -> List Code
codes =
    List.map .code


codeFromString : String -> Code
codeFromString =
    Code


codeToString : Code -> String
codeToString (Code string) =
    string


findByCode : Code -> List Country2 -> Result String Country2
findByCode code =
    List.filter (.code >> (==) code)
        >> List.head
        >> Result.fromMaybe ("Pays non trouvé code=" ++ codeToString code)


findByCodes : List Code -> List Country2 -> Result String (List Country2)
findByCodes codes_ countries =
    codes_
        |> List.map (\code -> findByCode code countries)
        |> RE.combine


toString2 : Country2 -> String
toString2 =
    .code >> codeToString


decode2 : Decoder Country2
decode2 =
    Decode.map6 Country2
        (Decode.field "code" (Decode.map Code Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "electricity" (Decode.map Process.Uuid Decode.string))
        (Decode.field "heat" (Decode.map Process.Uuid Decode.string))
        (Decode.field "dyeingWeighting" Decode.float)
        (Decode.field "airTransportRatio" Decode.float)


decodeList2 : Decoder (List Country2)
decodeList2 =
    Decode.list decode2


encode2 : Country2 -> Encode.Value
encode2 v =
    Encode.object
        [ ( "code", v.code |> codeToString |> Encode.string )
        , ( "name", Encode.string v.name )
        , ( "electricity", v.electricity |> Process.uuidToString |> Encode.string )
        , ( "heat", v.heat |> Process.uuidToString |> Encode.string )
        , ( "dyeingWeighting", Encode.float v.dyeingWeighting )
        , ( "airTransportRatio", Encode.float v.airTransportRatio )
        ]


encodeAll2 : List Country2 -> String
encodeAll2 =
    Encode.list encode2 >> Encode.encode 0
