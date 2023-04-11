module Views.Format exposing
    ( days
    , formatFloat
    , formatFoodSelectedImpact
    , formatFoodSelectedImpactPerKg
    , formatImpactFloat
    , formatRichFloat
    , formatTextileSelectedImpact
    , hours
    , kg
    , kgToString
    , kilowattHours
    , km
    , m3
    , megajoules
    , percent
    , ratio
    , splitAsFloat
    , splitAsPercentage
    , squareMetters
    , surfaceMass
    , yarnSize
    )

import Area exposing (Area)
import Data.Impact as Impact exposing (Impacts)
import Data.Split as Split exposing (Split)
import Data.Unit as Unit
import Decimal
import Duration exposing (Duration)
import Energy exposing (Energy)
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Html exposing (..)
import Html.Attributes exposing (..)
import Length exposing (Length)
import Mass exposing (Mass)
import Volume exposing (Volume)


formatImpactFloat : Impact.Definition -> Float -> Html msg
formatImpactFloat { unit, decimals } =
    formatRichFloat decimals unit


formatFoodSelectedImpact : Impact.Definition -> Impacts -> Html msg
formatFoodSelectedImpact { trigram, unit, decimals } =
    Impact.getImpact trigram
        >> Unit.impactToFloat
        >> formatRichFloat decimals unit


formatFoodSelectedImpactPerKg : Impact.Definition -> Impacts -> Html msg
formatFoodSelectedImpactPerKg { trigram, unit, decimals } =
    Impact.getImpact trigram
        >> Unit.impactToFloat
        >> formatRichFloat decimals (unit ++ "/kg")


formatTextileSelectedImpact : Unit.Functional -> Duration -> Impact.Definition -> Impacts -> Html msg
formatTextileSelectedImpact funit daysOfWear { trigram, unit, decimals } =
    Impact.getImpact trigram
        >> Unit.inFunctionalUnit funit daysOfWear
        >> Unit.impactToFloat
        >> formatRichFloat decimals unit


{-| Formats a float with a provided decimal precision, which is overriden
automatically when the provided value is either:

  - greater or equal to `100`
  - stricly lesser than `0.01`

-}
formatFloat : Int -> Float -> String
formatFloat decimals float =
    let
        simpleFmt dc =
            FormatNumber.format { frenchLocale | decimals = Exact dc }
                >> String.replace "−" "-"
    in
    if float == 0 then
        "0"

    else if abs float >= 100 then
        simpleFmt 0 float

    else if abs float < 0.01 then
        let
            sci =
                float
                    |> Decimal.fromFloat
                    |> Decimal.roundTo -12
                    |> Decimal.toStringIn Decimal.Sci

            formatFloatStr =
                String.toFloat >> Maybe.withDefault 0 >> simpleFmt 2
        in
        case String.split "e" sci of
            [ floatStr, exp ] ->
                formatFloatStr floatStr ++ "e" ++ exp

            _ ->
                simpleFmt decimals float

    else
        simpleFmt decimals float


formatRichFloat : Int -> String -> Float -> Html msg
formatRichFloat decimals unit value =
    span []
        [ value
            |> formatFloat decimals
            |> text
        , span [ class "fs-unit" ] [ text "\u{202F}", text unit ]
        ]


kg : Mass -> Html msg
kg =
    Mass.inKilograms >> formatRichFloat 3 "kg"


kgToString : Mass -> String
kgToString mass =
    formatFloat 3 (Mass.inKilograms mass)
        ++ "kg"


km : Length -> Html msg
km =
    Length.inKilometers >> formatRichFloat 0 "km"


kilowattHours : Energy -> Html msg
kilowattHours =
    Energy.inKilowattHours >> formatRichFloat 2 "kWh"


m3 : Volume -> Html msg
m3 =
    Volume.inCubicMeters >> formatRichFloat 2 "m³"


megajoules : Energy -> Html msg
megajoules =
    Energy.inMegajoules >> formatRichFloat 2 "MJ"


percent : Float -> Html msg
percent =
    formatRichFloat 2 "%"


squareMetters : Area -> Html msg
squareMetters =
    Area.inSquareMeters >> formatRichFloat 2 "m²"


surfaceMass : Unit.SurfaceMass -> Html msg
surfaceMass =
    Unit.surfaceMassInGramsPerSquareMeters >> toFloat >> formatRichFloat 0 "g/m²"


yarnSize : Unit.YarnSize -> Html msg
yarnSize =
    Unit.yarnSizeInKilometers >> toFloat >> formatRichFloat 0 "Nm"


ratio : Unit.Ratio -> Html msg
ratio =
    ratioToDecimals 2


ratioToDecimals : Int -> Unit.Ratio -> Html msg
ratioToDecimals decimals (Unit.Ratio float) =
    (float * 100)
        |> formatRichFloat decimals "%"


splitAsFloat : Int -> Split -> Html msg
splitAsFloat int value =
    Split.toFloat value
        |> formatFloat int
        |> text


splitAsPercentage : Split -> Html msg
splitAsPercentage value =
    Split.toPercentString value
        ++ "\u{202F}%"
        |> Html.text


days : Duration -> Html msg
days =
    Duration.inDays >> formatRichFloat 0 "j"


hours : Duration -> Html msg
hours =
    Duration.inHours >> formatRichFloat 2 "h"
