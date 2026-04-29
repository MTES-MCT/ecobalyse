module Data.Food.Origin exposing
    ( Origin(..)
    , decode
    , toLabel
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Origin
    = EuropeAndMaghreb
    | France
    | FranceOutreMer
    | OutOfEuropeAndMaghreb
    | OutOfEuropeAndMaghrebByPlane


decode : Decoder Origin
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


fromString : String -> Result String Origin
fromString string =
    case string of
        "EuropeAndMaghreb" ->
            Ok EuropeAndMaghreb

        "France" ->
            Ok France

        "FranceOutreMer" ->
            Ok FranceOutreMer

        "OutOfEuropeAndMaghreb" ->
            Ok OutOfEuropeAndMaghreb

        "OutOfEuropeAndMaghrebByPlane" ->
            Ok OutOfEuropeAndMaghrebByPlane

        _ ->
            Err <| "Origine géographique inconnue : " ++ string


toLabel : Origin -> String
toLabel origin =
    case origin of
        EuropeAndMaghreb ->
            "Europe et Maghreb"

        France ->
            "France"

        FranceOutreMer ->
            "France d’outre-mer"

        OutOfEuropeAndMaghreb ->
            "Hors Europe et Maghreb"

        OutOfEuropeAndMaghrebByPlane ->
            "Hors Europe et Maghreb par avion"
