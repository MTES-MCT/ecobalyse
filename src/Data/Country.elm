module Data.Country exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Country
    = China
    | France
    | India
    | Spain
    | Tunisia
    | Turkey


choices : List Country
choices =
    List.sortBy toString
        [ China
        , France
        , India
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
        "Chine" ->
            China

        "France" ->
            France

        "Inde" ->
            India

        "Espagne" ->
            Spain

        "Tunisie" ->
            Tunisia

        "Turquie" ->
            Turkey

        _ ->
            France


toString : Country -> String
toString country =
    case country of
        China ->
            "Chine"

        France ->
            "France"

        India ->
            "Inde"

        Spain ->
            "Espagne"

        Tunisia ->
            "Tunisie"

        Turkey ->
            "Turquie"
