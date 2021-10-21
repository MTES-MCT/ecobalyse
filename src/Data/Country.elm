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
    , electricity : Process.Uuid
    , heat : Process.Uuid
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


choices2 : List Country2
choices2 =
    [ { code = Code "BD"
      , name = "Bangladesh"
      , electricity = Process.Uuid "1ee6061e-8e15-4558-9338-94ad87abf932"
      , heat = Process.Uuid "2e8de6f6-0ea1-455b-adce-ea74d307d222"
      , dyeingWeighting = 1
      }
    , { code = Code "CN"
      , name = "Chine"
      , electricity = Process.Uuid "8f923f3d-0bd2-4326-99e2-f984b4454226"
      , heat = Process.Uuid "2e8de6f6-0ea1-455b-adce-ea74d307d222"
      , dyeingWeighting = 1
      }
    , { code = Code "ES"
      , name = "Espagne"
      , electricity = Process.Uuid "37301c44-c4cf-4214-a4ac-eee5785ccdc5"
      , heat = Process.Uuid "618440a9-f4aa-65bc-21cb-ea40eee53f3d"
      , dyeingWeighting = 0
      }
    , { code = Code "FR"
      , name = "France"
      , electricity = Process.Uuid "05585055-9742-4fff-81ff-ad2e30e1b791"
      , heat = Process.Uuid "12fc43f2-a007-423b-a619-619d725793ea"
      , dyeingWeighting = 0
      }
    , { code = Code "IN"
      , name = "Inde"
      , electricity = Process.Uuid "1b470f5c-6ae6-404d-bd71-8546d33dbc17"
      , heat = Process.Uuid "2e8de6f6-0ea1-455b-adce-ea74d307d222"
      , dyeingWeighting = 1
      }
    , { code = Code "PT"
      , name = "Portugal"
      , electricity = Process.Uuid "a1d83202-0052-4d10-b9d2-938564be6a0b"
      , heat = Process.Uuid "59c4c64c-0916-868a-5dd6-a42c4c42222f"
      , dyeingWeighting = 0
      }
    , { code = Code "TN"
      , name = "Tunisie"
      , electricity = Process.Uuid "f0eb64cd-468d-4f3c-a9a3-3b3661625955"
      , heat = Process.Uuid "2e8de6f6-0ea1-455b-adce-ea74d307d222"
      , dyeingWeighting = 1
      }
    , { code = Code "TR"
      , name = "Turquie"
      , electricity = Process.Uuid "6fad8643-de3e-49dd-a48b-8e17b4175c23"
      , heat = Process.Uuid "2e8de6f6-0ea1-455b-adce-ea74d307d222"
      , dyeingWeighting = 1
      }
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


encodeAll2 : String
encodeAll2 =
    choices2
        |> Encode.list encode2
        |> Encode.encode 0


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



-- TODO?
-- codeToCountry : Code -> Result String Country
-- codeToCountry code ->
