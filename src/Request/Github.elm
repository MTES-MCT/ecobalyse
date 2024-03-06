module Request.Github exposing (getChangelog)

import Data.Github as Github
import Data.Session exposing (Session)
import Json.Decode as Decode
import RemoteData exposing (WebData)
import RemoteData.Http exposing (defaultConfig)


config : RemoteData.Http.Config
config =
    -- drop ALL headers because Parcel's proxy messes with them
    -- see https://stackoverflow.com/a/47840149/330911
    { defaultConfig | headers = [] }


getChangelog : Session -> (WebData (List Github.Commit) -> msg) -> Cmd msg
getChangelog { github } event =
    RemoteData.Http.getWithConfig config
        -- FIXME: specify branch
        ("https://api.github.com/repos/" ++ github.repository ++ "/commits?sha=" ++ github.branch)
        event
        (Decode.list Github.decodeCommit)
