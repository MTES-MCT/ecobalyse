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
import Request.BackendHttp as BackendHttp


endpoint : { a | backendApiUrl : String } -> String -> String
endpoint { backendApiUrl } path =
    String.join "/" [ backendApiUrl, "api", path ]


{-| Request an authentication email
-}
askLoginEmail : Session -> (Result BackendHttp.Error () -> msg) -> String -> Cmd msg
askLoginEmail session event email =
    Http.post
        { body = Http.jsonBody <| Encode.object [ ( "email", email |> Encode.string ) ]
        , expect = BackendHttp.expectApiWhatever event
        , url = endpoint session "access/magic_link/login"
        }


{-| Logs the user in
-}
login : Session -> (Result BackendHttp.Error AccessTokenData -> msg) -> String -> String -> Cmd msg
login session event email token =
    Http.get
        { expect = BackendHttp.expectApiJson event User.decodeAccessTokenData
        , url = endpoint session "access/login" ++ "?email=" ++ email ++ "&token=" ++ token
        }


{-| Retrieve user profile
-}
profile : Session -> (Result BackendHttp.Error User -> msg) -> String -> Cmd msg
profile session event accessToken =
    Http.request
        { body = Http.emptyBody
        , expect = BackendHttp.expectApiJson event User.decodeUser
        , headers = [ Http.header "Authorization" ("Bearer " ++ accessToken) ]
        , method = "GET"
        , timeout = Nothing
        , tracker = Nothing
        , url = endpoint session "me"
        }


{-| Signup a new user
-}
signup : Session -> (Result BackendHttp.Error User -> msg) -> SignupForm -> Cmd msg
signup session event signupForm =
    Http.post
        { body = Http.jsonBody <| User.encodeSignupForm signupForm
        , expect = BackendHttp.expectApiJson event User.decodeUser
        , url = endpoint session "access/magic_link/signup"
        }
