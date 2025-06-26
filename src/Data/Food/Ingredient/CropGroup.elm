module Data.Food.Ingredient.CropGroup exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE


type CropGroup
    = LegumesFleurs
    | Vergers
    | Colza
    | Tournesol
    | FruitsACoques
    | LegumineusesAGrain
    | BleTendre
    | Orge
    | Riz
    | MaisGrainEtEnsilage
    | AutresCereales
    | AutresCulturesIndustrielles
    | AutresOleagineux
    | Vignes
    | Oliviers
    | Divers
    | Proteagineux
    | PrairiesTemporaires
    | PrairiesPermanentes
    | PlantesAFibres
    | NoCropGroup


fromString : String -> Result String CropGroup
fromString str =
    case str of
        "LEGUMES-FLEURS" ->
            Ok LegumesFleurs

        "VERGERS" ->
            Ok Vergers

        "COLZA" ->
            Ok Colza

        "TOURNESOL" ->
            Ok Tournesol

        "FRUITS A COQUES" ->
            Ok FruitsACoques

        "LEGUMINEUSES A GRAIN" ->
            Ok LegumineusesAGrain

        "BLE TENDRE" ->
            Ok BleTendre

        "ORGE" ->
            Ok Orge

        "RIZ" ->
            Ok Riz

        "MAIS GRAIN ET ENSILAGE" ->
            Ok MaisGrainEtEnsilage

        "AUTRES CEREALES" ->
            Ok AutresCereales

        "AUTRES CULTURES INDUSTRIELLES" ->
            Ok AutresCulturesIndustrielles

        "AUTRES OLEAGINEUX" ->
            Ok AutresOleagineux

        "VIGNES" ->
            Ok Vignes

        "OLIVIERS" ->
            Ok Oliviers

        "DIVERS" ->
            Ok Divers

        "PROTEAGINEUX" ->
            Ok Proteagineux

        "PRAIRIES TEMPORAIRES" ->
            Ok PrairiesTemporaires

        "PRAIRIES PERMANENTES" ->
            Ok PrairiesPermanentes

        "PLANTES A FIBRES" ->
            Ok PlantesAFibres

        "" ->
            Ok NoCropGroup

        _ ->
            Err <| "Groupe de culture invalide : " ++ str


toLabel : CropGroup -> String
toLabel cropGroup =
    case cropGroup of
        LegumesFleurs ->
            "Légumes et fleurs"

        Vergers ->
            "Vergers"

        Colza ->
            "Colza"

        Tournesol ->
            "Tournesol"

        FruitsACoques ->
            "Fruits à coques"

        LegumineusesAGrain ->
            "Légumineuses à grain"

        BleTendre ->
            "Blé tendre"

        Orge ->
            "Orge"

        Riz ->
            "Riz"

        MaisGrainEtEnsilage ->
            "Maïs grain et ensilage"

        AutresCereales ->
            "Autres céréales"

        AutresCulturesIndustrielles ->
            "Autres cultures industrielles"

        AutresOleagineux ->
            "Autres oléagineux"

        Vignes ->
            "Vignes"

        Oliviers ->
            "Oliviers"

        Divers ->
            "Divers"

        Proteagineux ->
            "Proteagineux"

        PrairiesTemporaires ->
            "Prairies temporaires"

        PrairiesPermanentes ->
            "Prairies permanentes"

        PlantesAFibres ->
            "Plantes à fibres"

        NoCropGroup ->
            "N/A"


decode : Decoder CropGroup
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


empty : CropGroup
empty =
    NoCropGroup
