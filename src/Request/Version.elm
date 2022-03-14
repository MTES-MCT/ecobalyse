module Request.Version exposing (loadVersion)

import Json.Decode as Decode
import RemoteData exposing (WebData)
import RemoteData.Http as Http


hashDecoder : Decode.Decoder String
hashDecoder =
    Decode.field "hash" Decode.string


loadVersion : (WebData String -> msg) -> Cmd msg
loadVersion event =
    Http.get "/version.json" event hashDecoder
