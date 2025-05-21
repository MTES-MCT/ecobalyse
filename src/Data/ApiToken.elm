module Data.ApiToken exposing
    ( CreatedToken
    , Token
    , decodeCreatedToken
    , decodeToken
    , toString
    )

import Data.Common.DecodeUtils as DU
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as JDP
import Time exposing (Posix)


type alias CreatedToken =
    { id : String
    , lastAccessedAt : Maybe Posix
    }


type Token
    = Token String


decodeToken : Decoder Token
decodeToken =
    Decode.map Token Decode.string


decodeCreatedToken : Decoder CreatedToken
decodeCreatedToken =
    Decode.succeed CreatedToken
        |> JDP.required "id" Decode.string
        |> DU.strictOptional "lastAccessedAt" DE.datetime


toString : Token -> String
toString (Token token) =
    token
