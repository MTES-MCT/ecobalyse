module Views.Format exposing (..)

import Data.Impact as Impact exposing (Impacts)
import Data.Unit as Unit
import Decimal
import Energy exposing (Energy)
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Html exposing (..)
import Html.Attributes exposing (..)
import Length exposing (Length)
import Mass exposing (Mass)


formatImpact : Impact.Definition -> Impacts -> Html msg
formatImpact { trigram, unit } =
    Impact.getImpact trigram
        >> Unit.impactToFloat
        >> formatRichFloat 2 unit


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


km : Length -> Html msg
km =
    Length.inKilometers >> formatRichFloat 0 "km"


kilowattHours : Energy -> Html msg
kilowattHours =
    Energy.inKilowattHours >> formatRichFloat 2 "KWh"


megajoules : Energy -> Html msg
megajoules =
    Energy.inMegajoules >> formatRichFloat 2 "MJ"


percent : Float -> Html msg
percent =
    formatRichFloat 2 "%"


ratio : Unit.Ratio -> Html msg
ratio (Unit.Ratio float) =
    (float * 100)
        |> formatRichFloat 2 "%"
