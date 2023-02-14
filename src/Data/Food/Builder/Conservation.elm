module Data.Food.Builder.Conservation exposing (..)

import Energy exposing (Joules, kilowattHours)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Quantity exposing (Quantity, Rate, rate)
import Result.Extra as RE
import Volume exposing (CubicMeters, cubicMeters, liters)


type alias Needs =
    { energy : Quantity Float (Rate Joules CubicMeters)
    , cooling : Quantity Float (Rate Joules CubicMeters)
    , water : Quantity Float (Rate CubicMeters CubicMeters)
    }


type Type
    = Ambient Needs
    | Chilled Needs
    | Frozen Needs


type alias Query =
    -- TODO remove ?
    { type_ : Type
    }


type alias Conservation =
    -- TODO remove ?
    { type_ : Type
    }


ambient : Type
ambient =
    Ambient
        { energy = rate (kilowattHours 123.08) (cubicMeters 1)
        , cooling = rate (kilowattHours 0) (cubicMeters 1)
        , water = rate (liters 561.5) (cubicMeters 1)
        }


chilled : Type
chilled =
    Chilled
        { energy = rate (kilowattHours 61.54) (cubicMeters 1)
        , cooling = rate (kilowattHours 415.38) (cubicMeters 1)
        , water = rate (liters 280.8) (cubicMeters 1)
        }


frozen : Type
frozen =
    Frozen
        { energy = rate (kilowattHours 123.08) (cubicMeters 1)
        , cooling = rate (kilowattHours 0) (cubicMeters 1)
        , water = rate (liters 561.5) (cubicMeters 1)
        }


all : List Type
all =
    [ ambient
    , chilled
    , frozen
    ]


toString : Type -> String
toString t =
    case t of
        Ambient _ ->
            "Sec"

        Chilled _ ->
            "Frais"

        Frozen _ ->
            "Surgelé"


fromString : String -> Result String Type
fromString str =
    case str of
        "Sec" ->
            Ok ambient

        "Frais" ->
            Ok chilled

        "Surgelé" ->
            Ok frozen

        _ ->
            Err "Type de conservation incorrect"


encodeQuery : Query -> Encode.Value
encodeQuery c =
    Encode.object
        [ ( "type", encodeType c.type_ )
        ]


encodeType : Type -> Encode.Value
encodeType =
    Encode.string << toString


decodeQuery : Decoder Query
decodeQuery =
    Decode.map Query
        (Decode.field "type" decodeType)


decodeType : Decoder Type
decodeType =
    Decode.string
        |> Decode.andThen (fromString >> RE.unpack Decode.fail Decode.succeed)
