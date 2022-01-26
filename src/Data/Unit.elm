module Data.Unit exposing
    ( Functional(..)
    , Impact
    , ImpactUnit(..)
    , Ratio(..)
    , decodeImpact
    , decodeRatio
    , encodeImpact
    , encodeRatio
    , forKWh
    , forKg
    , forKgAndDistance
    , forMJ
    , functionalToString
    , impact
    , impactPefScore
    , impactToFloat
    , ratio
    , ratioToFloat
    , ratioedForKWh
    , ratioedForKg
    , ratioedForMJ
    )

import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Length exposing (Length)
import Mass exposing (Mass)
import Quantity exposing (Quantity(..))


type alias Qty unit =
    Quantity Float unit



-- Functional unit


type Functional
    = PerDayOfWear
    | PerItem


functionalToString : Functional -> String
functionalToString unit =
    case unit of
        PerDayOfWear ->
            "Jour porté"

        PerItem ->
            "Vêtement"



-- Ratio


type Ratio
    = Ratio Float


ratio : Float -> Ratio
ratio float =
    Ratio float


ratioToFloat : Ratio -> Float
ratioToFloat (Ratio float) =
    float


decodeRatio : Decoder Ratio
decodeRatio =
    Decode.map ratio Decode.float


encodeRatio : Ratio -> Encode.Value
encodeRatio (Ratio float) =
    Encode.float float



-- Abstract Impact


type ImpactUnit
    = ImpactUnit


type alias Impact =
    Quantity Float ImpactUnit


impact : Float -> Impact
impact value =
    Quantity value


impactToFloat : Impact -> Float
impactToFloat (Quantity value) =
    value


impactPefScore : Impact -> Ratio -> Impact -> Impact
impactPefScore normalization weighting =
    Quantity.divideBy (impactToFloat normalization)
        >> Quantity.multiplyBy (ratioToFloat weighting)
        -- Raw PEF scores are expressed in Pt (points), we want mPt (millipoints)
        >> Quantity.multiplyBy 1000


decodeImpact : Decoder Impact
decodeImpact =
    Decode.float
        |> Decode.andThen (impact >> Decode.succeed)


encodeImpact : Impact -> Encode.Value
encodeImpact =
    impactToFloat >> Encode.float



-- Generic helpers


forKg : Qty unit -> Mass -> Qty unit
forKg forOneKg =
    -- ref: https://github.com/ianmackenzie/elm-units/blob/master/doc/CustomUnits.md
    forOneKg
        |> Quantity.per Mass.kilogram
        |> Quantity.at


forKgAndDistance : Qty unit -> Length -> Mass -> Qty unit
forKgAndDistance cc distance mass =
    -- Note: unit rate is for transported tons per km.
    mass
        |> Quantity.divideBy 1000
        |> forKg cc
        |> Quantity.multiplyBy (Length.inKilometers distance)


forKWh : Qty unit -> Energy -> Qty unit
forKWh forOneKWh =
    forOneKWh
        |> Quantity.per (Energy.kilowattHours 1)
        |> Quantity.at


forMJ : Qty unit -> Energy -> Qty unit
forMJ forOneMJ =
    forOneMJ
        |> Quantity.per (Energy.megajoules 1)
        |> Quantity.at


ratioed :
    (Qty unit -> a -> Qty unit)
    -> ( Qty unit, Qty unit )
    -> Ratio
    -> a
    -> Qty unit
ratioed for ( a, b ) (Ratio ratio_) input =
    Quantity.sum
        [ input |> for a |> Quantity.multiplyBy ratio_
        , input |> for b |> Quantity.multiplyBy (1 - ratio_)
        ]


ratioedForKg : ( Qty unit, Qty unit ) -> Ratio -> Mass -> Qty unit
ratioedForKg =
    ratioed forKg


ratioedForKWh : ( Qty unit, Qty unit ) -> Ratio -> Energy -> Qty unit
ratioedForKWh =
    ratioed forKWh


ratioedForMJ : ( Qty unit, Qty unit ) -> Ratio -> Energy -> Qty unit
ratioedForMJ =
    ratioed forMJ
