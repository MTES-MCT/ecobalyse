module Data.Unit exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Kg
    = Kg Float


kgToFloat : Kg -> Float
kgToFloat (Kg value) =
    value


kgOp : (Float -> Float -> Float) -> Kg -> Kg -> Kg
kgOp op (Kg x) (Kg y) =
    op x y |> Kg


decodeKg : Decoder Kg
decodeKg =
    Decode.map Kg Decode.float


encodeKg : Kg -> Encode.Value
encodeKg =
    kgToFloat >> Encode.float
