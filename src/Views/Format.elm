module Views.Format exposing (..)

import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)


formatInt : String -> Int -> String
formatInt unit int =
    FormatNumber.format { frenchLocale | decimals = Exact 0 } (toFloat int) ++ "\u{202F}" ++ unit


formatFloat : String -> Float -> String
formatFloat unit float =
    FormatNumber.format { frenchLocale | decimals = Exact 3 } float ++ "\u{202F}" ++ unit
