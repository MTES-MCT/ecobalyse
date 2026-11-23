module Views.Format exposing
    ( amount
    , complement
    , cubicMeters
    , days
    , float
    , hours
    , impact
    , impactAsFloat
    , kilograms
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
            kilograms <| Mass.kilograms floatAmount

        Process.Liter ->
            liters <| Volume.liters floatAmount

        Process.SquareMeter ->
            squareMeters <| Area.squareMeters floatAmount

        _ ->
            String.fromFloat floatAmount
                ++ " "
                ++ Process.unitToString unit
                |> text


complement : Unit.Impact -> Html msg
complement impact_ =
    let
        formatted =
            impact_
                |> Unit.impactToFloat
                |> DataFormat.float 2
    in
    span []
        [ text <|
            if not (String.startsWith "-" formatted) then
                "+" ++ formatted

            else
                formatted
        , span [ class "fs-unit" ] [ text "\u{202F}Pts" ]
        ]


cubicMeters : Volume -> Html msg
cubicMeters =
    Volume.inCubicMeters >> float 3 "m³"


days : Duration -> Html msg
days =
    Duration.inDays >> float 0 "j"


float : Int -> String -> Float -> Html msg
float decimals unit value =
    span []
        [ value
            |> DataFormat.float decimals
            |> text
        , span [ class "fs-unit" ] [ text "\u{202F}", text unit ]
        ]


hours : Duration -> Html msg
hours =
    Duration.inHours >> float 2 "h"


impact : Definition -> Impacts -> Html msg
impact { decimals, trigram, unit } =
    Impact.getImpact trigram
        >> Unit.impactToFloat
        >> float decimals unit


impactAsFloat : { a | decimals : Int, unit : String } -> Float -> Html msg
impactAsFloat { decimals, unit } =
    float decimals unit


kilograms : Mass -> Html msg
kilograms =
    Mass.inKilograms >> float 3 "kg"


kilowattHours : Energy -> Html msg
kilowattHours =
    Energy.inKilowattHours >> float 2 "kWh"


km : Length -> Html msg
km =
    Length.inKilometers >> float 0 "km"


liters : Volume -> Html msg
liters =
    Volume.inLiters >> float 3 "L"


massPerUnit : { a | massPerUnit : Maybe Float, unit : Process.Unit } -> Html msg
massPerUnit process =
    case process.massPerUnit of
        Just value ->
            if process.unit /= Process.Kilogram then
                float 2 ("kg/" ++ Process.unitToString process.unit) value

            else
                text "N/A"

        Nothing ->
            text "N/A"


megajoules : Energy -> Html msg
megajoules =
    Energy.inMegajoules >> float 2 "MJ"


minutes : Duration -> Html msg
minutes =
    Duration.inMinutes >> float 0 "min"


percent : Float -> Html msg
percent =
    float 2 "%"


priceInEUR : Economics.Price -> Html msg
priceInEUR =
    Economics.priceToFloat >> float 2 "€"


qtyVariationRatio : Unit.QuantityVariationRatio -> Html msg
qtyVariationRatio ratio =
    ratio |> Unit.qtyVariationRatioToFloat |> String.fromFloat |> text


qtyVariationRatioAsWastePercent : Unit.QuantityVariationRatio -> Html msg
qtyVariationRatioAsWastePercent ratio =
    percent <| (1 - Unit.qtyVariationRatioToFloat ratio) * 100


splitAsFloat : Int -> Split -> Html msg
splitAsFloat int value =
    Split.toFloat value
        |> DataFormat.float int
        |> text


splitAsPercentage : Int -> Split -> Html msg
splitAsPercentage decimals value =
    Split.toPercentString decimals value
        ++ "\u{202F}%"
        |> Html.text


squareMeters : Area -> Html msg
squareMeters =
    Area.inSquareMeters >> float 3 "m²"


surfaceMass : Unit.SurfaceMass -> Html msg
surfaceMass =
    Unit.surfaceMassInGramsPerSquareMeters >> toFloat >> float 0 "g/m²"


threadDensity : Unit.ThreadDensity -> Html msg
threadDensity (Unit.ThreadDensity density_) =
    density_ |> float 0 "#/cm"


yarnSize : Unit.YarnSize -> Html msg
yarnSize =
    Unit.yarnSizeInKilometers >> float 0 "Nm"
