module Data.Key exposing (decode, escape)

import Json.Decode as Decode exposing (Decoder)


decode : Decode.Decoder String
decode =
    Decode.field "key" Decode.string


escape : msg -> Decoder msg
escape msg =
    succeedForKeyCode 27 msg


succeedForKeyCode : Int -> msg -> Decoder msg
succeedForKeyCode key msg =
    Decode.field "keyCode" Decode.int
        |> Decode.andThen (forKeyCode key msg)


forKeyCode : Int -> msg -> Int -> Decoder msg
forKeyCode key msg keyCode =
    if keyCode == key then
        Decode.succeed msg

    else
        Decode.fail (String.fromInt keyCode)
