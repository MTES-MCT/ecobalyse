module Server.Request exposing (..)

import Json.Encode as Encode


type alias Request =
    -- Notes:
    -- - `method` is ExpressJS `method` string (HTTP verb: GET, POST, etc.)
    -- - `url` is ExpressJS `url` string
    --   string params, which uses the qs package under the hood:
    --   https://www.npmjs.com/package/qs
    -- - `jsResponseHandler` is an ExpressJS response callback function
    { method : String
    , url : String
    , jsResponseHandler : Encode.Value
    }
