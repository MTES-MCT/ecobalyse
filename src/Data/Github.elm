module Data.Github exposing
    ( Commit
    , PullRequest
    , PullRequestBody
    , decodeCommit
    , decodePullRequest
    , encodePullRequestBody
    )

import Data.Example as Example exposing (Example)
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
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


type alias PullRequestBody query =
    { examples : List (Example query)
    , name : String
    , email : String
    , description : String
    }


encodePullRequestBody : (query -> Encode.Value) -> PullRequestBody query -> Encode.Value
encodePullRequestBody encodeQuery { examples, name, email, description } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "email", Encode.string email )
        , ( "description", Encode.string description )
        , ( "examples", Example.encodeList encodeQuery examples )
        ]


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
