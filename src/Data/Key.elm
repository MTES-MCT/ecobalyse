module Data.Key exposing
    ( arrowDown
    , arrowUp
    , enter
    , escape
    )

import Json.Decode as Decode exposing (Decoder)


arrowDown : msg -> Decoder msg
arrowDown msg =
    succeedForKeyCode 40 msg


arrowUp : msg -> Decoder msg
arrowUp msg =
    succeedForKeyCode 38 msg


enter : msg -> Decoder msg
enter msg =
    succeedForKeyCode 13 msg


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
