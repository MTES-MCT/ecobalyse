module Data.Country exposing (..)

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


decode : Decoder Country
decode =
    Decode.string
        |> Decode.andThen (fromString >> Decode.succeed)


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
