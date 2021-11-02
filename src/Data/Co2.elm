module Data.Co2 exposing (..)

import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity exposing (Quantity(..), Rate)


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


perKg : Co2e -> Quantity Float (Rate KgCo2e Mass.Kilograms)
perKg =
    Quantity.per Mass.kilogram


perKWh : Co2e -> Quantity Float (Rate KgCo2e Energy.Joules)
perKWh =
    Quantity.per (Energy.kilowattHours 1)


perMJ : Co2e -> Quantity Float (Rate KgCo2e Energy.Joules)
perMJ =
    Quantity.per (Energy.megajoules 1)


forKg : Co2e -> Mass -> Co2e
forKg =
    -- ref: https://github.com/ianmackenzie/elm-units/blob/master/doc/CustomUnits.md
    perKg >> Quantity.at


forKgAndDistance : Co2e -> Length -> Mass -> Co2e
forKgAndDistance cc distance =
    -- Note: Climate Change Co2 rate is for transported tons per km.
    Quantity.divideBy 1000
        >> forKg cc
        >> Quantity.multiplyBy (Length.inKilometers distance)


forKWh : Co2e -> Energy -> Co2e
forKWh =
    perKWh >> Quantity.at


forMJ : Co2e -> Energy -> Co2e
forMJ =
    perMJ >> Quantity.at


ratioed : (Co2e -> a -> Co2e) -> ( Co2e, Co2e ) -> Float -> a -> Co2e
ratioed for ( a, b ) ratio mass =
    Quantity.sum
        [ mass |> for a |> Quantity.multiplyBy ratio
        , mass |> for b |> Quantity.multiplyBy (1 - ratio)
        ]


ratioedForKg : ( Co2e, Co2e ) -> Float -> Mass -> Co2e
ratioedForKg =
    ratioed forKg


ratioedForKWh : ( Co2e, Co2e ) -> Float -> Energy -> Co2e
ratioedForKWh =
    ratioed forKWh


ratioedForMJ : ( Co2e, Co2e ) -> Float -> Energy -> Co2e
ratioedForMJ =
    ratioed forMJ


decodeKgCo2e : Decoder Co2e
decodeKgCo2e =
    Decode.float |> Decode.andThen (kgCo2e >> Decode.succeed)


encodeKgCo2e : Co2e -> Encode.Value
encodeKgCo2e =
    inKgCo2e >> Encode.float
