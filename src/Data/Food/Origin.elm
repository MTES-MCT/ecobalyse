module Data.Food.Origin exposing
    ( Origin(..)
    , decode
    , toLabel
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Origin
    = France
    | EuropeAndMaghreb
    | OutOfEuropeAndMaghreb
    | OutOfEuropeAndMaghrebByPlane


decode : Decoder Origin
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


fromString : String -> Result String Origin
fromString string =
    case string of
        "France" ->
            Ok France

        "EuropeAndMaghreb" ->
            Ok EuropeAndMaghreb

        "OutOfEuropeAndMaghreb" ->
            Ok OutOfEuropeAndMaghreb

        "OutOfEuropeAndMaghrebByPlane" ->
            Ok OutOfEuropeAndMaghrebByPlane

        _ ->
            Err <| "Origine géographique inconnue : " ++ string


toLabel : Origin -> String
toLabel origin =
    case origin of
        France ->
            "France"

        EuropeAndMaghreb ->
            "Europe et Maghreb"

        OutOfEuropeAndMaghreb ->
            "Hors Europe et Maghreb"

        OutOfEuropeAndMaghrebByPlane ->
            "Hors Europe et Maghreb par avion"
