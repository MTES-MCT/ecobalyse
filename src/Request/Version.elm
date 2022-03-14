module Request.Version exposing (Version(..), loadVersion, pollVersion, updateVersion)

import Json.Decode as Decode
import RemoteData exposing (WebData)
import RemoteData.Http as Http
import Time


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
                    if currentV /= v then
                        NewerVersion currentV v

                    else
                        currentVersion

                NewerVersion _ _ ->
                    currentVersion

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


pollVersion : msg -> Sub msg
pollVersion event =
    Time.every (60 * 1000) (always event)
