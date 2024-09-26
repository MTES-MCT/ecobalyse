module Server.Request exposing (Request)

import Json.Encode as Encode
import Static.Json as StaticJson


type alias Request =
    -- Notes:
    -- - `method` is ExpressJS `method` string (HTTP verb: GET, POST, etc.)
    -- - `url` is ExpressJS' request `url` string
    -- - `body` is the JSON body; if no JSON body exist in the request, fallbacks to `{}`
    -- - `jsResponseHandler` is an ExpressJS response callback function
    { body : Encode.Value
    , jsResponseHandler : Encode.Value
    , method : String
    , processes : StaticJson.RawJsonProcesses
    , url : String
    }
