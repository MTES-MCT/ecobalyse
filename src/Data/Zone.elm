module Data.Zone exposing
    ( Zone(..)
    , decode
    , toLabel
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Zone
    = Africa
    | Asia
    | Europe
    | MiddleEast
    | NorthAmerica
    | Oceania
    | SouthAmerica


decode : Decoder Zone
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


fromString : String -> Result String Zone
fromString string =
    case string of
        "Africa" ->
            Ok Africa

        "Asia" ->
            Ok Asia

        "Europe" ->
            Ok Europe

        "Middle_East" ->
            Ok MiddleEast

        "North_America" ->
            Ok NorthAmerica

        "Oceania" ->
            Ok Oceania

        "South_America" ->
            Ok SouthAmerica

        _ ->
            Err <| "Zone géographique inconnue : " ++ string


toLabel : Zone -> String
toLabel zone =
    case zone of
        Africa ->
            "Afrique"

        Asia ->
            "Asie"

        Europe ->
            "Europe"

        MiddleEast ->
            "Moyen-Orient"

        NorthAmerica ->
            "Amérique du Nord"

        Oceania ->
            "Océanie"

        SouthAmerica ->
            "Amérique du Sud"
