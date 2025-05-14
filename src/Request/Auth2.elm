module Request.Auth2 exposing
    ( requestAuthEmail
    , signup
    )

import Data.Session exposing (Session)
import Data.User2 as User exposing (SignupForm, User)
import Http
import Json.Encode as Encode


{-| Request an authentication email
-}
requestAuthEmail : Session -> (Result Http.Error () -> msg) -> String -> Cmd msg
requestAuthEmail session event email =
    Http.post
        { body = Http.jsonBody <| Encode.object [ ( "email", email |> Encode.string ) ]
        , expect = Http.expectWhatever event
        , url = session.backendApiUrl ++ "access/magic_link/login"
        }


{-| Signup a new user
-}
signup : Session -> (Result Http.Error User -> msg) -> SignupForm -> Cmd msg
signup session event signupForm =
    Http.post
        { body = Http.jsonBody <| User.encodeSignupForm signupForm
        , expect = Http.expectJson event User.decodeUser
        , url = session.backendApiUrl ++ "access/magic_link/signup"
        }
