module Data.Github exposing
    ( Release
    , decodeReleaseList
    , unreleased
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe


type alias Release =
    { draft : Bool
    , hash : String
    , markdown : String
    , name : String
    , tag : String
    , url : String
    }


decodeRelease : Decoder Release
decodeRelease =
    Decode.succeed Release
        |> Pipe.required "draft" Decode.bool
        |> Pipe.required "target_commitish" Decode.string
        |> Pipe.required "body" Decode.string
        |> Pipe.required "name" Decode.string
        |> Pipe.required "tag_name" Decode.string
        |> Pipe.required "html_url" Decode.string


decodeReleaseList : Decoder (List Release)
decodeReleaseList =
    Decode.list decodeRelease
        -- Exclude draft releases
        |> Decode.map (List.filter (.draft >> not))


unreleased : Release
unreleased =
    Release True "" "" "Unreleased" "Unreleased" ""
