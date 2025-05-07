module Request.Auth exposing
    ( AuthResponse(..)
    , Errors
    , login
    , logout
    , processes
    , profile
    , register
    )

import Data.User as User exposing (User)
import Dict exposing (Dict)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Errors =
    Dict String String


type AuthResponse
    = ErrorResponse String Errors
    | SuccessResponse String


decodeAuthResponse : Decoder AuthResponse
decodeAuthResponse =
    Decode.field "success" Decode.bool
        |> Decode.andThen
            (\success ->
                if success then
                    Decode.field "msg" Decode.string
                        |> Decode.map SuccessResponse

                else
                    Decode.succeed ErrorResponse
                        |> JDP.required "msg" Decode.string
                        |> JDP.optional "errors" (Decode.dict Decode.string) Dict.empty
            )


login : (Result Http.Error AuthResponse -> msg) -> String -> Cmd msg
login event email =
    Http.post
        { body = Http.jsonBody (Encode.object [ ( "email", Encode.string email ) ])
        , expect = Http.expectJson event decodeAuthResponse
        , url = "/accounts/login/"
        }


logout : msg -> Cmd msg
logout event =
    Http.post
        { body = Http.emptyBody
        , expect = Http.expectWhatever (always event)
        , url = "/accounts/logout/"
        }


processes : (Result Http.Error String -> msg) -> String -> Cmd msg
processes event token =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson event Decode.string
        , headers = [ Http.header "token" token ]
        , method = "GET"
        , timeout = Nothing
        , tracker = Nothing
        , url = "processes/processes.json"
        }


profile : (Result Http.Error User -> msg) -> Cmd msg
profile event =
    Http.get
        { expect = Http.expectJson event User.decode
        , url = "/accounts/profile/"
        }


register : (Result Http.Error AuthResponse -> msg) -> Encode.Value -> Cmd msg
register event userForm =
    Http.post
        { body = Http.jsonBody userForm
        , expect = Http.expectJson event decodeAuthResponse
        , url = "/accounts/register/"
        }
