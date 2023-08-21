module Data.Textile.Material.Origin exposing
    ( Origin(..)
    , decode
    , isRecycled
    , toString
    )

import Json.Decode as Decode exposing (Decoder)


type Origin
    = Natural
    | Recycled
    | Synthetic


decode : Decoder Origin
decode =
    Decode.map fromString Decode.string


fromString : String -> Origin
fromString origin =
    case origin of
        "Naturelles" ->
            Natural

        "Recyclées" ->
            Recycled

        "Synthétiques et artificielles" ->
            Synthetic

        _ ->
            Natural


toString : Origin -> String
toString origin =
    case origin of
        Natural ->
            "Naturelles"

        Recycled ->
            "Recyclées"

        Synthetic ->
            "Synthétiques et artificielles"


isRecycled : Origin -> Bool
isRecycled origin =
    origin == Recycled
