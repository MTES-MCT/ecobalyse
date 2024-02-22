module Data.Split exposing
    ( Split
    , apply
    , applyToQuantity
    , complement
    , decodeFloat
    , divideBy
    , encodeFloat
    , fifteen
    , five
    , fourty
    , fromFloat
    , fromPercent
    , full
    , half
    , ninetyFive
    , quarter
    , seventy
    , seventyFive
    , tenth
    , thirty
    , toFloat
    , toFloatString
    , toPercent
    , toPercentString
    , twenty
    , zero
    )

{-|

    This module manages splits, or "shares", eg: 0.33, or 33%, or a third. Also, the precision will be up to two decimals, so the equivalent of a percent.
    0.121 or 1.119 will both be rounded to 0.12 or 12%.

-}

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity exposing (Quantity)


type Split
    = Split Int


zero : Split
zero =
    Split 0


full : Split
full =
    Split 100


five : Split
five =
    Split 5


tenth : Split
tenth =
    Split 10


fifteen : Split
fifteen =
    Split 15


twenty : Split
twenty =
    Split 20


thirty : Split
thirty =
    Split 30


fourty : Split
fourty =
    Split 40


half : Split
half =
    Split 50


seventy : Split
seventy =
    Split 70


seventyFive : Split
seventyFive =
    Split 75


ninetyFive : Split
ninetyFive =
    Split 95


quarter : Split
quarter =
    Split 25


fromFloat : Float -> Result String Split
fromFloat float =
    if float < 0 || float > 1 then
        Err ("Une part (en nombre flottant) doit être comprise entre 0 et 1 inclus (ici: " ++ String.fromFloat float ++ ")")

    else
        float
            |> (*) 100
            |> round
            |> Split
            |> Ok


fromPercent : Int -> Result String Split
fromPercent int =
    if int < 0 || int > 100 then
        Err ("Une part (en pourcentage) doit être comprise entre 0 et 100 inclus (ici: " ++ String.fromInt int ++ ")")

    else
        Ok (Split int)


toFloat : Split -> Float
toFloat (Split int) =
    Basics.toFloat int / 100


toPercent : Split -> Int
toPercent (Split int) =
    int


toFloatString : Split -> String
toFloatString =
    toFloat >> String.fromFloat


toPercentString : Split -> String
toPercentString (Split int) =
    String.fromInt int


complement : Split -> Split
complement (Split int) =
    Split (100 - int)


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
