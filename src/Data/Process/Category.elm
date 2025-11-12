module Data.Process.Category exposing
    ( Category(..)
    , Material(..)
    , MaterialDict
    , decodeList
    , decodeMaterialDict
    , encode
    , materialTypeToLabel
    , materialTypeToString
    , toLabel
    )

import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type Category
    = EndOfLife
    | Energy
    | Ingredient
    | Material
    | MaterialType Material
    | Packaging
    | TextileMaterial
    | Transform
    | Transport
    | Use
    | WasteTreatment


type Material
    = Metal
    | OrganicFibers
    | OtherMaterial
    | Plastic
    | SyntheticFibers
    | Upholstery
    | Wood


{-| A dict where keys are typed as `Material`
-}
type alias MaterialDict a =
    AnyDict String Material a


decodeMaterialDict : Decoder a -> Decoder (MaterialDict a)
decodeMaterialDict =
    AnyDict.decode_ (\key _ -> materialTypeFromString key) materialTypeToString


decodeList : Decoder (List Category)
decodeList =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)
        |> Decode.list


encode : Category -> Encode.Value
encode =
    toString >> Encode.string


fromString : String -> Result String Category
fromString string =
    case string of
        "end-of-life" ->
            Ok EndOfLife

        "energy" ->
            Ok Energy

        "ingredient" ->
            Ok Ingredient

        "material" ->
            Ok Material

        "packaging" ->
            Ok Packaging

        "textile_material" ->
            Ok TextileMaterial

        "transformation" ->
            Ok Transform

        "transport" ->
            Ok Transport

        "use" ->
            Ok Use

        "waste treatment" ->
            Ok WasteTreatment

        _ ->
            if String.startsWith "material_type:" string then
                string
                    |> String.dropLeft 14
                    |> materialTypeFromString
                    |> Result.map MaterialType

            else
                Err <| "Catégorie de procédé invalide: " ++ string


materialTypeFromString : String -> Result String Material
materialTypeFromString string =
    case string of
        "metal" ->
            Ok Metal

        "organic_fibers" ->
            Ok OrganicFibers

        "plastic" ->
            Ok Plastic

        "synthetic_fibers" ->
            Ok SyntheticFibers

        "upholstery" ->
            Ok Upholstery

        "wood" ->
            Ok Wood

        "other" ->
            Ok OtherMaterial

        _ ->
            Err <| "Type de matière non supporté: " ++ string


materialTypeToLabel : Material -> String
materialTypeToLabel material =
    case material of
        Metal ->
            "Métal"

        OrganicFibers ->
            "Fibres organiques"

        OtherMaterial ->
            "Autre type de matière"

        Plastic ->
            "Plastique"

        SyntheticFibers ->
            "Fibres synthétiques"

        Upholstery ->
            "Mousses et rembourrés"

        Wood ->
            "Bois"


materialTypeToString : Material -> String
materialTypeToString material =
    case material of
        Metal ->
            "metal"

        OrganicFibers ->
            "organic_fibers"

        OtherMaterial ->
            "other"

        Plastic ->
            "plastic"

        SyntheticFibers ->
            "synthetic_fibers"

        Upholstery ->
            "upholstery"

        Wood ->
            "wood"


toString : Category -> String
toString category =
    case category of
        EndOfLife ->
            "end-of-life"

        Energy ->
            "energy"

        Ingredient ->
            "ingredient"

        Material ->
            "material"

        MaterialType str ->
            "material_type:" ++ materialTypeToString str

        Packaging ->
            "packaging"

        TextileMaterial ->
            "textile_material"

        Transform ->
            "transformation"

        Transport ->
            "transport"

        Use ->
            "use"

        WasteTreatment ->
            "waste treatment"


toLabel : Category -> String
toLabel category =
    case category of
        EndOfLife ->
            "Fin de vie"

        Energy ->
            "Énergie"

        Ingredient ->
            "Ingrédient"

        Material ->
            "Matériau"

        MaterialType str ->
            "Type de matériau:" ++ materialTypeToLabel str

        Packaging ->
            "Emballage"

        TextileMaterial ->
            "Matériau textile"

        Transform ->
            "Transformation"

        Transport ->
            "Transport"

        Use ->
            "Utilisation"

        WasteTreatment ->
            "Traitement des déchets"
