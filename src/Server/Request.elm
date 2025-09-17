module Server.Request exposing (Request)

import Json.Encode as Encode


type alias Request =
    { -- JSON body; if no JSON body exist in the request, fallbacks to `{}`
      body : Encode.Value

    -- ExpressJS response callback function
    , jsResponseHandler : Encode.Value

    -- ExpressJS `method` string (HTTP verb: GET, POST, etc.)
    , method : String

    -- Raw JSON processes as a string
    , processes : String

    -- ExpressJS' request `url` string
    , url : String

    -- host retrieved from the request
    , host : String
    }
