module Data.Textile.Material.Origin exposing
    ( Origin(..)
    , decode
    , toString
    )

import Json.Decode as Decode exposing (Decoder)


type Origin
    = Natural
    | Artificial
    | Synthetic


decode : Decoder Origin
decode =
    Decode.map fromString Decode.string


fromString : String -> Origin
fromString origin =
    case origin of
        "Naturelles" ->
            Natural

        "Artificielles" ->
            Artificial

        "Synthétiques" ->
            Synthetic

        _ ->
            Natural


toString : Origin -> String
toString origin =
    case origin of
        Natural ->
            "Naturelles"

        Artificial ->
            "Artificielles"

        Synthetic ->
            "Synthétiques"
