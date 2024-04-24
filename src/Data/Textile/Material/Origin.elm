module Data.Textile.Material.Origin exposing
    ( Origin(..)
    , Shares
    , decode
    , defaultShares
    , isSynthetic
    , natural
    , nonSynthetic
    , syntheticAndArtificial
    , threadProcess
    , toLabel
    , toMicrofibersComplement
    , toString
    )

import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type Origin
    = ArtificialFromInorganic
    | ArtificialFromOrganic
    | NaturalFromAnimal
    | NaturalFromVegetal
    | Synthetic


type alias Shares =
    { artificialFromInorganic : Split
    , artificialFromOrganic : Split
    , naturalFromAnimal : Split
    , naturalFromVegetal : Split
    , synthetic : Split
    }


decode : Decoder Origin
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


defaultShares : Shares
defaultShares =
    { artificialFromInorganic = Split.zero
    , artificialFromOrganic = Split.zero
    , naturalFromAnimal = Split.zero
    , naturalFromVegetal = Split.zero
    , synthetic = Split.zero
    }


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


natural : List Origin
natural =
    [ NaturalFromAnimal
    , NaturalFromVegetal
    ]


nonSynthetic : List Origin
nonSynthetic =
    [ ArtificialFromInorganic
    , ArtificialFromOrganic
    , NaturalFromAnimal
    , NaturalFromVegetal
    ]


syntheticAndArtificial : List Origin
syntheticAndArtificial =
    [ ArtificialFromInorganic
    , ArtificialFromOrganic
    , Synthetic
    ]


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
