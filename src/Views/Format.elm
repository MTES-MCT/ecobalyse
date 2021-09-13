module Views.Format exposing (..)

import Energy exposing (Energy)
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Html exposing (..)
import Html.Attributes exposing (..)
import Mass exposing (Mass)


formatInt : String -> Int -> String
formatInt unit int =
    FormatNumber.format { frenchLocale | decimals = Exact 0 } (toFloat int) ++ "\u{202F}" ++ unit


formatFloat : Int -> Float -> String
formatFloat decimals float =
    FormatNumber.format { frenchLocale | decimals = Exact decimals } float


formatRichFloat : Int -> String -> Float -> Html msg
formatRichFloat decimals unit value =
    span []
        [ text
            (if value == 0 then
                "0"

             else
                formatFloat decimals value
            )
        , text "\u{202F}"
        , span [ class "fs-70p" ] [ text unit ]
        ]


kgCo2 : Int -> Float -> Html msg
kgCo2 decimals =
    formatRichFloat decimals "kgCO₂e"


kg : Mass -> Html msg
kg =
    Mass.inKilograms >> formatRichFloat 2 "kg"


kilowattHours : Energy -> Html msg
kilowattHours =
    Energy.inKilowattHours >> formatRichFloat 2 "KWh"


megajoules : Energy -> Html msg
megajoules =
    Energy.inMegajoules >> formatRichFloat 2 "MJ"


percent : Float -> Html msg
percent =
    formatRichFloat 2 "%"
