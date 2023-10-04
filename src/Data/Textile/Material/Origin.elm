module Data.Textile.Material.Origin exposing
    ( Origin(..)
    , decode
    , threadProcess
    , toLabel
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
        "ArtificialFromInorganic" ->
            Ok ArtificialFromInorganic

        "ArtificialFromOrganic" ->
            Ok ArtificialFromOrganic

        "NaturalFromAnimal" ->
            Ok NaturalFromAnimal

        "NaturalFromVegetal" ->
            Ok NaturalFromVegetal

        "Synthetic" ->
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


toLabel : Origin -> String
toLabel origin =
    case origin of
        ArtificialFromInorganic ->
            "Matière artificielle d'origine inorganique"

        ArtificialFromOrganic ->
            "Matière artificielle d'origine organique"

        NaturalFromAnimal ->
            "Matière naturelle d'origine animale"

        NaturalFromVegetal ->
            "Matière naturelle d'origine végétale"

        Synthetic ->
            "Matière synthétique"


toString : Origin -> String
toString origin =
    case origin of
        ArtificialFromInorganic ->
            "ArtificialFromInorganic"

        ArtificialFromOrganic ->
            "ArtificialFromOrganic"

        NaturalFromAnimal ->
            "NaturalFromAnimal"

        NaturalFromVegetal ->
            "NaturalFromVegetal"

        Synthetic ->
            "Synthetic"


threadProcess : Origin -> String
threadProcess origin =
    case origin of
        Synthetic ->
            "Filage"

        _ ->
            "Filature"
