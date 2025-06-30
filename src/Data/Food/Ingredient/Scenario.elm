module Data.Food.Ingredient.Scenario exposing (Scenario, decode, empty, toLabel)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Scenario
    = Import
    | NoScenario
    | Organic
    | Reference


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
        Import ->
            "Import"

        NoScenario ->
            "N/A"

        Organic ->
            "Biologique"

        Reference ->
            "Référence"




decode : Decoder Scenario
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


empty : Scenario
empty =
    NoScenario
