module Request.Version exposing
    ( Version(..)
    , VersionData
    , loadVersion
    , pollVersion
    , updateVersion
    )

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipe
import RemoteData exposing (WebData)
import RemoteData.Http as Http
import Time


type alias VersionData =
    { hash : String
    , tag : Maybe String
    }


type Version
    = Unknown
    | Version VersionData
    | NewerVersion


updateVersion : Version -> WebData VersionData -> Version
updateVersion currentVersion webData =
    case webData of
        RemoteData.Success v ->
            case currentVersion of
                Version currentV ->
                    if currentV.hash /= v.hash || currentV.tag /= v.tag then
                        NewerVersion

                    else
                        currentVersion

                NewerVersion ->
                    currentVersion

                _ ->
                    Version v

        _ ->
            currentVersion


versionDataDecoder : Decode.Decoder VersionData
versionDataDecoder =
    Decode.succeed VersionData
        |> Pipe.required "hash" Decode.string
        |> Pipe.optional "tag" (Decode.nullable Decode.string) Nothing


loadVersion : (WebData VersionData -> msg) -> Cmd msg
loadVersion event =
    Http.get "/version.json" event versionDataDecoder


pollVersion : msg -> Sub msg
pollVersion event =
    Time.every (60 * 1000) (always event)