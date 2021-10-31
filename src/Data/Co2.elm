module Data.Co2 exposing (..)

import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
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


co2eForMass : Co2e -> Mass -> Co2e
co2eForMass =
    -- ref: https://github.com/ianmackenzie/elm-units/blob/master/doc/CustomUnits.md
    Quantity.per Mass.kilogram >> Quantity.at


co2eForMassAndDistance : Co2e -> Length -> Mass -> Co2e
co2eForMassAndDistance cc distance =
    -- Note: Climate Change Co2 values are for transported tons per km.
    Quantity.divideBy 1000
        >> co2eForMass cc
        >> Quantity.multiplyBy (Length.inKilometers distance)


co2eForKWh : Co2e -> Energy -> Co2e
co2eForKWh =
    Quantity.per (Energy.kilowattHours 1) >> Quantity.at


ratioedCo2eForMass : ( Co2e, Co2e ) -> Float -> Mass -> Co2e
ratioedCo2eForMass ( a, b ) ratio mass =
    Quantity.sum
        [ co2eForMass a mass |> Quantity.multiplyBy ratio
        , co2eForMass b mass |> Quantity.multiplyBy (1 - ratio)
        ]


ratioedCo2eForKWh : ( Co2e, Co2e ) -> Float -> Energy -> Co2e
ratioedCo2eForKWh ( a, b ) ratio energy =
    Quantity.sum
        [ co2eForKWh a energy |> Quantity.multiplyBy ratio
        , co2eForKWh b energy |> Quantity.multiplyBy (1 - ratio)
        ]


decodeKgCo2e : Decoder Co2e
decodeKgCo2e =
    Decode.float |> Decode.andThen (kgCo2e >> Decode.succeed)


encodeKgCo2e : Co2e -> Encode.Value
encodeKgCo2e =
    inKgCo2e >> Encode.float
