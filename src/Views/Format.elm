module Views.Format exposing
    ( amount
    , complement
    , cubicMeters
    , days
    , hours
    , impact
    , impactAsFloat
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
    , richFloat
    , splitAsFloat
    , splitAsPercentage
    , squareMeters
    , surfaceMass
    , threadDensity
    , yarnSize
    )

import Area exposing (Area)
import Data.Component.Amount as Amount exposing (Amount)
import Data.Format as Format
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


complement : Unit.Impact -> Html msg
complement impact_ =
    let
        formatted =
            impact_
                |> Unit.impactToFloat
                |> Format.float 2
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
    Volume.inCubicMeters >> richFloat 3 "m³"


days : Duration -> Html msg
days =
    Duration.inDays >> richFloat 0 "j"


hours : Duration -> Html msg
hours =
    Duration.inHours >> richFloat 2 "h"


impact : Definition -> Impacts -> Html msg
impact { decimals, trigram, unit } =
    Impact.getImpact trigram
        >> Unit.impactToFloat
        >> richFloat decimals unit


impactAsFloat : { a | decimals : Int, unit : String } -> Float -> Html msg
impactAsFloat { decimals, unit } =
    richFloat decimals unit


kg : Mass -> Html msg
kg =
    Mass.inKilograms >> richFloat 3 "kg"


kilowattHours : Energy -> Html msg
kilowattHours =
    Energy.inKilowattHours >> richFloat 2 "kWh"


km : Length -> Html msg
km =
    Length.inKilometers >> richFloat 0 "km"


liters : Volume -> Html msg
liters =
    Volume.inLiters >> richFloat 3 "L"


massPerUnit : { a | massPerUnit : Maybe Float, unit : Process.Unit } -> Html msg
massPerUnit process =
    case process.massPerUnit of
        Just value ->
            if process.unit /= Process.Kilogram then
                richFloat 2 ("kg/" ++ Process.unitToString process.unit) value

            else
                text "N/A"

        Nothing ->
            text "N/A"


megajoules : Energy -> Html msg
megajoules =
    Energy.inMegajoules >> richFloat 2 "MJ"


minutes : Duration -> Html msg
minutes =
    Duration.inMinutes >> richFloat 0 "min"


percent : Float -> Html msg
percent =
    richFloat 2 "%"


priceInEUR : Economics.Price -> Html msg
priceInEUR =
    Economics.priceToFloat >> richFloat 2 "€"


qtyVariationRatio : Unit.QuantityVariationRatio -> Html msg
qtyVariationRatio ratio =
    ratio |> Unit.qtyVariationRatioToFloat |> String.fromFloat |> text


qtyVariationRatioAsWastePercent : Unit.QuantityVariationRatio -> Html msg
qtyVariationRatioAsWastePercent ratio =
    percent <| (1 - Unit.qtyVariationRatioToFloat ratio) * 100


richFloat : Int -> String -> Float -> Html msg
richFloat decimals unit value =
    span []
        [ value
            |> Format.float decimals
            |> text
        , span [ class "fs-unit" ] [ text "\u{202F}", text unit ]
        ]


splitAsFloat : Int -> Split -> Html msg
splitAsFloat int value =
    Split.toFloat value
        |> Format.float int
        |> text


splitAsPercentage : Int -> Split -> Html msg
splitAsPercentage decimals value =
    Split.toPercentString decimals value
        ++ "\u{202F}%"
        |> Html.text


squareMeters : Area -> Html msg
squareMeters =
    Area.inSquareMeters >> richFloat 3 "m²"


surfaceMass : Unit.SurfaceMass -> Html msg
surfaceMass =
    Unit.surfaceMassInGramsPerSquareMeters >> toFloat >> richFloat 0 "g/m²"


threadDensity : Unit.ThreadDensity -> Html msg
threadDensity (Unit.ThreadDensity density_) =
    density_ |> richFloat 0 "#/cm"


yarnSize : Unit.YarnSize -> Html msg
yarnSize =
    Unit.yarnSizeInKilometers >> richFloat 0 "Nm"
