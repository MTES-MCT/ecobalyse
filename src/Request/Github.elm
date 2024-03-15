module Request.Github exposing
    ( createFoodExamplesPR
    , createTextileExamplesPR
    , getChangelog
    )

import Data.Example as Example exposing (Example)
import Data.Food.Query as FoodQuery
import Data.Github as Github
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


getChangelog : Session -> (WebData (List Github.Commit) -> msg) -> Cmd msg
getChangelog { github } event =
    RemoteData.Http.getWithConfig config
        ("https://api.github.com/repos/" ++ github.repository ++ "/commits?sha=" ++ github.branch)
        event
        (Decode.list Github.decodeCommit)


createExamplesPr :
    String
    -> (WebData Github.PullRequest -> msg)
    -> (query -> Encode.Value)
    -> List (Example query)
    -> Cmd msg
createExamplesPr endpoint event encodeQuery =
    Example.encodeList encodeQuery
        >> RemoteData.Http.postWithConfig config endpoint event Github.decodePullRequest


createFoodExamplesPR : Session -> (WebData Github.PullRequest -> msg) -> Cmd msg
createFoodExamplesPR { db } event =
    db.food.examples
        |> createExamplesPr "/api/contrib/examples/food" event FoodQuery.encode


createTextileExamplesPR : Session -> (WebData Github.PullRequest -> msg) -> Cmd msg
createTextileExamplesPR { db } event =
    db.textile.examples
        |> createExamplesPr "/api/contrib/examples/textile" event TextileQuery.encode
