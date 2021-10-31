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


co2ePerMass : Co2e -> Mass -> Co2e
co2ePerMass =
    -- ref: https://github.com/ianmackenzie/elm-units/blob/master/doc/CustomUnits.md
    Quantity.per Mass.kilogram >> Quantity.at


co2ePerKmPerMass : Co2e -> Length -> Mass -> Co2e
co2ePerKmPerMass cc distance mass =
    -- mass should be in tons
    mass
        |> Quantity.divideBy 1000
        |> co2ePerMass cc
        |> Quantity.multiplyBy (Length.inKilometers distance)


co2ePerKWh : Co2e -> Energy -> Co2e
co2ePerKWh =
    Quantity.per (Energy.kilowattHours 1) >> Quantity.at


ratioedCo2ePerMass : ( Co2e, Co2e ) -> Float -> Mass -> Co2e
ratioedCo2ePerMass ( a, b ) ratio mass =
    Quantity.sum
        [ co2ePerMass a mass |> Quantity.multiplyBy ratio
        , co2ePerMass b mass |> Quantity.multiplyBy (1 - ratio)
        ]


ratioedCo2ePerKWh : ( Co2e, Co2e ) -> Float -> Energy -> Co2e
ratioedCo2ePerKWh ( a, b ) ratio energy =
    Quantity.sum
        [ co2ePerKWh a energy |> Quantity.multiplyBy ratio
        , co2ePerKWh b energy |> Quantity.multiplyBy (1 - ratio)
        ]


decodeKgCo2e : Decoder Co2e
decodeKgCo2e =
    Decode.float |> Decode.andThen (kgCo2e >> Decode.succeed)


encodeKgCo2e : Co2e -> Encode.Value
encodeKgCo2e =
    inKgCo2e >> Encode.float
