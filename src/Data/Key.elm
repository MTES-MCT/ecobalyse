module Data.Key exposing (escape)

import Json.Decode as Decode exposing (Decoder)


escape : msg -> Decoder msg
escape msg =
    succeedForKeyCode 27 msg


forKeyCode : Int -> msg -> Int -> Decoder msg
forKeyCode key msg keyCode =
    if keyCode == key then
        Decode.succeed msg

    else
        Decode.fail (String.fromInt keyCode)


succeedForKeyCode : Int -> msg -> Decoder msg
succeedForKeyCode key msg =
    Decode.field "keyCode" Decode.int
        |> Decode.andThen (forKeyCode key msg)
