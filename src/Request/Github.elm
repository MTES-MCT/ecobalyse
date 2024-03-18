module Request.Github exposing
    ( createFoodExamplesPR
    , createTextileExamplesPR
    , getChangelog
    )

import Data.Food.Query as FoodQuery
import Data.Github as Github exposing (Commit, PullRequest, PullRequestBody)
import Data.Session exposing (Session)
import Data.Textile.Query as TextileQuery
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData exposing (WebData)
import RemoteData.Http exposing (defaultConfig)


config : RemoteData.Http.Config
config =
    -- drop ALL headers because Parcel's proxy messes with them
    -- see https://stackoverflow.com/a/47840149/330911
    { defaultConfig | headers = [] }


getChangelog : Session -> (WebData (List Commit) -> msg) -> Cmd msg
getChangelog { github } event =
    RemoteData.Http.getWithConfig config
        ("https://api.github.com/repos/" ++ github.repository ++ "/commits?sha=" ++ github.branch)
        event
        (Decode.list Github.decodeCommit)


createExamplesPr : String -> (WebData PullRequest -> msg) -> Encode.Value -> Cmd msg
createExamplesPr endpoint event =
    RemoteData.Http.postWithConfig config endpoint event Github.decodePullRequest


createFoodExamplesPR : (WebData PullRequest -> msg) -> PullRequestBody FoodQuery.Query -> Cmd msg
createFoodExamplesPR event =
    Github.encodePullRequestBody FoodQuery.encode
        >> createExamplesPr "/api/contrib/examples/food" event


createTextileExamplesPR : (WebData PullRequest -> msg) -> PullRequestBody TextileQuery.Query -> Cmd msg
createTextileExamplesPR event =
    Github.encodePullRequestBody TextileQuery.encode
        >> createExamplesPr "/api/contrib/examples/textile" event
