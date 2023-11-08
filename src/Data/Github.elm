module Data.Github exposing (Commit, decodeCommit)

import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Time exposing (Posix)


type alias Commit =
    { sha : String
    , message : String
    , date : Posix
    , authorName : String
    , authorLogin : String
    , authorAvatar : Maybe String
    }


decodeCommit : Decoder Commit
decodeCommit =
    Decode.succeed Commit
        |> Pipe.requiredAt [ "sha" ] Decode.string
        |> Pipe.requiredAt [ "commit", "message" ] Decode.string
        |> Pipe.requiredAt [ "commit", "author", "date" ] Iso8601.decoder
        |> Pipe.requiredAt [ "commit", "author", "name" ] Decode.string
        |> Pipe.optionalAt [ "author", "login" ] Decode.string "Ecobalyse"
        |> Pipe.optionalAt [ "author", "avatar_url" ] (Decode.maybe Decode.string) Nothing
