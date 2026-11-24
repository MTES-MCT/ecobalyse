module Data.Impact exposing
    ( Impact, ImpactUnit
    , none, fromFloat
    , toFloat
    , aggregateScore
    , decoder, encode
    )

{-| A single impact score, as opposed to `Data.ImpactSet` which tallies the score across several metrics.

@docs Impact, ImpactUnit
@docs none, fromFloat
@docs toFloat
@docs aggregateScore
@docs decoder, encode

-}

import Data.Split as Split exposing (Split)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity exposing (Quantity(..))


type ImpactUnit
    = ImpactUnit Never


type alias Impact =
    Quantity Float ImpactUnit


fromFloat : Float -> Impact
fromFloat value =
    Quantity value


none : Impact
none =
    Quantity.zero


toFloat : Impact -> Float
toFloat (Quantity value) =
    value


aggregateScore : Impact -> Split -> Impact -> Impact
aggregateScore normalization weighting =
    Quantity.divideBy (toFloat normalization)
        >> Quantity.multiplyBy (Split.toFloat weighting)
        -- Raw aggregate scores like PEF are expressed in Pt (points); we want Pts (micropoints)
        >> Quantity.multiplyBy 1000000


decoder : Decoder Impact
decoder =
    Decode.map fromFloat Decode.float


encode : Impact -> Encode.Value
encode =
    toFloat >> Encode.float
