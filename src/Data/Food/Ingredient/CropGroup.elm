module Data.Food.Ingredient.CropGroup exposing (CropGroup, decode, empty, toLabel)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type CropGroup
    = OtherCereals
    | OtherIndustrialCrops
    | OtherOilseeds
    | SoftWheat
    | Rapeseed
    | Miscellaneous
    | Nuts
    | VegetablesAndFlowers
    | GrainLegumes
    | CornGrainAndSilage
    | NoCropGroup
    | OliveTrees
    | Barley
    | FiberPlants
    | PermanentGrasslands
    | TemporaryGrasslands
    | ProteinCrops
    | Rice
    | Sunflower
    | Orchards
    | Vineyards


fromString : String -> Result String CropGroup
fromString str =
    case str of
        "AUTRES CEREALES" ->
            Ok OtherCereals

        "AUTRES CULTURES INDUSTRIELLES" ->
            Ok OtherIndustrialCrops

        "AUTRES OLEAGINEUX" ->
            Ok OtherOilseeds

        "BLE TENDRE" ->
            Ok SoftWheat

        "COLZA" ->
            Ok Rapeseed

        "DIVERS" ->
            Ok Miscellaneous

        "FRUITS A COQUES" ->
            Ok Nuts

        "LEGUMES-FLEURS" ->
            Ok VegetablesAndFlowers

        "LEGUMINEUSES A GRAIN" ->
            Ok GrainLegumes

        "MAIS GRAIN ET ENSILAGE" ->
            Ok CornGrainAndSilage

        "" ->
            Ok NoCropGroup

        "OLIVIERS" ->
            Ok OliveTrees

        "ORGE" ->
            Ok Barley

        "PLANTES A FIBRES" ->
            Ok FiberPlants

        "PRAIRIES PERMANENTES" ->
            Ok PermanentGrasslands

        "PRAIRIES TEMPORAIRES" ->
            Ok TemporaryGrasslands

        "PROTEAGINEUX" ->
            Ok ProteinCrops

        "RIZ" ->
            Ok Rice

        "TOURNESOL" ->
            Ok Sunflower

        "VERGERS" ->
            Ok Orchards

        "VIGNES" ->
            Ok Vineyards

        _ ->
            Err <| "Groupe de culture invalide : " ++ str


toLabel : CropGroup -> String
toLabel cropGroup =
    case cropGroup of
        OtherCereals ->
            "Autres céréales"

        OtherIndustrialCrops ->
            "Autres cultures industrielles"

        OtherOilseeds ->
            "Autres oléagineux"

        SoftWheat ->
            "Blé tendre"

        Rapeseed ->
            "Colza"

        Miscellaneous ->
            "Divers"

        Nuts ->
            "Fruits à coques"

        VegetablesAndFlowers ->
            "Légumes et fleurs"

        GrainLegumes ->
            "Légumineuses à grain"

        CornGrainAndSilage ->
            "Maïs grain et ensilage"

        NoCropGroup ->
            "N/A"

        OliveTrees ->
            "Oliviers"

        Barley ->
            "Orge"

        FiberPlants ->
            "Plantes à fibres"

        PermanentGrasslands ->
            "Prairies permanentes"

        TemporaryGrasslands ->
            "Prairies temporaires"

        ProteinCrops ->
            "Proteagineux"

        Rice ->
            "Riz"

        Sunflower ->
            "Tournesol"

        Orchards ->
            "Vergers"

        Vineyards ->
            "Vignes"


decode : Decoder CropGroup
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


empty : CropGroup
empty =
    NoCropGroup
