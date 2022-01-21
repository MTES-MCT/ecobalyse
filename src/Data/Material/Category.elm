module Data.Material.Category exposing
    ( Category(..)
    , decode
    , encode
    , toString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Category
    = Natural
    | Recycled
    | Synthetic


decode : Decoder Category
decode =
    Decode.map fromString Decode.string


encode : Category -> Encode.Value
encode =
    toString >> Encode.string


fromString : String -> Category
fromString category =
    case category of
        "Naturelles" ->
            Natural

        "Recyclées" ->
            Recycled

        "Synthétiques et artificielles" ->
            Synthetic

        _ ->
            Natural


toString : Category -> String
toString category =
    case category of
        Natural ->
            "Naturelles"

        Recycled ->
            "Recyclées"

        Synthetic ->
            "Synthétiques et artificielles"
