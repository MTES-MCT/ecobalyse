module Data.Food.Amount exposing
    ( Amount(..)
    , format
    , fromUnitAndFloat
    , toFloat
    , toTuple
    , tonKilometerToKilometer
    )

import Energy exposing (Energy)
import Length exposing (Length)
import Mass exposing (Mass)
import Views.Format as Format
import Volume exposing (Volume)


type Amount
    = Mass Mass
    | Volume Volume
    | TonKilometer Mass
    | EnergyInKWh Energy
    | EnergyInMJ Energy
    | Length Length


toTuple : Amount -> ( Float, String )
toTuple amount =
    case amount of
        Mass mass ->
            ( Mass.inGrams mass, "g" )

        Volume volume ->
            ( Volume.inMilliliters volume, "ml" )

        TonKilometer tonKm ->
            ( Mass.inKilograms tonKm, "kg.km" )

        EnergyInKWh energy ->
            ( Energy.inKilowattHours energy, "kWh" )

        EnergyInMJ energy ->
            ( Energy.inMegajoules energy, "MJ" )

        Length length ->
            ( Length.inKilometers length, "km" )


format : Mass -> Amount -> String
format totalWeight amount =
    case amount of
        TonKilometer tonKm ->
            let
                -- amount is in Ton.Km for the total weight. We instead want the total number of km.
                distanceInKm =
                    Mass.inMetricTons tonKm / Mass.inMetricTons totalWeight
            in
            Format.formatFloat 0 distanceInKm
                ++ "\u{00A0}km ("
                ++ Format.formatFloat 2 (Mass.inKilograms tonKm)
                ++ "\u{00A0}kg.km)"

        _ ->
            let
                ( quantity, unit ) =
                    toTuple amount
            in
            Format.formatFloat 2 quantity ++ "\u{00A0}" ++ unit


fromUnitAndFloat : String -> Float -> Result String Amount
fromUnitAndFloat unit amount =
    case unit of
        "m³" ->
            Ok <| Volume (Volume.cubicMeters amount)

        "kg" ->
            Ok <| Mass (Mass.kilograms amount)

        "km" ->
            Ok <| Length (Length.kilometers amount)

        "kWh" ->
            Ok <| EnergyInKWh (Energy.kilowattHours amount)

        "l" ->
            Ok <| Volume (Volume.liters amount)

        "MJ" ->
            Ok <| EnergyInMJ (Energy.megajoules amount)

        "t/km" ->
            Ok <| Mass (Mass.metricTons amount)

        _ ->
            Err <| "Could not convert the unit " ++ unit


toFloat : Amount -> Float
toFloat amount =
    case amount of
        Mass mass ->
            Mass.inKilograms mass

        Volume volume ->
            Volume.inLiters volume

        TonKilometer tonKm ->
            Mass.inMetricTons tonKm

        EnergyInKWh energy ->
            Energy.inKilowattHours energy

        EnergyInMJ energy ->
            Energy.inMegajoules energy

        Length length ->
            Length.inKilometers length


tonKilometerToKilometer : Mass -> Amount -> Result String Length
tonKilometerToKilometer mass amount =
    case amount of
        TonKilometer tonKm ->
            (Mass.inMetricTons tonKm / Mass.inMetricTons mass)
                |> Length.kilometers
                |> Ok

        _ ->
            Err "The amount provided isn't in TonKilometer"
