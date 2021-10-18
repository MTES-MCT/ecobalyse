module Data.Country exposing (..)

import Data.Process as Process
import Json.Decode as Decode exposing (Decoder)
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


type Id
    = Id String


type alias Country2 =
    -- The big idea: replace static country type (eg. France) with country db ids (Id "France")
    { id : Id
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
    [ { id = Id "Bangladesh"
      , electricity = Process.Uuid "1ee6061e-8e15-4558-9338-94ad87abf932"
      , heat = Process.Uuid "2e8de6f6-0ea1-455b-adce-ea74d307d222"
      , dyeingWeighting = 1
      }
    , { id = Id "Chine"
      , electricity = Process.Uuid "8f923f3d-0bd2-4326-99e2-f984b4454226"
      , heat = Process.Uuid "2e8de6f6-0ea1-455b-adce-ea74d307d222"
      , dyeingWeighting = 1
      }
    , { id = Id "Espagne"
      , electricity = Process.Uuid "37301c44-c4cf-4214-a4ac-eee5785ccdc5"
      , heat = Process.Uuid "618440a9-f4aa-65bc-21cb-ea40eee53f3d"
      , dyeingWeighting = 0
      }
    , { id = Id "France"
      , electricity = Process.Uuid "05585055-9742-4fff-81ff-ad2e30e1b791"
      , heat = Process.Uuid "12fc43f2-a007-423b-a619-619d725793ea"
      , dyeingWeighting = 0
      }
    , { id = Id "Inde"
      , electricity = Process.Uuid "1b470f5c-6ae6-404d-bd71-8546d33dbc17"
      , heat = Process.Uuid "2e8de6f6-0ea1-455b-adce-ea74d307d222"
      , dyeingWeighting = 1
      }
    , { id = Id "Portugal"
      , electricity = Process.Uuid "a1d83202-0052-4d10-b9d2-938564be6a0b"
      , heat = Process.Uuid "59c4c64c-0916-868a-5dd6-a42c4c42222f"
      , dyeingWeighting = 0
      }
    , { id = Id "Tunisie"
      , electricity = Process.Uuid "f0eb64cd-468d-4f3c-a9a3-3b3661625955"
      , heat = Process.Uuid "2e8de6f6-0ea1-455b-adce-ea74d307d222"
      , dyeingWeighting = 1
      }
    , { id = Id "Turquie"
      , electricity = Process.Uuid "6fad8643-de3e-49dd-a48b-8e17b4175c23"
      , heat = Process.Uuid "2e8de6f6-0ea1-455b-adce-ea74d307d222"
      , dyeingWeighting = 1
      }
    ]


idToString : Id -> String
idToString (Id string) =
    string


toString2 : Country2 -> String
toString2 =
    .id >> idToString


decode : Decoder Country
decode =
    Decode.string
        |> Decode.andThen (fromString >> Decode.succeed)


decode2 : Decoder Country2
decode2 =
    Decode.map4 Country2
        (Decode.field "id" (Decode.map Id Decode.string))
        (Decode.field "electricity" (Decode.map Process.Uuid Decode.string))
        (Decode.field "heat" (Decode.map Process.Uuid Decode.string))
        (Decode.field "dyeingWeighting" Decode.float)


decodeList2 : Decoder (List Country2)
decodeList2 =
    Decode.list decode2


encode : Country -> Encode.Value
encode country =
    Encode.string (toString country)


fromString : String -> Country
fromString country =
    case country of
        "Bangladesh" ->
            Bangladesh

        "Chine" ->
            China

        "France" ->
            France

        "Inde" ->
            India

        "Espagne" ->
            Spain

        "Portugal" ->
            Portugal

        "Tunisie" ->
            Tunisia

        "Turquie" ->
            Turkey

        _ ->
            France


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
