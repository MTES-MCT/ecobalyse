module Data.Github exposing (..)

import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Time exposing (Posix)


type alias Commit =
    { sha : String
    , message : String
    , date : Posix
    , authorName : String
    , authorLogin : String
    , authorAvatar : String
    }


decodeCommit : Decoder Commit
decodeCommit =
    Decode.map6 Commit
        (Decode.at [ "sha" ] Decode.string)
        (Decode.at [ "commit", "message" ] Decode.string)
        (Decode.at [ "commit", "author", "date" ] Iso8601.decoder)
        (Decode.at [ "commit", "author", "name" ] Decode.string)
        (Decode.at [ "author", "login" ] Decode.string)
        (Decode.at [ "author", "avatar_url" ] Decode.string)
