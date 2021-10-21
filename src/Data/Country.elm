module Data.Country exposing (..)

import Data.Process as Process
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExtra
import Json.Encode as Encode


type Country
    = Bangladesh
    | China
    | France
    | India
    | Portugal
    | Spain
    | Tunisia
    | Turkey


type Code
    = Code String


type alias Country2 =
    -- The big idea: replace static country type (eg. France) with country db ids (Code "FR")
    { code : Code
    , name : String
    , electricity : Process.Uuid -- IDEA: replace by process record
    , heat : Process.Uuid -- IDEA: replace by process record
    , dyeingWeighting : Float
    }


choices : List Country
choices =
    List.sortBy toString
        [ Bangladesh
        , China
        , France
        , India
        , Portugal
        , Spain
        , Tunisia
        , Turkey
        ]


codeToString : Code -> String
codeToString (Code string) =
    string


toString2 : Country2 -> String
toString2 =
    .code >> codeToString


decode : Decoder Country
decode =
    Decode.string
        |> Decode.andThen (fromString >> DecodeExtra.fromResult)


decode2 : Decoder Country2
decode2 =
    Decode.map5 Country2
        (Decode.field "code" (Decode.map Code Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "electricity" (Decode.map Process.Uuid Decode.string))
        (Decode.field "heat" (Decode.map Process.Uuid Decode.string))
        (Decode.field "dyeingWeighting" Decode.float)


decodeList2 : Decoder (List Country2)
decodeList2 =
    Decode.list decode2


encode : Country -> Encode.Value
encode country =
    Encode.string (toString country)


encode2 : Country2 -> Encode.Value
encode2 v =
    Encode.object
        [ ( "code", v.code |> codeToString |> Encode.string )
        , ( "name", Encode.string v.name )
        , ( "electricity", v.electricity |> Process.uuidToString |> Encode.string )
        , ( "heat", v.heat |> Process.uuidToString |> Encode.string )
        , ( "dyeingWeighting", Encode.float v.dyeingWeighting )
        ]


encodeAll2 : List Country2 -> String
encodeAll2 =
    Encode.list encode2 >> Encode.encode 0


fromString : String -> Result String Country
fromString country =
    case country of
        "Bangladesh" ->
            Ok Bangladesh

        "Chine" ->
            Ok China

        "France" ->
            Ok France

        "Inde" ->
            Ok India

        "Espagne" ->
            Ok Spain

        "Portugal" ->
            Ok Portugal

        "Tunisie" ->
            Ok Tunisia

        "Turquie" ->
            Ok Turkey

        _ ->
            Err <| "Pays invalide " ++ country


toString : Country -> String
toString country =
    case country of
        Bangladesh ->
            "Bangladesh"

        China ->
            "Chine"

        France ->
            "France"

        India ->
            "Inde"

        Portugal ->
            "Portugal"

        Spain ->
            "Espagne"

        Tunisia ->
            "Tunisie"

        Turkey ->
            "Turquie"


codeToCountry : Code -> Result String Country
codeToCountry code =
    case code of
        Code "BD" ->
            Ok Bangladesh

        Code "CN" ->
            Ok China

        Code "ES" ->
            Ok Spain

        Code "FR" ->
            Ok France

        Code "IN" ->
            Ok India

        Code "PT" ->
            Ok Portugal

        Code "TN" ->
            Ok Tunisia

        Code "TR" ->
            Ok Turkey

        _ ->
            Err <| "Impossible de résoudre le code pays " ++ codeToString code


countryToCode : Country -> Code
countryToCode country =
    case country of
        Bangladesh ->
            Code "BD"

        China ->
            Code "CN"

        France ->
            Code "FR"

        India ->
            Code "IN"

        Portugal ->
            Code "PT"

        Spain ->
            Code "ES"

        Tunisia ->
            Code "TN"

        Turkey ->
            Code "TR"
