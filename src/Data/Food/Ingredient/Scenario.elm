module Data.Food.Ingredient.Scenario exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Scenario
    = Reference
    | Organic
    | Import
    | NoScenario

fromString : String -> Result String Scenario
fromString str =
    case str of
        "reference" ->
            Ok Reference

        "organic" ->
            Ok Organic

        "import" ->
            Ok Import

        "" ->
            Ok NoScenario

        _ ->
            Err <| "Scénario invalide : " ++ str

toLabel : Scenario -> String
toLabel scenario =
    case scenario of
        Reference ->
            "Référence"

        Organic ->
            "Biologique"

        Import ->
            "Import"

        NoScenario ->
            "N/A"


decode : Decoder Scenario
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


empty : Scenario
empty =
    NoScenario
