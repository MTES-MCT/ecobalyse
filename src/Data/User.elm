module Data.User exposing
    ( User
    , decode
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe


type alias User =
    { email : String
    , firstname : String
    , lastname : String
    , company : String
    , cgu : Bool
    , token : String
    }


decode : Decoder User
decode =
    Decode.succeed User
        |> Pipe.required "email" Decode.string
        |> Pipe.required "first_name" Decode.string
        |> Pipe.required "last_name" Decode.string
        |> Pipe.optional "organization" Decode.string ""
        |> Pipe.required "terms_of_use" Decode.bool
        |> Pipe.required "token" Decode.string
