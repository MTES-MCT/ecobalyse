module Data.Split exposing
    ( Split
    , add
    , apply
    , asFloat
    , asPercent
    , complement
    , decode
    , encode
    , fourty
    , fromFloat
    , fromPercent
    , full
    , half
    , quarter
    , tenth
    , toFloatString
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


type Split
    = Split Int


zero : Split
zero =
    Split 0


full : Split
full =
    Split 100


tenth : Split
tenth =
    Split 10


twenty : Split
twenty =
    Split 20


fourty : Split
fourty =
    Split 40


half : Split
half =
    Split 50


quarter : Split
quarter =
    Split 25


fromFloat : Float -> Result String Split
fromFloat float =
    if float < 0 || float > 1 then
        Err ("Une part (en flottant) doit être comprise entre 0 et 1 inclus (ici: " ++ String.fromFloat float ++ ")")

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


asFloat : Split -> Float
asFloat (Split int) =
    toFloat int / 100


asPercent : Split -> Int
asPercent (Split int) =
    int


toFloatString : Split -> String
toFloatString =
    asFloat >> String.fromFloat


toPercentString : Split -> String
toPercentString (Split int) =
    String.fromInt int


add : Split -> Split -> Result String Split
add (Split a) (Split b) =
    let
        total =
            a + b
    in
    if total < 0 || total > 100 then
        Err "L'addition de plusieurs part doit être entre comprise entre 0 et 100%"

    else
        Ok (Split total)


complement : Split -> Split
complement (Split int) =
    Split (100 - int)


apply : Float -> Split -> Float
apply input split =
    split
        |> asFloat
        |> (*) input


decode : Decoder Split
decode =
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


encode : Split -> Encode.Value
encode percent =
    percent
        |> asFloat
        |> Encode.float
