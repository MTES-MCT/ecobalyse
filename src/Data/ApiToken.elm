module Data.ApiToken exposing
    ( CreatedToken
    , Token
    , decodeCreatedToken
    , decodeToken
    , toString
    )

import Data.Common.DecodeUtils as DU
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP


type alias CreatedToken =
    { id : String
    , lastAccessedAt : Maybe String
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
        -- TODO: parse datetime
        |> DU.strictOptional "lastAccessedAt" Decode.string


toString : Token -> String
toString (Token token) =
    token
