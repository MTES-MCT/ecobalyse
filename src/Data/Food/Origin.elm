module Data.Food.Origin exposing
    ( Origin(..)
    , decode
    , toCountryCode
    )

import Data.Country as Country
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Origin
    = EuropeAndMaghreb
    | France
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

        "OutOfEuropeAndMaghreb" ->
            Ok OutOfEuropeAndMaghreb

        "OutOfEuropeAndMaghrebByPlane" ->
            Ok OutOfEuropeAndMaghrebByPlane

        _ ->
            Err <| "Origine géographique inconnue : " ++ string


toCountryCode : Origin -> Country.Code
toCountryCode origin =
    case origin of
        EuropeAndMaghreb ->
            -- @FIXME: use real value
            Country.codeFromString "FR"

        France ->
            Country.codeFromString "FR"

        OutOfEuropeAndMaghreb ->
            -- @FIXME: use real value
            Country.codeFromString "FR"

        OutOfEuropeAndMaghrebByPlane ->
            -- @FIXME: use real value and fix the plane problem
            Country.codeFromString "FR"
