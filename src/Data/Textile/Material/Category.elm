module Data.Textile.Material.Category exposing
    ( Category(..)
    , codec
    , toString
    )

import Codec exposing (Codec)


type Category
    = Natural
    | Recycled
    | Synthetic


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


codec : Codec Category
codec =
    Codec.string
        |> Codec.map fromString toString
