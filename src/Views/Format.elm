module Views.Format exposing (..)

import Data.Impact as Impact2
import Data.Unit as Unit
import Energy exposing (Energy)
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Html exposing (..)
import Html.Attributes exposing (..)
import Length exposing (Length)
import Mass exposing (Mass)
import Page.Simulator.Impact as Impact exposing (Impact)


formatImpact : Impact -> { a | cch : Unit.Co2e, fwe : Unit.Pe } -> Html msg
formatImpact impact { cch, fwe } =
    case impact of
        Impact.ClimateChange ->
            kgCo2 2 cch

        Impact.FreshwaterEutrophication ->
            kgP 2 fwe


formatImpact2 : Impact2.Impact -> Unit.Impact -> Html msg
formatImpact2 { unit } =
    Unit.impactToFloat >> formatRichFloat 2 unit


formatInt : String -> Int -> String
formatInt unit int =
    FormatNumber.format { frenchLocale | decimals = Exact 0 } (toFloat int) ++ "\u{202F}" ++ unit


formatFloat : Int -> Float -> String
formatFloat decimals float =
    -- FIXME: there must be a simpler way…
    let
        ( newFloat, expStr ) =
            if float == 0 then
                ( float, "" )

            else if float < 0.000000001 then
                ( float * 1000 * 1000 * 1000, "E-9" )

            else if float < 0.00000001 then
                ( float * 100000000, "E-8" )

            else if float < 0.0000001 then
                ( float * 10000000, "E-7" )

            else if float < 0.000001 then
                ( float * 1000000, "E-6" )

            else if float < 0.00001 then
                ( float * 100000, "E-5" )

            else if float < 0.0001 then
                ( float * 10000, "E-4" )

            else if float < 0.001 then
                ( float * 1000, "E-3" )

            else if float < 0.01 then
                ( float * 100, "E-2" )

            else if float < 0.1 then
                ( float * 10, "E-1" )

            else
                ( float, "" )
    in
    FormatNumber.format { frenchLocale | decimals = Exact decimals } newFloat ++ expStr


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
    Unit.inKgPe >> formatRichFloat decimals "kgPe"


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
