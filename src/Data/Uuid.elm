module Data.Uuid exposing
    ( Uuid
    , decoder
    , fromString
    , generateUuid
    , toString
    )

import Json.Decode exposing (Decoder)
import Prng.Uuid as Uuid
import Random.Pcg.Extended as Random
import Task exposing (Task)
import Time


type alias Uuid =
    Uuid.Uuid


generateUuid : Task x Uuid
generateUuid =
    Time.now
        |> Task.andThen (\time -> Task.succeed (Random.initialSeed (Time.posixToMillis time) []))
        |> Task.map (\seed -> Random.step Uuid.generator seed |> Tuple.first)


decoder : Decoder Uuid
decoder =
    Uuid.decoder


fromString : String -> Maybe Uuid
fromString =
    Uuid.fromString


toString : Uuid -> String
toString =
    Uuid.toString
