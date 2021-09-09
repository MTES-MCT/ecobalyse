module Views.Format exposing (..)

import Data.Unit as Unit
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Html exposing (..)
import Html.Attributes exposing (..)


formatInt : String -> Int -> String
formatInt unit int =
    FormatNumber.format { frenchLocale | decimals = Exact 0 } (toFloat int) ++ "\u{202F}" ++ unit


formatFloat : Int -> Float -> String
formatFloat decimals float =
    FormatNumber.format { frenchLocale | decimals = Exact decimals } float


formatRichFloat : Int -> String -> Float -> Html msg
formatRichFloat decimals unit value =
    span []
        [ value |> formatFloat decimals |> text
        , text "\u{202F}"
        , span [ class "fs-70p" ] [ text unit ]
        ]


kgCo2 : Float -> Html msg
kgCo2 =
    formatRichFloat 2 "kgCO₂e"


kg : Unit.Kg -> Html msg
kg =
    Unit.kgToFloat >> formatRichFloat 2 "kg"


percent : Float -> Html msg
percent =
    formatRichFloat 2 "%"
