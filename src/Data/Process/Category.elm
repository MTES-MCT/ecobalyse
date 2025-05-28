module Data.Process.Category exposing
    ( Category(..)
    , decodeList
    , encode
    , toLabel
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode


type Category
    = EndOfLife
    | Energy
    | Ingredient
    | Material
    | MaterialType String
    | Packaging
    | TextileMaterial
    | Transform
    | Transport
    | Use
    | WasteTreatment


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
        "eol" ->
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
                Ok (MaterialType (String.dropLeft 14 string))

            else
                Err <| "Catégorie de procédé invalide: " ++ string


toString : Category -> String
toString category =
    case category of
        EndOfLife ->
            "eol"

        Energy ->
            "energy"

        Ingredient ->
            "ingredient"

        Material ->
            "material"

        MaterialType str ->
            "material_type:" ++ str

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
            "Type de matériau:" ++ str

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
