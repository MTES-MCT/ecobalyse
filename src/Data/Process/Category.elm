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
    = Distribution
    | EndOfLife
    | Energy
    | Ingredient
    | Material
    | MaterialType Material
    | Packaging
    | PackagingType PackagingType
    | TextileMaterial
    | Transform
    | Transport
    | Use
    | WasteTreatment


type Material
    = Aluminium
    | BatteryCell
    | Composites
    | Containerboard
    | Copper
    | FerrousMetal
    | Glass
    | HDPE
    | LDPE
    | Metal -- obsolete materials
    | OrganicFibers
    | OtherMaterial -- obsolete materials
    | PET
    | PP
    | PWB
    | Plastic -- obsolete materials
    | PurFoam
    | RigidPlastics
    | Rubber
    | SyntheticFibers
    | Upholstery -- obsolete materials
    | Wood


type PackagingType
    = Bag
    | Bottle
    | Box
    | Case
    | Flask
    | Jar
    | OtherPackaging
    | Pack
    | Sheet
    | Tray


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
        "distribution" ->
            Ok Distribution

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

            else if String.startsWith "packaging_type:" string then
                string
                    |> String.dropLeft 15
                    |> packagingTypeFromString
                    |> Result.map PackagingType

            else
                Err <| "Catégorie de procédé invalide: " ++ string


materialTypeFromString : String -> Result String Material
materialTypeFromString string =
    case string of
        "aluminium" ->
            Ok Aluminium

        "battery_cell" ->
            Ok BatteryCell

        "composites" ->
            Ok Composites

        "containerboard" ->
            Ok Containerboard

        "copper" ->
            Ok Copper

        "ferrous_metals" ->
            Ok FerrousMetal

        "glass" ->
            Ok Glass

        "hdpe" ->
            Ok HDPE

        "ldpe" ->
            Ok LDPE

        "organic_fibers" ->
            Ok OrganicFibers

        "pet" ->
            Ok PET

        "pp" ->
            Ok PP

        "pur_foam" ->
            Ok PurFoam

        "pwb" ->
            Ok PWB

        "rigid_plastics" ->
            Ok RigidPlastics

        "rubber" ->
            Ok Rubber

        "synthetic_fibers" ->
            Ok SyntheticFibers

        "wood" ->
            Ok Wood

        -- obsolete materials
        "metal" ->
            Ok Metal

        -- obsolete materials
        "plastic" ->
            Ok Plastic

        -- obsolete materials
        "upholstery" ->
            Ok Upholstery

        -- obsolete materials
        "other" ->
            Ok OtherMaterial

        _ ->
            Err <| "Type de matière non supporté: " ++ string


materialTypeToLabel : Material -> String
materialTypeToLabel material =
    case material of
        Aluminium ->
            "Aluminium"

        BatteryCell ->
            "Cellule de batteries"

        Composites ->
            "Composites"

        Containerboard ->
            "Carton"

        Copper ->
            "Cuivre"

        FerrousMetal ->
            "Métaux ferreux"

        Glass ->
            "Verre"

        HDPE ->
            "PEHD"

        LDPE ->
            "PEBD"

        -- obsolete materials
        Metal ->
            "Métal"

        OrganicFibers ->
            "Fibres organiques"

        -- obsolete materials
        OtherMaterial ->
            "Autre type de matière"

        PET ->
            "PET"

        PP ->
            "PP"

        PWB ->
            "Carte de circuit imprimé"

        -- obsolete materials
        Plastic ->
            "Plastique"

        PurFoam ->
            "PUR"

        RigidPlastics ->
            "Plastiques rigides"

        Rubber ->
            "Caoutchouc"

        SyntheticFibers ->
            "Fibres synthétiques"

        -- obsolete materials
        Upholstery ->
            "Mousses et rembourrés"

        Wood ->
            "Bois"


materialTypeToString : Material -> String
materialTypeToString material =
    case material of
        Aluminium ->
            "aluminium"

        BatteryCell ->
            "battery_cell"

        Composites ->
            "composites"

        Containerboard ->
            "containerboard"

        Copper ->
            "copper"

        FerrousMetal ->
            "ferrous_metals"

        Glass ->
            "glass"

        HDPE ->
            "hdpe"

        LDPE ->
            "ldpe"

        -- obsolete materials
        Metal ->
            "metal"

        OrganicFibers ->
            "organic_fibers"

        -- obsolete materials
        OtherMaterial ->
            "other"

        PET ->
            "pet"

        PP ->
            "pp"

        PWB ->
            "pwb"

        -- obsolete materials
        Plastic ->
            "plastic"

        PurFoam ->
            "pur_foam"

        RigidPlastics ->
            "rigid_plastics"

        Rubber ->
            "rubber"

        SyntheticFibers ->
            "synthetic_fibers"

        -- obsolete materials
        Upholstery ->
            "upholstery"

        Wood ->
            "wood"


packagingTypeFromString : String -> Result String PackagingType
packagingTypeFromString string =
    case string of
        "bag" ->
            Ok Bag

        "bottle" ->
            Ok Bottle

        "box" ->
            Ok Box

        "case" ->
            Ok Case

        "flask" ->
            Ok Flask

        "jar" ->
            Ok Jar

        "other" ->
            Ok OtherPackaging

        "pack" ->
            Ok Pack

        "sheet" ->
            Ok Sheet

        "tray" ->
            Ok Tray

        _ ->
            Err <| "Type d’emballage non supporté\u{202F}: " ++ string


packagingTypeToString : PackagingType -> String
packagingTypeToString packagingType =
    case packagingType of
        Bag ->
            "bag"

        Bottle ->
            "bottle"

        Box ->
            "box"

        Case ->
            "case"

        Flask ->
            "flask"

        Jar ->
            "jar"

        OtherPackaging ->
            "other"

        Pack ->
            "pack"

        Sheet ->
            "sheet"

        Tray ->
            "tray"


packagingTypeToLabel : PackagingType -> String
packagingTypeToLabel packagingType =
    case packagingType of
        Bag ->
            "Sachet"

        Bottle ->
            "Bouteille"

        Box ->
            "Boîte"

        Case ->
            "Etui"

        Flask ->
            "Flacon"

        Jar ->
            "Pot & bocal"

        OtherPackaging ->
            "Autres"

        Pack ->
            "Lot"

        Sheet ->
            "Feuille"

        Tray ->
            "Barquette"


toString : Category -> String
toString category =
    case category of
        Distribution ->
            "distribution"

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

        PackagingType packagingType ->
            "packaging_type:" ++ packagingTypeToString packagingType

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
        Distribution ->
            "Distribution"

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

        PackagingType packagingType ->
            "Type d’emballage:" ++ packagingTypeToLabel packagingType

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
