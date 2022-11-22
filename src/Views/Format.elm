module Views.Format exposing
    ( days
    , formatFloat
    , formatImpact
    , formatImpactFloat
    , formatRichFloat
    , hours
    , kg
    , kgToString
    , kilowattHours
    , km
    , m3
    , megajoules
    , percent
    , picking
    , ratio
    , ratioToDecimals
    , ratioToPercentString
    , surfaceMass
    )

import Data.Impact as Impact exposing (Impacts)
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


formatImpact : Unit.Functional -> Impact.Definition -> Duration -> Impacts -> Html msg
formatImpact funit { trigram, unit, decimals } daysOfWear def =
    def
        |> Impact.getImpact trigram
        |> Unit.inFunctionalUnit funit daysOfWear
        |> Unit.impactToFloat
        |> formatRichFloat decimals unit


formatImpactFloat : Impact.Definition -> Int -> Float -> Html msg
formatImpactFloat { unit } decimals =
    formatRichFloat decimals unit


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
    if abs float >= 100 then
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
        [ text
            (if value == 0 then
                "0"

             else
                formatFloat decimals value
            )
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


surfaceMass : Unit.SurfaceMass -> Html msg
surfaceMass =
    Unit.surfaceMassToFloat >> formatRichFloat 0 "gr/m²"


picking : Unit.PickPerMeter -> Html msg
picking =
    Unit.pickPerMeterToFloat >> formatRichFloat 0 "duites/m"


ratioToPercentString : Unit.Ratio -> String
ratioToPercentString value =
    (value
        |> Unit.ratioToFloat
        |> (*) 100
        |> round
        |> String.fromInt
    )
        ++ "\u{202F}%"


ratio : Unit.Ratio -> Html msg
ratio =
    ratioToDecimals 2


ratioToDecimals : Int -> Unit.Ratio -> Html msg
ratioToDecimals decimals (Unit.Ratio float) =
    (float * 100)
        |> formatRichFloat decimals "%"


days : Duration -> Html msg
days =
    Duration.inDays >> formatRichFloat 0 "j"


hours : Duration -> Html msg
hours =
    Duration.inHours >> formatRichFloat 2 "h"
