module Request.Version exposing (loadVersion)

import Json.Decode as Decode
import RemoteData exposing (WebData)
import RemoteData.Http as Http


type Version
    = Unknown
    | Version String
    | NewerVersion String String


updateVersion : Version -> WebData String -> Version
updateVersion currentVersion webData =
    case webData of
        RemoteData.Success v ->
            case currentVersion of
                Version currentV ->
                    NewerVersion currentV v

                _ ->
                    Version v

        _ ->
            Unknown


hashDecoder : Decode.Decoder String
hashDecoder =
    Decode.field "hash" Decode.string


loadVersion : (WebData String -> msg) -> Cmd msg
loadVersion event =
    Http.get "/version.json" event hashDecoder
