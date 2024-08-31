module Data.Github exposing
    ( Commit
    , Release
    , decodeCommit
    , decodeReleaseList
    , unreleased
    )

import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Time exposing (Posix)


type alias Commit =
    { sha : String
    , message : String
    , date : Posix
    , authorName : String
    , authorLogin : String
    , authorAvatar : Maybe String
    }


type alias Release =
    { draft : Bool
    , hash : String
    , markdown : String
    , name : String
    , tag : String
    , url : String
    }


decodeCommit : Decoder Commit
decodeCommit =
    Decode.succeed Commit
        |> Pipe.requiredAt [ "sha" ] Decode.string
        |> Pipe.requiredAt [ "commit", "message" ] Decode.string
        |> Pipe.requiredAt [ "commit", "author", "date" ] Iso8601.decoder
        |> Pipe.requiredAt [ "commit", "author", "name" ] Decode.string
        |> Pipe.optionalAt [ "author", "login" ] Decode.string "Ecobalyse"
        |> Pipe.optionalAt [ "author", "avatar_url" ] (Decode.maybe Decode.string) Nothing
        |> Decode.map
            (\({ authorAvatar, authorName } as commit) ->
                if authorAvatar == Nothing && authorName == "Ingredient editor" then
                    { commit | authorAvatar = Just "img/ingredient-editor.png" }

                else
                    commit
            )


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
