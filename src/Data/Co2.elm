module Data.Co2 exposing (..)

import Mass exposing (Mass)
import Quantity exposing (Quantity(..), Rate)


type KgCo2e
    = KgCo2e


type alias Co2 =
    Quantity Float KgCo2e


type alias ClimateChange =
    Quantity Float (Rate KgCo2e Mass.Kilograms)


kgCo2e : Float -> Co2
kgCo2e value =
    Quantity value


inGramsCo2e : Quantity Float KgCo2e -> Float
inGramsCo2e (Quantity value) =
    value * 1000


inKgCo2e : Quantity Float KgCo2e -> Float
inKgCo2e (Quantity value) =
    value


inTonsCo2e : Quantity Float KgCo2e -> Float
inTonsCo2e (Quantity value) =
    value / 1000


climateChange : Quantity Float KgCo2e -> ClimateChange
climateChange =
    Quantity.per Mass.kilogram


co2ePerMass : ClimateChange -> Mass -> Quantity Float KgCo2e
co2ePerMass cc =
    -- ref: https://github.com/ianmackenzie/elm-units/blob/master/doc/CustomUnits.md
    -- > Mass.kilograms 0.170 |> Co2.co2ePerMass (Co2.kgCo2e 0.2) |> Co2.inKgCo2e
    -- 0.034 : Float
    -- > Mass.grams 170 |> Co2.co2ePerMass (Co2.kgCo2e 0.2) |> Co2.inKgCo2e
    -- 0.034 : Float
    -- > Mass.kilograms 0.170 |> Co2.co2ePerMass (Co2.kgCo2e 0.2)|>Co2.inGramsCo2e
    -- 34 : Float
    Quantity.at cc
