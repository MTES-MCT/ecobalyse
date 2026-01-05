module Data.Textile.Material.Spinning exposing
    ( Spinning
    , decode
    , encode
    , fromString
    , getAvailableProcesses
    , getDefault
    , getElec
    , toLabel
    , toString
    , waste
    )

import Data.Split as Split exposing (Split)
import Data.Textile.Material.Origin as Origin exposing (Origin)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Mass exposing (Mass)


type Spinning
    = Conventional
    | Synthetic
    | Unconventional


type alias ProcessData =
    { normalization : Float, waste : Split }


fromString : String -> Result String Spinning
fromString string =
    case string of
        "ConventionalSpinning" ->
            Ok Conventional

        "SyntheticSpinning" ->
            Ok Synthetic

        "UnconventionalSpinning" ->
            Ok Unconventional

        other ->
            Err <| "Le procédé de filature ou filage " ++ other ++ " n'est pas valide"


toString : Spinning -> String
toString spinning =
    case spinning of
        Conventional ->
            "ConventionalSpinning"

        Synthetic ->
            "SyntheticSpinning"

        Unconventional ->
            "UnconventionalSpinning"


toLabel : Spinning -> String
toLabel spinning =
    case spinning of
        Conventional ->
            "Filature conventionnelle"

        Synthetic ->
            "Filage"

        Unconventional ->
            "Filature non conventionnelle"


decode : Decoder Spinning
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


encode : Spinning -> Encode.Value
encode =
    toString >> Encode.string


processesData : { conventional : ProcessData, synthetic : ProcessData, unconventional : ProcessData }
processesData =
    -- See https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#consommation-delectricite
    -- and https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#taux-de-pertes
    { conventional = { normalization = 4, waste = Split.fromPercent 12 |> Result.withDefault Split.zero }
    , synthetic = { normalization = 1.5, waste = Split.fromPercent 3 |> Result.withDefault Split.zero }
    , unconventional = { normalization = 2, waste = Split.fromPercent 12 |> Result.withDefault Split.zero }
    }


getDefault : Origin -> Spinning
getDefault origin =
    -- See https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#fabrication-du-fil-filature-vs-filage-1
    -- Depending on the origin of the fiber, the default spinning process to use is different:
    -- * natural or artificial origin: conventional spinning (can be changed by the user to unconventional spinning)
    -- * synthetic origin: synthetic spinning (can't be changed to anything else)
    case origin of
        Origin.Synthetic ->
            Synthetic

        _ ->
            Conventional


getAvailableProcesses : Origin -> List Spinning
getAvailableProcesses origin =
    case origin of
        Origin.Synthetic ->
            [ Synthetic ]

        _ ->
            [ Conventional, Unconventional ]


normalization : Spinning -> Float
normalization spinning =
    case spinning of
        Conventional ->
            processesData.conventional.normalization

        Synthetic ->
            processesData.synthetic.normalization

        Unconventional ->
            processesData.unconventional.normalization


waste : Spinning -> Split
waste spinning =
    case spinning of
        Conventional ->
            processesData.conventional.waste

        Synthetic ->
            processesData.synthetic.waste

        Unconventional ->
            processesData.unconventional.waste


getElec : Mass -> Unit.YarnSize -> Spinning -> Float
getElec mass yarnSize spinning =
    -- See the formula in https://fabrique-numerique.gitbook.io/ecobalyse/textile/etapes-du-cycle-de-vie/etape-2-fabrication-du-fil-new-draft#consommation-delectricite
    -- Formula: kWh(Process) = YarnSize(Nm) / 50 * Normalization(Process) * OutputMass(kg)
    Unit.yarnSizeInKilometers yarnSize
        / 50
        * normalization spinning
        * Mass.inKilograms mass
