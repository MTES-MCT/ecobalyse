module Server.Request exposing (Request)

import Json.Decode as Decode
import Json.Encode as Encode


type alias Request =
    -- Notes:
    -- - `method` is ExpressJS `method` string (HTTP verb: GET, POST, etc.)
    -- - `url` is ExpressJS' request `url` string
    -- - `jsResponseHandler` is an ExpressJS response callback function
    { method : String
    , url : String
    , body : Decode.Value
    , jsResponseHandler : Encode.Value
    }
