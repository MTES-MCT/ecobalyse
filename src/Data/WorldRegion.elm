module Data.WorldRegion exposing
    ( WorldRegion(..)
    , decode
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type WorldRegion
    = Africa
    | Asia
    | Europe
    | MiddleEast
    | NorthAmerica
    | Oceania
    | SouthAmerica


decode : Decoder WorldRegion
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


fromString : String -> Result String WorldRegion
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
            Err <| "Région géographique inconnue : " ++ string
