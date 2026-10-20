module Data.Component.Amount exposing
    ( Amount
    , applyRatio
    , decode
    , divideBy
    , encode
    , fromFloat
    , fromString
    , multiplyBy
    , toFloat
    , toString
    , validate
    )

import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


{-| An abstract float amount representation
-}
type Amount
    = Amount Float


applyRatio : Unit.Ratio -> Amount -> Amount
applyRatio ratio (Amount amount) =
    Amount (amount * Unit.ratioToFloat ratio)


decode : Decoder Amount
decode =
    Decode.map Amount Decode.float


divideBy : Float -> Amount -> Amount
divideBy float (Amount amount) =
    Amount (amount / float)


encode : Amount -> Encode.Value
encode =
    toFloat >> Encode.float


fromFloat : Float -> Amount
fromFloat =
    Amount


fromString : String -> Maybe Amount
fromString =
    String.toFloat >> Maybe.map Amount


multiplyBy : Float -> Amount -> Amount
multiplyBy float (Amount amount) =
    Amount (amount * float)


toFloat : Amount -> Float
toFloat (Amount float) =
    float


toString : Amount -> String
toString =
    toFloat >> String.fromFloat


validate : Amount -> Result String Amount
validate (Amount float) =
    if float < 0 then
        Err "Une quantité doit être supérieure ou égale à zéro"

    else
        Ok (Amount float)
