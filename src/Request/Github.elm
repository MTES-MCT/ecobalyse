module Request.Github exposing
    ( getChangelog
    , getReleases
    )

import Data.Env as Env
import Data.Github as Github
import Data.Session exposing (Session)
import Json.Decode as Decode
import RemoteData exposing (WebData)
import RemoteData.Http exposing (defaultConfig)


apiBaseUrl : String
apiBaseUrl =
    "https://api.github.com/repos/" ++ Env.githubRepository


config : RemoteData.Http.Config
config =
    -- drop ALL headers because Parcel's proxy messes with them
    -- see https://stackoverflow.com/a/47840149/330911
    { defaultConfig | headers = [] }


getChangelog : Session -> (WebData (List Github.Commit) -> msg) -> Cmd msg
getChangelog _ event =
    Decode.list Github.decodeCommit
        |> RemoteData.Http.getWithConfig config (apiBaseUrl ++ "/commits") event


getReleases : (WebData (List Github.Release) -> msg) -> Cmd msg
getReleases event =
    Github.decodeReleaseList
        |> RemoteData.Http.getWithConfig config (apiBaseUrl ++ "/releases") event
