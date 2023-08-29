module Data.Textile.Material.Spinning exposing (Spinning(..), decodeSpinning, encodeSpinning, getAvailableSpinningProcesses, getDefaultSpinning, getSpinningElec, spinningFromString, spinningToLabel, spinningToString, wasteForSpinning)

import Data.Split as Split exposing (Split)
import Data.Textile.Material.Origin as Origin exposing (Origin)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Mass exposing (Mass)


type Spinning
    = ConventionalSpinning
    | UnconventionalSpinning
    | SyntheticSpinning


type alias SpinningProcessData =
    { normalization : Float, waste : Split }


spinningFromString : String -> Result String Spinning
spinningFromString string =
    case string of
        "ConventionalSpinning" ->
            Ok ConventionalSpinning

        "UnconventionalSpinning" ->
            Ok UnconventionalSpinning

        "SyntheticSpinning" ->
            Ok SyntheticSpinning

        other ->
            Err <| "Le procédé de filature ou filage " ++ other ++ " n'est pas valide"


spinningToString : Spinning -> String
spinningToString spinning =
    case spinning of
        ConventionalSpinning ->
            "ConventionalSpinning"

        UnconventionalSpinning ->
            "UnconventionalSpinning"

        SyntheticSpinning ->
            "SyntheticSpinning"


spinningToLabel : Spinning -> String
spinningToLabel spinning =
    case spinning of
        ConventionalSpinning ->
            "Filature conventionnelle"

        UnconventionalSpinning ->
            "Filature non conventionnelle"

        SyntheticSpinning ->
            "Filage"


decodeSpinning : Decoder Spinning
decodeSpinning =
    Decode.string
        |> Decode.andThen (spinningFromString >> DE.fromResult)


encodeSpinning : Spinning -> Encode.Value
encodeSpinning =
    spinningToString >> Encode.string


spinningProcessesData : { conventional : SpinningProcessData, unconventional : SpinningProcessData, synthetic : SpinningProcessData }
spinningProcessesData =
    -- See https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#consommation-delectricite
    -- and https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#taux-de-pertes
    { conventional = { normalization = 4, waste = Split.fromPercent 12 |> Result.withDefault Split.zero }
    , unconventional = { normalization = 2, waste = Split.fromPercent 12 |> Result.withDefault Split.zero }
    , synthetic = { normalization = 1.5, waste = Split.fromPercent 3 |> Result.withDefault Split.zero }
    }


getDefaultSpinning : Origin -> Spinning
getDefaultSpinning origin =
    -- See https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#fabrication-du-fil-filature-vs-filage-1
    -- Depending on the origin of the fiber, the default spinning process to use is different:
    -- * natural or artificial origin: conventional spinning (can be changed by the user to unconventional spinning)
    -- * synthetic origin: synthetic spinning (can't be changed to anything else)
    case origin of
        Origin.Synthetic ->
            SyntheticSpinning

        _ ->
            ConventionalSpinning


getAvailableSpinningProcesses : Origin -> List Spinning
getAvailableSpinningProcesses origin =
    case origin of
        Origin.Synthetic ->
            [ SyntheticSpinning ]

        _ ->
            [ ConventionalSpinning, UnconventionalSpinning ]


normalizationForSpinning : Spinning -> Float
normalizationForSpinning spinning =
    case spinning of
        ConventionalSpinning ->
            spinningProcessesData.conventional.normalization

        UnconventionalSpinning ->
            spinningProcessesData.unconventional.normalization

        SyntheticSpinning ->
            spinningProcessesData.synthetic.normalization


wasteForSpinning : Spinning -> Split
wasteForSpinning spinning =
    case spinning of
        ConventionalSpinning ->
            spinningProcessesData.conventional.waste

        UnconventionalSpinning ->
            spinningProcessesData.unconventional.waste

        SyntheticSpinning ->
            spinningProcessesData.synthetic.waste


getSpinningElec : Mass -> Unit.YarnSize -> Spinning -> Float
getSpinningElec mass yarnSize spinning =
    -- See the formula in https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#consommation-delectricite
    -- Formula: kWh(Process) = YarnSize(Nm) / 50 * Normalization(Process) * OutputMass(kg)
    (Unit.yarnSizeInKilometers yarnSize |> toFloat)
        / 50
        * normalizationForSpinning spinning
        * Mass.inKilograms mass
