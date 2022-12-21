module Data.Food.Amount exposing
    ( Amount(..)
    , format
    , fromUnitAndFloat
    , getMass
    , multiplyBy
    , setFloat
    , toDisplayTuple
    , toStandardFloat
    )

import Data.Food.Transport as Transport exposing (TransportationQuantity)
import Energy exposing (Energy)
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity
import Views.Format as Format
import Volume exposing (Volume)


type Amount
    = EnergyInKWh Energy
    | EnergyInMJ Energy
    | Length Length
    | Mass Mass
    | Transport TransportationQuantity
    | Volume Volume


format : Mass -> Amount -> String
format totalWeight amount =
    case amount of
        Transport transport ->
            let
                -- amount is in Ton.Km for the total weight. We instead want the total number of km.
                distance =
                    Transport.getLength totalWeight transport
                        |> Length.inKilometers
            in
            Format.formatFloat 0 distance
                ++ "\u{00A0}km ("
                ++ Format.formatFloat 2 (Transport.inKgKilometers transport)
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
            Ok <| Transport (Transport.tonKilometers amount)

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
        EnergyInKWh energy ->
            EnergyInKWh (Quantity.multiplyBy ratio energy)

        EnergyInMJ energy ->
            EnergyInMJ (Quantity.multiplyBy ratio energy)

        Length length ->
            Length (Quantity.multiplyBy ratio length)

        Mass mass ->
            Mass (Quantity.multiplyBy ratio mass)

        Transport transport ->
            Transport (Quantity.multiplyBy ratio transport)

        Volume volume ->
            Volume (Quantity.multiplyBy ratio volume)


{-| Updates an Amount with a new float value, preserving its current unit.
-}
setFloat : Amount -> Float -> Amount
setFloat amount float =
    case amount of
        EnergyInKWh _ ->
            EnergyInKWh (Energy.kilowattHours float)

        EnergyInMJ _ ->
            EnergyInMJ (Energy.megajoules float)

        Length _ ->
            Length (Length.kilometers float)

        Mass _ ->
            Mass (Mass.grams float)

        Transport _ ->
            Transport (Transport.tonKilometers float)

        Volume _ ->
            Volume (Volume.liters float)


{-| A tuple used for display: we display units differently than what's used in Agribalyse.
eg: kilograms in agribalyse, grams in our UI, ton.km in agribalyse, kg.km in our UI
-}
toDisplayTuple : Amount -> ( Float, String )
toDisplayTuple amount =
    case amount of
        EnergyInKWh energy ->
            ( Energy.inKilowattHours energy, "kWh" )

        EnergyInMJ energy ->
            ( Energy.inMegajoules energy, "MJ" )

        Length length ->
            ( Length.inKilometers length, "km" )

        Mass mass ->
            ( Mass.inGrams mass, "g" )

        Transport transport ->
            ( Transport.inKgKilometers transport, "kg.km" )

        Volume volume ->
            ( Volume.inMilliliters volume, "ml" )


toStandardFloat : Amount -> Float
toStandardFloat amount =
    -- Standard here means using agribalyse units
    case amount of
        EnergyInKWh energy ->
            Energy.inKilowattHours energy

        EnergyInMJ energy ->
            Energy.inMegajoules energy

        Length length ->
            Length.inKilometers length

        Mass mass ->
            Mass.inKilograms mass

        Transport transport ->
            Transport.inTonKilometers transport

        Volume volume ->
            Volume.inLiters volume
