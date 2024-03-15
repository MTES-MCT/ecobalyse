module Data.Github exposing
    ( Commit
    , PullRequest
    , decodeCommit
    , decodePullRequest
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


type alias PullRequest =
    { status : Int
    , html_url : String
    , diff_url : String
    , additions : Int
    , deletions : Int
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
        |> Decode.andThen
            (\({ authorAvatar, authorName } as commit) ->
                Decode.succeed
                    (if authorAvatar == Nothing && authorName == "Ingredient editor" then
                        { commit | authorAvatar = Just "img/ingredient-editor.png" }

                     else
                        commit
                    )
            )


decodePullRequest : Decoder PullRequest
decodePullRequest =
    Decode.succeed PullRequest
        |> Pipe.required "status" Decode.int
        |> Pipe.required "html_url" Decode.string
        |> Pipe.required "diff_url" Decode.string
        |> Pipe.required "additions" Decode.int
        |> Pipe.required "deletions" Decode.int
