module Views.Format exposing (..)

import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Html exposing (..)
import Html.Attributes exposing (..)


formatInt : String -> Int -> String
formatInt unit int =
    FormatNumber.format { frenchLocale | decimals = Exact 0 } (toFloat int) ++ "\u{202F}" ++ unit


formatFloat : String -> Float -> String
formatFloat unit float =
    FormatNumber.format { frenchLocale | decimals = Exact 3 } float ++ "\u{202F}" ++ unit


kgCo2 : Float -> Html msg
kgCo2 co2 =
    span []
        [ co2 |> FormatNumber.format { frenchLocale | decimals = Exact 3 } |> text
        , text "\u{202F}"
        , span [ class "fs-70p" ] [ text "kgCO₂e" ]
        ]


kg : Float -> Html msg
kg kg_ =
    span []
        [ kg_ |> FormatNumber.format { frenchLocale | decimals = Exact 3 } |> text
        , text "\u{202F}"
        , span [ class "fs-70p" ] [ text "kg" ]
        ]
