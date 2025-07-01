module Data.Food.Ingredient.CropGroup exposing (CropGroup, decode, empty, toLabel)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type CropGroup
    = Barley
    | CornGrainAndSilage
    | FiberPlants
    | GrainLegumes
    | Miscellaneous
    | NoCropGroup
    | Nuts
    | OliveTrees
    | Orchards
    | OtherCereals
    | OtherIndustrialCrops
    | OtherOilseeds
    | PermanentGrasslands
    | ProteinCrops
    | Rapeseed
    | Rice
    | SoftWheat
    | Sunflower
    | TemporaryGrasslands
    | VegetablesAndFlowers
    | Vineyards


fromString : String -> Result String CropGroup
fromString str =
    case str of
        "ORGE" ->
            Ok Barley

        "MAIS GRAIN ET ENSILAGE" ->
            Ok CornGrainAndSilage

        "PLANTES A FIBRES" ->
            Ok FiberPlants

        "LEGUMINEUSES A GRAIN" ->
            Ok GrainLegumes

        "DIVERS" ->
            Ok Miscellaneous

        "" ->
            Ok NoCropGroup

        "FRUITS A COQUES" ->
            Ok Nuts

        "OLIVIERS" ->
            Ok OliveTrees

        "VERGERS" ->
            Ok Orchards

        "AUTRES CEREALES" ->
            Ok OtherCereals

        "AUTRES CULTURES INDUSTRIELLES" ->
            Ok OtherIndustrialCrops

        "AUTRES OLEAGINEUX" ->
            Ok OtherOilseeds

        "PRAIRIES PERMANENTES" ->
            Ok PermanentGrasslands

        "PROTEAGINEUX" ->
            Ok ProteinCrops

        "COLZA" ->
            Ok Rapeseed

        "RIZ" ->
            Ok Rice

        "BLE TENDRE" ->
            Ok SoftWheat

        "TOURNESOL" ->
            Ok Sunflower

        "PRAIRIES TEMPORAIRES" ->
            Ok TemporaryGrasslands

        "LEGUMES-FLEURS" ->
            Ok VegetablesAndFlowers

        "VIGNES" ->
            Ok Vineyards

        _ ->
            Err <| "Groupe de culture invalide : " ++ str


toLabel : CropGroup -> String
toLabel cropGroup =
    case cropGroup of
        Barley ->
            "Orge"

        CornGrainAndSilage ->
            "Maïs grain et ensilage"

        FiberPlants ->
            "Plantes à fibres"

        GrainLegumes ->
            "Légumineuses à grain"

        Miscellaneous ->
            "Divers"

        NoCropGroup ->
            "N/A"

        Nuts ->
            "Fruits à coques"

        OliveTrees ->
            "Oliviers"

        Orchards ->
            "Vergers"

        OtherCereals ->
            "Autres céréales"

        OtherIndustrialCrops ->
            "Autres cultures industrielles"

        OtherOilseeds ->
            "Autres oléagineux"

        PermanentGrasslands ->
            "Prairies permanentes"

        ProteinCrops ->
            "Proteagineux"

        Rapeseed ->
            "Colza"

        Rice ->
            "Riz"

        SoftWheat ->
            "Blé tendre"

        Sunflower ->
            "Tournesol"

        TemporaryGrasslands ->
            "Prairies temporaires"

        VegetablesAndFlowers ->
            "Légumes et fleurs"

        Vineyards ->
            "Vignes"


decode : Decoder CropGroup
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


empty : CropGroup
empty =
    NoCropGroup
