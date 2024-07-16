module Data.Split exposing
    ( Split
    , apply
    , applyToQuantity
    , complement
    , decodeFloat
    , divideBy
    , encodeFloat
    , fifteen
    , fourty
    , fromFloat
    , fromPercent
    , full
    , half
    , quarter
    , sixty
    , tenth
    , thirty
    , toFloat
    , toFloatString
    , toPercent
    , toPercentString
    , twenty
    , two
    , zero
    )

{-|

    This module manages splits, or "shares", eg: 0.33, or 33%, or a third. Also, the precision will be up to two decimals, so the equivalent of a percent.
    0.121 or 1.119 will both be rounded to 0.12 or 12%.

-}

import FormatNumber
import FormatNumber.Locales exposing (Decimals(..), frenchLocale)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity exposing (Quantity)


type Split
    = Split Float


zero : Split
zero =
    Split 0


two : Split
two =
    Split 2


tenth : Split
tenth =
    Split 10


fifteen : Split
fifteen =
    Split 15


twenty : Split
twenty =
    Split 20


quarter : Split
quarter =
    Split 25


thirty : Split
thirty =
    Split 30


fourty : Split
fourty =
    Split 40


half : Split
half =
    Split 50


sixty : Split
sixty =
    Split 60


full : Split
full =
    Split 100


fromFloat : Float -> Result String Split
fromFloat float =
    if float < 0 || float > 1 then
        Err ("Une part (en nombre flottant) doit être comprise entre 0 et 1 inclus (ici: " ++ String.fromFloat float ++ ")")

    else
        float
            |> (*) 100
            |> Split
            |> Ok


fromPercent : Float -> Result String Split
fromPercent float =
    if float < 0 || float > 100 then
        Err ("Une part (en pourcentage) doit être comprise entre 0 et 100 inclus (ici: " ++ String.fromFloat float ++ ")")

    else
        Ok (Split float)


toFloat : Split -> Float
toFloat (Split float) =
    float / 100


toPercent : Split -> Float
toPercent (Split float) =
    float


toFloatString : Split -> String
toFloatString =
    toFloat >> String.fromFloat


toPercentString : Int -> Split -> String
toPercentString decimals (Split float) =
    float
        |> FormatNumber.format { frenchLocale | decimals = Exact decimals }


complement : Split -> Split
complement (Split float) =
    Split (100 - float)


apply : Float -> Split -> Float
apply input split =
    toFloat split * input


applyToQuantity : Quantity Float units -> Split -> Quantity Float units
applyToQuantity quantity split =
    Quantity.multiplyBy (toFloat split) quantity


divideBy : Float -> Split -> Float
divideBy input split =
    input / toFloat split


decodeFloat : Decoder Split
decodeFloat =
    Decode.float
        |> Decode.map fromFloat
        |> Decode.andThen
            (\result ->
                case result of
                    Ok split ->
                        Decode.succeed split

                    Err error ->
                        Decode.fail error
            )


encodeFloat : Split -> Encode.Value
encodeFloat =
    toFloat >> Encode.float
