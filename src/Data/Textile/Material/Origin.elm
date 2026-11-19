module Data.Textile.Material.Origin exposing
    ( Origin(..)
    , decode
    , isSynthetic
    , threadProcess
    , toLabel
    , toMicrofibersComplement
    , toString
    )

import Data.Impact as Impact exposing (Impact)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Origin
    = ArtificialFromOrganic
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


isSynthetic : Origin -> Bool
isSynthetic origin =
    origin == Synthetic


toMicrofibersComplement : Origin -> Impact
toMicrofibersComplement origin =
    -- see https://fabrique-numerique.gitbook.io/ecobalyse/textile/complements-hors-acv/microfibres
    -- Notes:
    -- - the float value corresponds to Ref(f) * 1000 to ease applying the formula
    case origin of
        ArtificialFromOrganic ->
            Impact.fromFloat 330

        NaturalFromAnimal ->
            Impact.fromFloat 390

        NaturalFromVegetal ->
            Impact.fromFloat 250

        Synthetic ->
            Impact.fromFloat 820


toLabel : Origin -> String
toLabel origin =
    case origin of
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
