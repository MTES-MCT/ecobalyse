module Views.Format exposing (..)

import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), Locale, frenchLocale)


intLocale : Locale
intLocale =
    { frenchLocale | decimals = Exact 0 }


formatInt : String -> Int -> String
formatInt unit int =
    FormatNumber.format intLocale (toFloat int) ++ "\u{202F}" ++ unit
