module Server.Request exposing (Request)

import Json.Encode as Encode


type alias Request =
    -- Notes:
    -- - `method` is ExpressJS `method` string (HTTP verb: GET, POST, etc.)
    -- - `url` is ExpressJS' request `url` string
    -- - `body` is the JSON body; if no JSON body exist in the request, fallbacks to `{}`
    -- - `jsResponseHandler` is an ExpressJS response callback function
    { method : String
    , url : String
    , body : Encode.Value
    , jsResponseHandler : Encode.Value
    }
