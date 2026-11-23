module Views.Format exposing
    ( amount
    , complement
    , cubicMeters
    , days
    , formatImpact
    , formatImpactFloat
    , formatRichFloat
    , hours
    , kg
    , kilowattHours
    , km
    , massPerUnit
    , megajoules
    , minutes
    , percent
    , priceInEUR
    , qtyVariationRatio
    , qtyVariationRatioAsWastePercent
    , splitAsFloat
    , splitAsPercentage
    , squareMeters
    , surfaceMass
    , threadDensity
    , yarnSize
    )

import Area exposing (Area)
import Data.Component.Amount as Amount exposing (Amount)
import Data.Format as DataFormat
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definition)
import Data.Process as Process exposing (Process)
import Data.Split as Split exposing (Split)
import Data.Textile.Economics as Economics
import Data.Unit as Unit
import Duration exposing (Duration)
import Energy exposing (Energy)
import Html exposing (..)
import Html.Attributes exposing (..)
import Length exposing (Length)
import Mass exposing (Mass)
import Volume exposing (Volume)


formatImpactFloat : { a | decimals : Int, unit : String } -> Float -> Html msg
formatImpactFloat { decimals, unit } =
    formatRichFloat decimals unit


formatImpact : Definition -> Impacts -> Html msg
formatImpact { decimals, trigram, unit } =
    Impact.getImpact trigram
        >> Unit.impactToFloat
        >> formatRichFloat decimals unit


formatRichFloat : Int -> String -> Float -> Html msg
formatRichFloat decimals unit value =
    span []
        [ value
            |> DataFormat.formatFloat decimals
            |> text
        , span [ class "fs-unit" ] [ text "\u{202F}", text unit ]
        ]


complement : Unit.Impact -> Html msg
complement impact =
    let
        formatted =
            impact
                |> Unit.impactToFloat
                |> DataFormat.formatFloat 2
    in
    span []
        [ text <|
            if not (String.startsWith "-" formatted) then
                "+" ++ formatted

            else
                formatted
        , span [ class "fs-unit" ] [ text "\u{202F}Pts" ]
        ]


amount : Process -> Amount -> Html msg
amount { unit } amount_ =
    let
        floatAmount =
            Amount.toFloat amount_
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


yarnSize : Unit.YarnSize -> Html msg
yarnSize =
    Unit.yarnSizeInKilometers >> formatRichFloat 0 "Nm"


splitAsFloat : Int -> Split -> Html msg
splitAsFloat int value =
    Split.toFloat value
        |> DataFormat.formatFloat int
        |> text


splitAsPercentage : Int -> Split -> Html msg
splitAsPercentage decimals value =
    Split.toPercentString decimals value
        ++ "\u{202F}%"
        |> Html.text


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


qtyVariationRatio : Unit.QuantityVariationRatio -> Html msg
qtyVariationRatio ratio =
    ratio |> Unit.qtyVariationRatioToFloat |> String.fromFloat |> text


qtyVariationRatioAsWastePercent : Unit.QuantityVariationRatio -> Html msg
qtyVariationRatioAsWastePercent ratio =
    percent <| (1 - Unit.qtyVariationRatioToFloat ratio) * 100
