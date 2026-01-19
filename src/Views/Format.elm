module Views.Format exposing
    ( amount
    , complement
    , cubicMeters
    , days
    , diff
    , formatFloat
    , formatImpact
    , formatImpactFloat
    , formatRichFloat
    , frenchDate
    , frenchDatetime
    , hours
    , kg
    , kgToString
    , kilowattHours
    , km
    , massPerUnit
    , megajoules
    , minutes
    , percent
    , picking
    , priceInEUR
    , splitAsFloat
    , splitAsPercentage
    , squareMeters
    , surfaceMass
    , threadDensity
    , yarnSize
    )

import Area exposing (Area)
import Data.Component as Component
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definition)
import Data.Process as Process exposing (Process)
import Data.Split as Split exposing (Split)
import Data.Textile.Economics as Economics
import Data.Unit as Unit
import DateFormat
import Decimal
import Duration exposing (Duration)
import Energy exposing (Energy)
import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Html exposing (..)
import Html.Attributes exposing (..)
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity
import Time exposing (Posix)
import Volume exposing (Volume)


formatImpactFloat : { a | decimals : Int, unit : String } -> Float -> Html msg
formatImpactFloat { decimals, unit } =
    formatRichFloat decimals unit


formatImpact : Definition -> Impacts -> Html msg
formatImpact { decimals, trigram, unit } =
    Impact.getImpact trigram
        >> Unit.impactToFloat
        >> formatRichFloat decimals unit


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


formatRichFloat : Int -> String -> Float -> Html msg
formatRichFloat decimals unit value =
    span []
        [ value
            |> formatFloat decimals
            |> text
        , span [ class "fs-unit" ] [ text "\u{202F}", text unit ]
        ]


complement : Unit.Impact -> Html msg
complement impact =
    -- Notes:
    -- - maluses are expressed with a negative number, bonuses with a
    --   positive one; here we render the *effect* it has on the score
    -- - complements are *always* expressed in ecoscore points
    let
        formatted =
            impact
                |> Quantity.negate
                |> Unit.impactToFloat
                |> formatFloat 2
    in
    span []
        [ text <|
            if not (String.startsWith "-" formatted) then
                "+" ++ formatted

            else
                formatted
        , span [ class "fs-unit" ] [ text "\u{202F}Pts" ]
        ]


amount : Process -> Component.Amount -> Html msg
amount { unit } amount_ =
    let
        floatAmount =
            Component.amountToFloat amount_
    in
    case unit of
        Process.CubicMeter ->
            cubicMeters <| Volume.cubicMeters floatAmount

        Process.Kilogram ->
            kg <| Mass.kilograms floatAmount

        Process.Liter ->
            liters <| Volume.liters floatAmount

        Process.SquareMeter ->
            squareMeters <| Area.squareMeters floatAmount

        _ ->
            String.fromFloat floatAmount
                ++ " "
                ++ Process.unitToString unit
                |> text


cubicMeters : Volume -> Html msg
cubicMeters =
    Volume.inCubicMeters >> formatRichFloat 3 "m³"


kg : Mass -> Html msg
kg =
    Mass.inKilograms >> formatRichFloat 3 "kg"


kgToString : Mass -> String
kgToString mass =
    formatFloat 3 (Mass.inKilograms mass)
        ++ "kg"


km : Length -> Html msg
km =
    Length.inKilometers >> formatRichFloat 0 "km"


liters : Volume -> Html msg
liters =
    Volume.inLiters >> formatRichFloat 3 "L"


kilowattHours : Energy -> Html msg
kilowattHours =
    Energy.inKilowattHours >> formatRichFloat 2 "kWh"


megajoules : Energy -> Html msg
megajoules =
    Energy.inMegajoules >> formatRichFloat 2 "MJ"


percent : Float -> Html msg
percent =
    formatRichFloat 2 "%"


priceInEUR : Economics.Price -> Html msg
priceInEUR =
    Economics.priceToFloat >> formatRichFloat 2 "€"


squareMeters : Area -> Html msg
squareMeters =
    Area.inSquareMeters >> formatRichFloat 3 "m²"


surfaceMass : Unit.SurfaceMass -> Html msg
surfaceMass =
    Unit.surfaceMassInGramsPerSquareMeters >> toFloat >> formatRichFloat 0 "g/m²"


threadDensity : Unit.ThreadDensity -> Html msg
threadDensity (Unit.ThreadDensity density_) =
    density_ |> formatRichFloat 0 "#/cm"


picking : Unit.PickPerMeter -> Html msg
picking =
    Unit.pickPerMeterToFloat >> formatRichFloat 0 "duites.m"


yarnSize : Unit.YarnSize -> Html msg
yarnSize =
    Unit.yarnSizeInKilometers >> formatRichFloat 0 "Nm"


splitAsFloat : Int -> Split -> Html msg
splitAsFloat int value =
    Split.toFloat value
        |> formatFloat int
        |> text


splitAsPercentage : Int -> Split -> Html msg
splitAsPercentage decimals value =
    Split.toPercentString decimals value
        ++ "\u{202F}%"
        |> Html.text


frenchDate : Posix -> String
frenchDate =
    DateFormat.formatI18n DateFormat.french
        "dd/MM/yyyy"
        Time.utc


frenchDatetime : Posix -> String
frenchDatetime =
    DateFormat.formatI18n DateFormat.french
        "dd/MM/yyyy à HH:mm:ss (UTC)"
        Time.utc


days : Duration -> Html msg
days =
    Duration.inDays >> formatRichFloat 0 "j"


hours : Duration -> Html msg
hours =
    Duration.inHours >> formatRichFloat 2 "h"


minutes : Duration -> Html msg
minutes =
    Duration.inMinutes >> formatRichFloat 0 "min"


massPerUnit : { a | massPerUnit : Maybe Float, unit : Process.Unit } -> Html msg
massPerUnit process =
    case process.massPerUnit of
        Just value ->
            if process.unit /= Process.Kilogram then
                formatRichFloat 2 ("kg/" ++ Process.unitToString process.unit) value

            else
                text "N/A"

        Nothing ->
            text "N/A"


diff : String -> Html msg
diff =
    String.split "\n"
        >> List.map
            (\line ->
                div
                    [ class <|
                        if String.startsWith "+ " line then
                            "bg-success bg-opacity-10 text-success"

                        else if String.startsWith "- " line then
                            "bg-danger bg-opacity-10 text-danger"

                        else
                            "text-muted"
                    ]
                    [ text line ]
            )
        >> pre [ class "mb-0" ]
