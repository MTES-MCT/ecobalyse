module Data.Food.Ingredient.CropGroup exposing (CropGroup, decode, empty, toLabel)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type CropGroup
    = AutresCereales
    | AutresCulturesIndustrielles
    | AutresOleagineux
    | BleTendre
    | Colza
    | Divers
    | FruitsACoques
    | LegumesFleurs
    | LegumineusesAGrain
    | MaisGrainEtEnsilage
    | NoCropGroup
    | Oliviers
    | Orge
    | PlantesAFibres
    | PrairiesPermanentes
    | PrairiesTemporaires
    | Proteagineux
    | Riz
    | Tournesol
    | Vergers
    | Vignes


fromString : String -> Result String CropGroup
fromString str =
    case str of
        "AUTRES CEREALES" ->
            Ok AutresCereales

        "AUTRES CULTURES INDUSTRIELLES" ->
            Ok AutresCulturesIndustrielles

        "AUTRES OLEAGINEUX" ->
            Ok AutresOleagineux

        "BLE TENDRE" ->
            Ok BleTendre

        "COLZA" ->
            Ok Colza

        "DIVERS" ->
            Ok Divers

        "FRUITS A COQUES" ->
            Ok FruitsACoques

        "LEGUMES-FLEURS" ->
            Ok LegumesFleurs

        "LEGUMINEUSES A GRAIN" ->
            Ok LegumineusesAGrain

        "MAIS GRAIN ET ENSILAGE" ->
            Ok MaisGrainEtEnsilage

        "" ->
            Ok NoCropGroup

        "OLIVIERS" ->
            Ok Oliviers

        "ORGE" ->
            Ok Orge

        "PLANTES A FIBRES" ->
            Ok PlantesAFibres

        "PRAIRIES PERMANENTES" ->
            Ok PrairiesPermanentes

        "PRAIRIES TEMPORAIRES" ->
            Ok PrairiesTemporaires

        "PROTEAGINEUX" ->
            Ok Proteagineux

        "RIZ" ->
            Ok Riz

        "TOURNESOL" ->
            Ok Tournesol

        "VERGERS" ->
            Ok Vergers

        "VIGNES" ->
            Ok Vignes

        _ ->
            Err <| "Groupe de culture invalide : " ++ str


toLabel : CropGroup -> String
toLabel cropGroup =
    case cropGroup of
        AutresCereales ->
            "Autres céréales"

        AutresCulturesIndustrielles ->
            "Autres cultures industrielles"

        AutresOleagineux ->
            "Autres oléagineux"

        BleTendre ->
            "Blé tendre"

        Colza ->
            "Colza"

        Divers ->
            "Divers"

        FruitsACoques ->
            "Fruits à coques"

        LegumesFleurs ->
            "Légumes et fleurs"

        LegumineusesAGrain ->
            "Légumineuses à grain"

        MaisGrainEtEnsilage ->
            "Maïs grain et ensilage"

        NoCropGroup ->
            "N/A"

        Oliviers ->
            "Oliviers"

        Orge ->
            "Orge"

        PlantesAFibres ->
            "Plantes à fibres"

        PrairiesPermanentes ->
            "Prairies permanentes"

        PrairiesTemporaires ->
            "Prairies temporaires"

        Proteagineux ->
            "Proteagineux"

        Riz ->
            "Riz"

        Tournesol ->
            "Tournesol"

        Vergers ->
            "Vergers"

        Vignes ->
            "Vignes"


decode : Decoder CropGroup
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


empty : CropGroup
empty =
    NoCropGroup
