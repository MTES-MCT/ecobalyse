module Data.Food.Ingredient.CropGroup exposing (CropGroup, decode, empty, toLabel)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type CropGroup
    = Arboriculture
    | OtherFrozen
    | Barley
    | Sugarcane
    | CornGrainAndSilage
    | SummerPastures
    | FiberPlants
    | Forage
    | Frozen
    | IndustrialFrozen
    | GrainLegumes
    | LegumesAndFlowers
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
    | Seeds
    | SoftWheat
    | Sunflower
    | TemporaryGrasslands
    | VegetablesAndFlowers
    | Vineyards


fromString : String -> Result String CropGroup
fromString str =
    case str of
        "ARBORICULTURE" ->
            Ok Arboriculture

        "AUTRES GELS" ->
            Ok OtherFrozen

        "ORGE" ->
            Ok Barley

        "CANNE A SUCRE" ->
            Ok Sugarcane


        "MAIS GRAIN ET ENSILAGE" ->
            Ok CornGrainAndSilage

        "ESTIVES LANDES" ->
            Ok SummerPastures

        "PLANTES A FIBRES" ->
            Ok FiberPlants

        "FOURRAGE" ->
            Ok Forage

        "GEL (surfaces gelées sans production)" ->
            Ok Frozen

        "GEL INDUSTRIEL" ->
            Ok IndustrialFrozen

        "LEGUMINEUSES A GRAIN" ->
            Ok GrainLegumes

        "LEGUMES-FLEURS" ->
            Ok VegetablesAndFlowers

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

        "SEMENCES" ->
            Ok Seeds

        "BLE TENDRE" ->
            Ok SoftWheat

        "TOURNESOL" ->
            Ok Sunflower

        "PRAIRIES TEMPORAIRES" ->
            Ok TemporaryGrasslands

        "VIGNES" ->
            Ok Vineyards

        _ ->
            Err <| "Groupe de culture invalide : " ++ str


toLabel : CropGroup -> String
toLabel cropGroup =
    case cropGroup of
        Arboriculture ->
            "Arboriculture"

        OtherFrozen ->
            "Autres gels"

        Barley ->
            "Orge"

        Sugarcane ->
            "Canne à sucre"
        CornGrainAndSilage ->
            "Maïs grain et ensilage"

        SummerPastures ->
            "Estives landes"

        FiberPlants ->
            "Plantes à fibres"

        Forage ->
            "Fourrage"

        Frozen ->
            "Gel (surfaces gelées sans production)"

        IndustrialFrozen ->
            "Gel industriel"

        GrainLegumes ->
            "Légumineuses à grain"

        LegumesAndFlowers ->
            "Légumes et fleurs"

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
            "Protéagineux"

        Rapeseed ->
            "Colza"

        Rice ->
            "Riz"

        Seeds ->
            "Semences"

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
