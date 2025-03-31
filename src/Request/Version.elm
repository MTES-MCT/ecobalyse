module Request.Version exposing
    ( Version(..)
    , VersionData
    , decodeVersionData
    , encodeVersionData
    , getTag
    , is
    , loadVersion
    , pollVersion
    , toMaybe
    , updateVersion
    )

import Data.Common.DecodeUtils as DU
import Data.Github as Github
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import RemoteData exposing (WebData)
import RemoteData.Http as Http
import Time


type alias VersionData =
    { hash : String
    , tag : Maybe String
    }


type Version
    = NewerVersion
    | Unknown
    | Version VersionData


updateVersion : Version -> WebData VersionData -> Version
updateVersion currentVersion webData =
    case webData of
        RemoteData.Success v ->
            case currentVersion of
                NewerVersion ->
                    currentVersion

                Version currentV ->
                    if currentV.hash /= v.hash || currentV.tag /= v.tag then
                        NewerVersion

                    else
                        currentVersion

                _ ->
                    Version v

        _ ->
            currentVersion


decodeVersionData : Decode.Decoder VersionData
decodeVersionData =
    Decode.succeed VersionData
        |> Pipe.required "hash" Decode.string
        |> DU.strictOptional "tag" Decode.string


encodeVersionData : VersionData -> Encode.Value
encodeVersionData v =
    Encode.object
        [ ( "hash", Encode.string v.hash )
        , ( "tag", v.tag |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        ]


is : Github.Release -> Version -> Bool
is release version =
    case version of
        Version { hash, tag } ->
            hash == release.hash || tag == Just release.tag

        _ ->
            False


getTag : Version -> Maybe String
getTag version =
    case version of
        Version { tag } ->
            tag

        _ ->
            Nothing


loadVersion : (WebData VersionData -> msg) -> Cmd msg
loadVersion event =
    Http.get "version.json" event decodeVersionData


pollVersion : msg -> Sub msg
pollVersion event =
    Time.every (60 * 1000) (always event)


toMaybe : Version -> Maybe VersionData
toMaybe version =
    case version of
        Version data ->
            Just data

        _ ->
            Nothing
