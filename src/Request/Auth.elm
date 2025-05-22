module Request.Auth exposing
    ( askMagicLink
    , login
    , logout
    , processes
    , profile
    , profileFromAccessToken
    , signup
    )

import Data.Session exposing (Session)
import Data.User as User exposing (AccessTokenData, SignupForm, User)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData
import Request.BackendHttp as BackendHttp exposing (WebData)


{-| Request an authentication email, containing a "magic link"
-}
askMagicLink : Session -> (WebData () -> msg) -> String -> Cmd msg
askMagicLink session event email =
    BackendHttp.post session
        "access/magic_link/login"
        event
        (Decode.succeed ())
        (Encode.object [ ( "email", email |> Encode.string ) ])


{-| Logs the user in
-}
login : Session -> (WebData AccessTokenData -> msg) -> String -> String -> Cmd msg
login session event email token =
    BackendHttp.get session
        ("access/login" ++ "?email=" ++ email ++ "&token=" ++ token)
        event
        User.decodeAccessTokenData


logout : Session -> (WebData () -> msg) -> User -> Cmd msg
logout session event user =
    BackendHttp.post session
        "access/logout"
        event
        (Decode.succeed ())
        (User.encodeUser user)


{-| Retrieve the detailed processes list
-}
processes : Session -> (WebData String -> msg) -> Cmd msg
processes session event =
    BackendHttp.getWithConfig session
        { url = session.clientUrl ++ "processes/processes.json" }
        event
        Decode.string


{-| Retrieve user profile using auth data from current session
-}
profile : Session -> (WebData User -> msg) -> Cmd msg
profile session event =
    BackendHttp.get session
        "me"
        event
        User.decodeUser


{-| Retrieve user profile from a token received by email
-}
profileFromAccessToken : Session -> (WebData User -> msg) -> String -> Cmd msg
profileFromAccessToken session event accessToken =
    Http.request
        { body = Http.emptyBody
        , expect = BackendHttp.expectJson (RemoteData.fromResult >> event) User.decodeUser
        , headers = [ Http.header "Authorization" <| "Bearer " ++ accessToken ]
        , method = "GET"
        , timeout = Nothing
        , tracker = Nothing
        , url = session.backendApiUrl ++ "/api/me"
        }


{-| Signup a new user
-}
signup : Session -> (WebData User -> msg) -> SignupForm -> Cmd msg
signup session event signupForm =
    BackendHttp.post session
        "access/magic_link/signup"
        event
        User.decodeUser
        (User.encodeSignupForm signupForm)
