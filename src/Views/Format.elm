module Views.Format exposing (..)

import Data.Unit as Unit
import Energy exposing (Energy)
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Html exposing (..)
import Html.Attributes exposing (..)
import Length exposing (Length)
import Mass exposing (Mass)
import Page.Simulator.Impact as Impact exposing (Impact)


formatImpact : Impact -> { a | co2 : Unit.Co2e, fwe : Unit.Pe } -> Html msg
formatImpact impact { co2, fwe } =
    case impact of
        Impact.ClimateChange ->
            kgCo2 2 co2

        Impact.FreshwaterEutrophication ->
            kgP 2 fwe


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
        , span [ class "fs-80p" ] [ text unit ]
        ]


kgCo2 : Int -> Unit.Co2e -> Html msg
kgCo2 decimals =
    Unit.inKgCo2e >> formatRichFloat decimals "kgCO₂e"


kgP : Int -> Unit.Pe -> Html msg
kgP decimals =
    Unit.inGramsPe >> formatRichFloat decimals "E-03 kgPe"


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
