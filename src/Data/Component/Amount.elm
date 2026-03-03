module Data.Component.Amount exposing
    ( Amount
    , decode
    , fromFloat
    , fromString
    , map
    , toFloat
    , toFrenchString
    , toString
    )

import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Json.Decode as Decode exposing (Decoder)


{-| An abstract float amount representation
-}
type Amount
    = Amount Float


decode : Decoder Amount
decode =
    Decode.map Amount Decode.float


fromFloat : Float -> Amount
fromFloat =
    Amount


fromString : String -> Maybe Amount
fromString =
    String.toFloat >> Maybe.map Amount


map : (Float -> Float) -> Amount -> Amount
map fn (Amount float) =
    Amount <| fn float


toFloat : Amount -> Float
toFloat (Amount float) =
    float


toFrenchString : Int -> Amount -> String
toFrenchString decimals =
    toFloat >> FormatNumber.format { frenchLocale | decimals = Exact decimals }


toString : Amount -> String
toString =
    toFloat >> String.fromFloat
