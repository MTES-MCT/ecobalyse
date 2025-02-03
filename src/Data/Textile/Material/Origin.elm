module Data.Textile.Material.Origin exposing
    ( Origin(..)
    , decode
    , getPreTreatments
    , isSynthetic
    , threadProcess
    , toLabel
    , toMicrofibersComplement
    , toString
    )

import Data.Process exposing (Process)
import Data.Textile.WellKnown exposing (WellKnown)
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


isSynthetic : Origin -> Bool
isSynthetic origin =
    origin == Synthetic


getPreTreatments : WellKnown -> Origin -> List Process
getPreTreatments { bleaching, degreasing, washingSyntheticFibers } origin =
    case origin of
        NaturalFromAnimal ->
            [ bleaching, degreasing ]

        NaturalFromVegetal ->
            [ bleaching, degreasing ]

        Synthetic ->
            [ washingSyntheticFibers ]

        _ ->
            []


toMicrofibersComplement : Origin -> Unit.Impact
toMicrofibersComplement origin =
    -- see https://fabrique-numerique.gitbook.io/ecobalyse/textile/limites-methodologiques/old/microfibres#calcul-du-complement-microfibres
    -- Notes:
    -- - this is a malus expressed as a negative Pts/kg impact
    -- - the float value corresponds to Ref(f) * 1000 to ease applying the formula
    case origin of
        ArtificialFromInorganic ->
            Unit.impact -820

        ArtificialFromOrganic ->
            Unit.impact -330

        NaturalFromAnimal ->
            Unit.impact -390

        NaturalFromVegetal ->
            Unit.impact -250

        Synthetic ->
            Unit.impact -820


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
