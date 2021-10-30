module Data.Co2 exposing (..)

import Energy exposing (Energy)
import Mass exposing (Mass)
import Quantity exposing (Quantity(..))


type KgCo2e
    = KgCo2e


type alias Co2e =
    Quantity Float KgCo2e


kgCo2e : Float -> Co2e
kgCo2e value =
    Quantity value


inGramsCo2e : Co2e -> Float
inGramsCo2e (Quantity value) =
    value * 1000


inKgCo2e : Co2e -> Float
inKgCo2e (Quantity value) =
    value


inTonsCo2e : Co2e -> Float
inTonsCo2e (Quantity value) =
    value / 1000


co2ePerMass : Co2e -> Mass -> Co2e
co2ePerMass cc =
    -- ref: https://github.com/ianmackenzie/elm-units/blob/master/doc/CustomUnits.md
    -- > Mass.kilograms 0.170 |> Co2.co2ePerMass (Co2.kgCo2e 0.2) |> Co2.inKgCo2e
    -- 0.034 : Float
    -- > Mass.grams 170 |> Co2.co2ePerMass (Co2.kgCo2e 0.2) |> Co2.inKgCo2e
    -- 0.034 : Float
    -- > Mass.kilograms 0.170 |> Co2.co2ePerMass (Co2.kgCo2e 0.2)|>Co2.inGramsCo2e
    -- 34 : Float
    Quantity.at (Quantity.per Mass.kilogram cc)


co2ePerKWh : Co2e -> Energy -> Co2e
co2ePerKWh cc =
    Quantity.at (Quantity.per (Energy.kilowattHours 1) cc)
