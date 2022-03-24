module Request.Version exposing
    ( Version(..)
    , loadVersion
    , pollVersion
    , toString
    , updateVersion
    )

import Json.Decode as Decode
import RemoteData exposing (WebData)
import RemoteData.Http as Http
import Time


type Version
    = Unknown
    | Version String
    | NewerVersion


toString : Version -> Maybe String
toString version =
    case version of
        Version string ->
            Just string

        _ ->
            Nothing


updateVersion : Version -> WebData String -> Version
updateVersion currentVersion webData =
    case webData of
        RemoteData.Success v ->
            case currentVersion of
                Version currentV ->
                    if currentV /= v then
                        NewerVersion

                    else
                        currentVersion

                NewerVersion ->
                    currentVersion

                _ ->
                    Version v

        _ ->
            currentVersion


hashDecoder : Decode.Decoder String
hashDecoder =
    Decode.field "hash" Decode.string


loadVersion : (WebData String -> msg) -> Cmd msg
loadVersion event =
    Http.get "/version.json" event hashDecoder


pollVersion : msg -> Sub msg
pollVersion event =
    Time.every (60 * 1000) (always event)
