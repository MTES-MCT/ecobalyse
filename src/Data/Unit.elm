module Data.Unit exposing (..)

import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity exposing (Quantity(..))



-- Climate change (Co2)


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


decodeKgCo2e : Decoder Co2e
decodeKgCo2e =
    Decode.float |> Decode.andThen (kgCo2e >> Decode.succeed)


encodeKgCo2e : Co2e -> Encode.Value
encodeKgCo2e =
    inKgCo2e >> Encode.float



-- Freshwater eutrophication (P)


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


decodeKgPe : Decoder Pe
decodeKgPe =
    Decode.float |> Decode.andThen (kgPe >> Decode.succeed)


encodeKgPe : Pe -> Encode.Value
encodeKgPe =
    inKgPe >> Encode.float



-- Generic helpers


forKg : Quantity Float unit -> Mass -> Quantity Float unit
forKg forOneKg =
    -- ref: https://github.com/ianmackenzie/elm-units/blob/master/doc/CustomUnits.md
    forOneKg
        |> Quantity.per Mass.kilogram
        |> Quantity.at


forKgAndDistance : Quantity Float unit -> Length -> Mass -> Quantity Float unit
forKgAndDistance cc distance mass =
    -- Note: unit rate is for transported tons per km.
    mass
        |> Quantity.divideBy 1000
        |> forKg cc
        |> Quantity.multiplyBy (Length.inKilometers distance)


forKWh : Quantity Float unit -> Energy -> Quantity Float unit
forKWh forOneKWh =
    forOneKWh
        |> Quantity.per (Energy.kilowattHours 1)
        |> Quantity.at


forMJ : Quantity Float unit -> Energy -> Quantity Float unit
forMJ forOneMJ =
    forOneMJ
        |> Quantity.per (Energy.megajoules 1)
        |> Quantity.at


ratioed :
    (Quantity Float unit -> a -> Quantity Float unit)
    -> ( Quantity Float unit, Quantity Float unit )
    -> Float
    -> a
    -> Quantity Float unit
ratioed for ( a, b ) ratio input =
    Quantity.sum
        [ input |> for a |> Quantity.multiplyBy ratio
        , input |> for b |> Quantity.multiplyBy (1 - ratio)
        ]


ratioedForKg : ( Quantity Float unit, Quantity Float unit ) -> Float -> Mass -> Quantity Float unit
ratioedForKg =
    ratioed forKg


ratioedForKWh : ( Quantity Float unit, Quantity Float unit ) -> Float -> Energy -> Quantity Float unit
ratioedForKWh =
    ratioed forKWh


ratioedForMJ : ( Quantity Float unit, Quantity Float unit ) -> Float -> Energy -> Quantity Float unit
ratioedForMJ =
    ratioed forMJ
