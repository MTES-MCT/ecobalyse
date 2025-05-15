module Request.Auth2 exposing
    ( login
    , signup
    )

import Data.Session exposing (Session)
import Data.User2 as User exposing (SignupForm, User)
import Http
import Json.Encode as Encode


endpoint : Session -> String -> String
endpoint { backendApiUrl } path =
    String.join "/" [ backendApiUrl, "api/access/magic_link", path ]


{-| Request an authentication email
-}
login : Session -> (Result Http.Error () -> msg) -> String -> Cmd msg
login session event email =
    Http.post
        { body = Http.jsonBody <| Encode.object [ ( "email", email |> Encode.string ) ]
        , expect = Http.expectWhatever event
        , url = endpoint session "login"
        }


{-| Signup a new user
-}
signup : Session -> (Result Http.Error User -> msg) -> SignupForm -> Cmd msg
signup session event signupForm =
    Http.post
        { body = Http.jsonBody <| User.encodeSignupForm signupForm
        , expect = Http.expectJson event User.decodeUser
        , url = endpoint session "signup"
        }
