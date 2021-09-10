module Data.Unit exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode



-- Kilograms


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



-- Kilometers


type Km
    = Km Float


kmToFloat : Km -> Float
kmToFloat (Km value) =
    value


kmOp : (Float -> Float -> Float) -> Km -> Km -> Km
kmOp op (Km x) (Km y) =
    op x y |> Km


decodeKm : Decoder Km
decodeKm =
    Decode.map Km Decode.float


encodeKm : Km -> Encode.Value
encodeKm =
    kmToFloat >> Encode.float
