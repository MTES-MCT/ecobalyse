module Data.Impact exposing
    ( Impact
    , ImpactUnit
    , decodeAndNegateImpact
    , decodeImpact
    , encodeImpact
    , impact
    , impactAggregateScore
    , impactToFloat
    , noImpacts
    )

import Data.Split as Split exposing (Split)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity exposing (Quantity(..))


type ImpactUnit
    = ImpactUnit Never


type alias Impact =
    Quantity Float ImpactUnit


impact : Float -> Impact
impact value =
    Quantity value


noImpacts : Impact
noImpacts =
    impact 0


impactToFloat : Impact -> Float
impactToFloat (Quantity value) =
    value


impactAggregateScore : Impact -> Split -> Impact -> Impact
impactAggregateScore normalization weighting =
    Quantity.divideBy (impactToFloat normalization)
        >> Quantity.multiplyBy (Split.toFloat weighting)
        -- Raw aggregate scores like PEF are expressed in Pt (points); we want Pts (micropoints)
        >> Quantity.multiplyBy 1000000


decodeAndNegateImpact : Decoder Impact
decodeAndNegateImpact =
    Decode.map Quantity.negate decodeImpact


decodeImpact : Decoder Impact
decodeImpact =
    Decode.map impact Decode.float


encodeImpact : Impact -> Encode.Value
encodeImpact =
    impactToFloat >> Encode.float
