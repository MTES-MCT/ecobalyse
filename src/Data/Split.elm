module Data.Split exposing
    ( Split
    , apply
    , applyToQuantity
    , assemble
    , complement
    , decodeFloat
    , decodePercent
    , divideBy
    , encodeFloat
    , fifteen
    , fourty
    , fromBoundedFloat
    , fromFloat
    , fromPercent
    , full
    , half
    , quarter
    , sixty
    , tenth
    , third
    , thirty
    , toFloat
    , toFloatString
    , toPercent
    , toPercentString
    , twenty
    , two
    , zero
    )

{-| This module manages splits, or "shares", eg: 0.33, or 33%, or a third. Also, the precision will be up to two decimals, so the equivalent of a percent.

0.121 or 1.119 will both be rounded to 0.12 or 12%.

-}

import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Quantity exposing (Quantity)


type Split
    = Split Float


zero : Split
zero =
    Split 0


two : Split
two =
    Split 0.02


tenth : Split
tenth =
    Split 0.1


fifteen : Split
fifteen =
    Split 0.15


twenty : Split
twenty =
    Split 0.2


quarter : Split
quarter =
    Split 0.25


thirty : Split
thirty =
    Split 0.3


third : Split
third =
    Split 0.33


fourty : Split
fourty =
    Split 0.4


half : Split
half =
    Split 0.5


sixty : Split
sixty =
    Split 0.6


full : Split
full =
    Split 1


fromFloat : Float -> Result String Split
fromFloat =
    fromBoundedFloat 0 1


fromBoundedFloat : Float -> Float -> Float -> Result String Split
fromBoundedFloat min max float =
    if float < min || float > max then
        Err <|
            ("Cette proportion doit être comprise entre "
                ++ String.fromFloat min
                ++ " et "
                ++ String.fromFloat max
                ++ " inclus (ici\u{202F}: "
                ++ String.fromFloat float
                ++ ")"
            )

    else
        Ok <| Split float


fromPercent : Float -> Result String Split
fromPercent percentFloat =
    if percentFloat < 0 || percentFloat > 100 then
        Err ("Une part (en pourcentage) doit être comprise entre 0 et 100 inclus (ici\u{202F}: " ++ String.fromFloat percentFloat ++ ")")

    else
        Ok (Split (percentFloat / 100))


toFloat : Split -> Float
toFloat (Split float) =
    float


toPercent : Split -> Float
toPercent (Split float) =
    float * 100


toFloatString : Split -> String
toFloatString =
    toFloat >> String.fromFloat


toPercentString : Int -> Split -> String
toPercentString decimals =
    toPercent >> FormatNumber.format { frenchLocale | decimals = Exact decimals }


complement : Split -> Split
complement (Split float) =
    Split (1 - float)


apply : Float -> Split -> Float
apply input split =
    toFloat split * input


applyToQuantity : Quantity Float units -> Split -> Quantity Float units
applyToQuantity quantity split =
    Quantity.multiplyBy (toFloat split) quantity


{-| Sums splits, fails if total is not 100%
-}
assemble : List Split -> Result String Split
assemble splits =
    let
        total =
            splits |> List.map toFloat |> List.sum
    in
    -- Note: taking care of float number rounding precision errors https://en.wikipedia.org/wiki/Round-off_error
    if not (List.member total [ 1, 0.6 + 0.3 + 0.1 ]) then
        Err <|
            "La somme des parts ne doit pas excéder 100%; ici\u{00A0}: "
                ++ String.fromFloat (total * 100)
                ++ "%"

    else
        Ok (Split total)


divideBy : Float -> Split -> Float
divideBy input split =
    input / toFloat split


decodeFloat : Decoder Split
decodeFloat =
    Decode.float
        |> Decode.andThen (fromFloat >> DE.fromResult)


decodePercent : Decoder Split
decodePercent =
    Decode.float
        |> Decode.andThen (fromPercent >> DE.fromResult)


encodeFloat : Split -> Encode.Value
encodeFloat =
    toFloat >> Encode.float
