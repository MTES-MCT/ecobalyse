module Data.FwE exposing (..)

import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity exposing (Quantity(..), Rate)


type KgPe
    = KgPe


type alias Pe =
    Quantity Float KgPe


kgPe : Float -> Pe
kgPe value =
    Quantity value


inGramsPe : Pe -> Float
inGramsPe (Quantity value) =
    value * 1000


inKgPe : Pe -> Float
inKgPe (Quantity value) =
    value


inTonsPe : Pe -> Float
inTonsPe (Quantity value) =
    value / 1000


perKg : Pe -> Quantity Float (Rate KgPe Mass.Kilograms)
perKg =
    Quantity.per Mass.kilogram


perKWh : Pe -> Quantity Float (Rate KgPe Energy.Joules)
perKWh =
    Quantity.per (Energy.kilowattHours 1)


perMJ : Pe -> Quantity Float (Rate KgPe Energy.Joules)
perMJ =
    Quantity.per (Energy.megajoules 1)


forKg : Pe -> Mass -> Pe
forKg =
    -- ref: https://github.com/ianmackenzie/elm-units/blob/master/doc/CustomUnits.md
    perKg >> Quantity.at


forKgAndDistance : Pe -> Length -> Mass -> Pe
forKgAndDistance cc distance =
    -- Note: Climate Change Co2 rate is for transported tons per km.
    Quantity.divideBy 1000
        >> forKg cc
        >> Quantity.multiplyBy (Length.inKilometers distance)


forKWh : Pe -> Energy -> Pe
forKWh =
    perKWh >> Quantity.at


forMJ : Pe -> Energy -> Pe
forMJ =
    perMJ >> Quantity.at


ratioed : (Pe -> a -> Pe) -> ( Pe, Pe ) -> Float -> a -> Pe
ratioed for ( a, b ) ratio mass =
    Quantity.sum
        [ mass |> for a |> Quantity.multiplyBy ratio
        , mass |> for b |> Quantity.multiplyBy (1 - ratio)
        ]


ratioedForKg : ( Pe, Pe ) -> Float -> Mass -> Pe
ratioedForKg =
    ratioed forKg


ratioedForKWh : ( Pe, Pe ) -> Float -> Energy -> Pe
ratioedForKWh =
    ratioed forKWh


ratioedForMJ : ( Pe, Pe ) -> Float -> Energy -> Pe
ratioedForMJ =
    ratioed forMJ


decodeKgPe : Decoder Pe
decodeKgPe =
    Decode.float |> Decode.andThen (kgPe >> Decode.succeed)


encodeKgPe : Pe -> Encode.Value
encodeKgPe =
    inKgPe >> Encode.float
