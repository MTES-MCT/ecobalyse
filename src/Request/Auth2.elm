module Request.Auth2 exposing
    ( askLoginEmail
    , login
    , profile
    , signup
    )

import Data.Session exposing (Session)
import Data.User2 as User exposing (AccessTokenData, SignupForm, User)
import Http
import Json.Encode as Encode


endpoint : { a | backendApiUrl : String } -> String -> String
endpoint { backendApiUrl } path =
    String.join "/" [ backendApiUrl, "api", path ]


{-| Request an authentication email
-}
askLoginEmail : Session -> (Result Http.Error () -> msg) -> String -> Cmd msg
askLoginEmail session event email =
    Http.post
        { body = Http.jsonBody <| Encode.object [ ( "email", email |> Encode.string ) ]
        , expect = Http.expectWhatever event
        , url = endpoint session "access/magic_link/login"
        }


{-| Logs the user in
-}
login : Session -> (Result Http.Error AccessTokenData -> msg) -> String -> String -> Cmd msg
login session event email token =
    Http.get
        { expect = Http.expectJson event User.decodeAccessTokenData
        , url = endpoint session "access/login" ++ "?email=" ++ email ++ "&token=" ++ token
        }


{-| Retrieve user profile
-}
profile : Session -> (Result Http.Error User -> msg) -> String -> Cmd msg
profile session event accessToken =
    Http.request
        { body = Http.emptyBody
        , expect = Http.expectJson event User.decodeUser
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , method = "GET"
        , timeout = Nothing
        , tracker = Nothing
        , url = endpoint session "me"
        }


{-| Signup a new user
-}
signup : Session -> (Result Http.Error User -> msg) -> SignupForm -> Cmd msg
signup session event signupForm =
    Http.post
        { body = Http.jsonBody <| User.encodeSignupForm signupForm
        , expect = Http.expectJson event User.decodeUser
        , url = endpoint session "access/magic_link/signup"
        }



-- FIXME: we should be able to access error details by inspecting a bad status response json body
-- type alias ErrorResponse =
--     { detail : String, status_code : Int }
-- expectCustomResponse : Decode.Decoder value -> (Result Http.Error value -> msg) -> Http.Expect msg
-- expectCustomResponse decoder toMsg =
--     Http.expectStringResponse toMsg <|
--         \response ->
--             case response of
--                 Http.BadStatus_ metadata body ->
--                     let
--                         errorDecoder =
--                             Decode.map2 ErrorResponse
--                                 (Decode.field "detail" Decode.string)
--                                 (Decode.field "status_code" Decode.int)
--                     in
--                     case Decode.decodeString errorDecoder body of
--                         Err _ ->
--                             Err <| Http.BadStatus metadata.statusCode
--                         Ok decodedError ->
--                             -- How to use decoded error?
--                             Err <| Http.BadStatus metadata.statusCode
--                 Http.BadUrl_ url ->
--                     Err (Http.BadUrl url)
--                 Http.GoodStatus_ _ body ->
--                     case Decode.decodeString decoder body of
--                         Err err ->
--                             Err <| Http.BadBody (Decode.errorToString err)
--                         Ok value ->
--                             Ok value
--                 Http.NetworkError_ ->
--                     Err Http.NetworkError
--                 Http.Timeout_ ->
--                     Err Http.Timeout
