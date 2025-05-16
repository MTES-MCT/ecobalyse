module Request.Auth2 exposing
    ( askLoginEmail
    , login
    , profileFromAccessToken
    , signup
    )

import Data.Session exposing (Session)
import Data.User2 as User exposing (AccessTokenData, SignupForm, User)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import RemoteData
import Request.BackendHttp as BackendHttp exposing (WebData)


{-| Request an authentication email
-}
askLoginEmail : Session -> (WebData () -> msg) -> String -> Cmd msg
askLoginEmail session event email =
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
