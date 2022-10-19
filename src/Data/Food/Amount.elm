module Data.Food.Amount exposing
    ( Amount(..)
    , format
    , fromUnitAndFloat
    , getMass
    , kilometerToTonKilometer
    , multiplyBy
    , toDisplayTuple
    , toStandardFloat
    , tonKilometerToKilometer
    )

import Energy exposing (Energy)
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity
import Views.Format as Format
import Volume exposing (Volume)


type Amount
    = Mass Mass
    | Volume Volume
    | TonKilometer Mass
    | EnergyInKWh Energy
    | EnergyInMJ Energy
    | Length Length


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
                    toDisplayTuple amount
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
            -- WARNING: at the point this code was written, there was only ONE
            -- ingredient with a unit different than "kg", and it was for Water,
            -- with a volumic mass close enough to 1 that we decided to treat 1l = 1kg.
            Ok <| Mass (Mass.kilograms amount)

        "MJ" ->
            Ok <| EnergyInMJ (Energy.megajoules amount)

        "ton.km" ->
            Ok <| TonKilometer (Mass.metricTons amount)

        _ ->
            Err <| "Could not convert the unit " ++ unit


getMass : Amount -> Mass
getMass amount =
    case amount of
        Mass mass ->
            mass

        _ ->
            Quantity.zero


multiplyBy : Float -> Amount -> Amount
multiplyBy ratio amount =
    case amount of
        Mass mass ->
            Mass (Quantity.multiplyBy ratio mass)

        Volume volume ->
            Volume (Quantity.multiplyBy ratio volume)

        TonKilometer tonKm ->
            TonKilometer (Quantity.multiplyBy ratio tonKm)

        EnergyInKWh energy ->
            EnergyInKWh (Quantity.multiplyBy ratio energy)

        EnergyInMJ energy ->
            EnergyInMJ (Quantity.multiplyBy ratio energy)

        Length length ->
            Length (Quantity.multiplyBy ratio length)


kilometerToTonKilometer : Length -> Mass -> Mass
kilometerToTonKilometer length amount =
    -- FIXME: amount shouldn't be a Mass, but a TonKilometer
    (Mass.inMetricTons amount / Length.inKilometers length)
        |> Mass.metricTons


toDisplayTuple : Amount -> ( Float, String )
toDisplayTuple amount =
    -- A tuple used for display: we display units differently than what's used in Agribalyse
    -- eg: kilograms in agribalyse, grams in our UI, ton.km in agribalyse, kg.km in our UI
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


tonKilometerToKilometer : Mass -> Mass -> Length
tonKilometerToKilometer mass amount =
    -- FIXME: amount shouldn't be a Mass, but a TonKilometer
    (Mass.inMetricTons amount / Mass.inMetricTons mass)
        |> Length.kilometers


toStandardFloat : Amount -> Float
toStandardFloat amount =
    -- Standard here means using agribalyse units
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
