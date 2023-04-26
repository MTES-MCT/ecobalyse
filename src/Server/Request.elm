module Server.Request exposing (Request)

import Json.Encode as Encode


type alias Request =
    -- Notes:
    -- - `method` is ExpressJS `method` string (HTTP verb: GET, POST, etc.)
    -- - `url` is ExpressJS' request `url` string
    -- - `jsResponseHandler` is an ExpressJS response callback function
    { method : String
    , url : String
    , jsResponseHandler : Encode.Value
    }
