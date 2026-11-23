module Data.Format exposing
    ( formatFloat
    , formatFrenchDatetime
    , formatKilograms
    )

import DateFormat
import Decimal
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Mass exposing (Mass)
import Time exposing (Posix)


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
    if isNaN float then
        -- FIXME: this is a temporary workaround for when distances were missing
        --        during computation of a score and we fallback to using Infinity
        -- @see https://www.notion.so/e3866a56500d4dfd9c2fc1d3d44c58a1
        "N/A"

    else if isInfinite float then
        (if float < 0 then
            "-"

         else
            ""
        )
            ++ "∞"

    else if float == 0 then
        "0"

    else if toFloat (round float) == float then
        -- flpat is an int, no need for decimals
        simpleFmt 0 float

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


formatFrenchDatetime : Posix -> String
formatFrenchDatetime =
    DateFormat.formatI18n DateFormat.french
        "dd/MM/yyyy à HH:mm:ss (UTC)"
        Time.utc


formatKilograms : Mass -> String
formatKilograms mass =
    formatFloat 3 (Mass.inKilograms mass)
        ++ "kg"
