module Data.Textile.Material.Origin exposing
    ( Origin(..)
    , decode
    , threadProcess
    , toString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Origin
    = NaturalFromAnimal
    | NaturalFromVegetal
    | ArtificialFromInorganic
    | ArtificialFromOrganic
    | Synthetic


decode : Decoder Origin
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


fromString : String -> Result String Origin
fromString origin =
    case origin of
        "Naturelles d'origine animale" ->
            Ok NaturalFromAnimal

        "Naturelles d'origine végétale" ->
            Ok NaturalFromVegetal

        "Artificielles d'origine inorganique" ->
            Ok ArtificialFromInorganic

        "Artificielles d'origine organique" ->
            Ok ArtificialFromOrganic

        "Synthétiques" ->
            Ok Synthetic

        _ ->
            Err <| "Origine inconnue: " ++ origin


toString : Origin -> String
toString origin =
    case origin of
        NaturalFromAnimal ->
            "Naturelles d'origine animale"

        NaturalFromVegetal ->
            "Naturelles d'origine végétale"

        ArtificialFromInorganic ->
            "Artificielles d'origine inorganique"

        ArtificialFromOrganic ->
            "Artificielles d'origine organique"

        Synthetic ->
            "Synthétiques"


threadProcess : Origin -> String
threadProcess origin =
    case origin of
        Synthetic ->
            "Filage"

        _ ->
            "Filature"
