module Views.Format exposing
    ( days
    , formatFloat
    , formatImpact
    , formatImpactFloat
    , formatInt
    , formatRichFloat
    , hours
    , kg
    , kgAsString
    , kilowattHours
    , km
    , megajoules
    , percent
    , percentAsString
    , ratio
    , ratioToDecimals
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


formatImpact : Unit.Functional -> Impact.Definition -> Duration -> Impacts -> Html msg
formatImpact funit { trigram, unit } daysOfWear def =
    def
        |> Impact.getImpact trigram
        |> Unit.inFunctionalUnit funit daysOfWear
        |> Unit.impactToFloat
        |> formatRichFloat 2 unit


formatImpactFloat : Impact.Definition -> Float -> Html msg
formatImpactFloat { unit } =
    formatRichFloat 2 unit


formatInt : String -> Int -> String
formatInt unit int =
    FormatNumber.format { frenchLocale | decimals = Exact 0 }
        (toFloat int)
        ++ "\u{202F}"
        ++ unit


formatFloat : Int -> Float -> String
formatFloat decimals float =
    let
        simpleFmt =
            FormatNumber.format { frenchLocale | decimals = Exact decimals }
                >> String.replace "−" "-"
    in
    if abs float < 0.01 then
        let
            sci =
                float
                    |> Decimal.fromFloat
                    |> Decimal.roundTo -12
                    |> Decimal.toStringIn Decimal.Sci

            formatFloatStr =
                String.toFloat >> Maybe.withDefault 0 >> simpleFmt
        in
        case String.split "e" sci of
            [ floatStr, exp ] ->
                formatFloatStr floatStr ++ "e" ++ exp

            _ ->
                simpleFmt float

    else
        simpleFmt float


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


kgAsString : Mass -> String
kgAsString mass =
    formatFloat 3 (Mass.inKilograms mass)
        ++ "kg"


km : Length -> Html msg
km =
    Length.inKilometers >> formatRichFloat 0 "km"


kilowattHours : Energy -> Html msg
kilowattHours =
    Energy.inKilowattHours >> formatRichFloat 2 "kWh"


megajoules : Energy -> Html msg
megajoules =
    Energy.inMegajoules >> formatRichFloat 2 "MJ"


percent : Float -> Html msg
percent =
    formatRichFloat 2 "%"


percentAsString : Float -> String
percentAsString value =
    String.fromInt (round (value * 100)) ++ "\u{202F}%\u{00A0}"


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
