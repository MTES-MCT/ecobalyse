module Data.Unit exposing (..)

import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity exposing (Quantity(..))



-- Abstract Impact


type ImpactUnit
    = ImpactUnit


type alias Impact =
    Quantity Float ImpactUnit


impactFromFloat : Float -> Impact
impactFromFloat value =
    Quantity value


impactToFloat : Impact -> Float
impactToFloat (Quantity value) =
    value


decodeImpact : Decoder Impact
decodeImpact =
    Decode.float
        |> Decode.andThen (impactFromFloat >> Decode.succeed)


encodeImpact : Impact -> Encode.Value
encodeImpact =
    impactToFloat >> Encode.float



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
