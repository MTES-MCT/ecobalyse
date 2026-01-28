module Request.Version exposing
    ( Version(..)
    , VersionData
    , decodeData
    , encodeData
    , getTag
    , loadVersion
    , pollVersion
    , toMaybe
    , update
    )

import Data.Common.DecodeUtils as DU
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import RemoteData exposing (WebData)
import RemoteData.Http as Http
import Time


type alias CurrentData =
    VersionData


type alias NewData =
    VersionData


type Version
    = NewerVersion CurrentData NewData
    | Unknown
    | Version VersionData


type alias VersionData =
    { hash : String
    , tag : Maybe String
    }


decodeData : Decode.Decoder VersionData
decodeData =
    Decode.succeed VersionData
        |> Pipe.required "hash" Decode.string
        |> DU.strictOptional "tag" Decode.string


encodeData : VersionData -> Encode.Value
encodeData v =
    Encode.object
        [ ( "hash", Encode.string v.hash )
        , ( "tag", v.tag |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        ]


getTag : Version -> Maybe String
getTag version =
    case version of
        Version { tag } ->
            tag

        _ ->
            Nothing


loadVersion : (WebData VersionData -> msg) -> Cmd msg
loadVersion event =
    Http.get "version.json" event decodeData


pollVersion : Int -> msg -> Sub msg
pollVersion versionPollSeconds =
    always >> Time.every (toFloat versionPollSeconds * 1000)


toMaybe : Version -> Maybe VersionData
toMaybe version =
    case version of
        NewerVersion data _ ->
            Just data

        Version data ->
            Just data

        _ ->
            Nothing


update : Version -> WebData VersionData -> Version
update currentVersion webData =
    case webData of
        RemoteData.Success freshest ->
            case currentVersion of
                NewerVersion _ _ ->
                    currentVersion

                Unknown ->
                    Version freshest

                Version current ->
                    if current.hash /= freshest.hash || current.tag /= freshest.tag then
                        NewerVersion current freshest

                    else
                        currentVersion

        _ ->
            currentVersion
