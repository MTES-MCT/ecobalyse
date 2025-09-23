module Server.Request exposing (Request)

import Json.Encode as Encode


type alias Request =
    { -- JSON body; if no JSON body exist in the request, fallbacks to `{}`
      body : Encode.Value

    -- host retrieved from the request
    , host : String

    -- ExpressJS response callback function
    , jsResponseHandler : Encode.Value

    -- ExpressJS `method` string (HTTP verb: GET, POST, etc.)
    , method : String

    -- Raw JSON processes as a string
    , processes : String

    -- Protocol (either 'http' or 'https')
    , protocol : String

    -- ExpressJS' request `url` string, actually a path
    , url : String

    -- Version number, if any
    , version : Maybe String
    }
