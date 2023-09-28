module Data.Textile.Material.Origin exposing
    ( Origin(..)
    , decode
    , threadProcess
    , toMicrofibersComplement
    , toString
    )

import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Origin
    = ArtificialFromInorganic
    | ArtificialFromOrganic
    | NaturalFromAnimal
    | NaturalFromVegetal
    | Synthetic


decode : Decoder Origin
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


fromString : String -> Result String Origin
fromString origin =
    case origin of
        "Artificielles d'origine inorganique" ->
            Ok ArtificialFromInorganic

        "Artificielles d'origine organique" ->
            Ok ArtificialFromOrganic

        "Naturelles d'origine animale" ->
            Ok NaturalFromAnimal

        "Naturelles d'origine végétale" ->
            Ok NaturalFromVegetal

        "Synthétiques" ->
            Ok Synthetic

        _ ->
            Err <| "Origine inconnue: " ++ origin


toMicrofibersComplement : Origin -> Unit.Impact
toMicrofibersComplement origin =
    -- Note: a malus expressed as a negative µPts/kg impact
    case origin of
        ArtificialFromInorganic ->
            Unit.impact -875

        ArtificialFromOrganic ->
            Unit.impact -425

        NaturalFromAnimal ->
            Unit.impact -750

        NaturalFromVegetal ->
            Unit.impact -550

        Synthetic ->
            Unit.impact -875


toString : Origin -> String
toString origin =
    case origin of
        ArtificialFromInorganic ->
            "Artificielles d'origine inorganique"

        ArtificialFromOrganic ->
            "Artificielles d'origine organique"

        NaturalFromAnimal ->
            "Naturelles d'origine animale"

        NaturalFromVegetal ->
            "Naturelles d'origine végétale"

        Synthetic ->
            "Synthétiques"


threadProcess : Origin -> String
threadProcess origin =
    case origin of
        Synthetic ->
            "Filage"

        _ ->
            "Filature"
