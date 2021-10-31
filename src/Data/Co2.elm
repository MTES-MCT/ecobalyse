module Data.Co2 exposing (..)

import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
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


co2ePerKWh : Co2e -> Energy -> Co2e
co2ePerKWh =
    Quantity.per (Energy.kilowattHours 1) >> Quantity.at


decodeKgCo2e : Decoder Co2e
decodeKgCo2e =
    Decode.float |> Decode.andThen (kgCo2e >> Decode.succeed)


encodeKgCo2e : Co2e -> Encode.Value
encodeKgCo2e =
    inKgCo2e >> Encode.float
