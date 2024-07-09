module Data.User exposing
    ( User
    , decode
    , encode
    , encodeForm
    , form
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type alias User =
    { email : String
    , firstname : String
    , lastname : String
    , company : String
    , cgu : Bool
    , token : String
    }


type alias Form a =
    { a | next : String }


decode : Decoder User
decode =
    Decode.succeed User
        |> Pipe.required "email" Decode.string
        |> Pipe.required "first_name" Decode.string
        |> Pipe.required "last_name" Decode.string
        |> Pipe.optional "organization" Decode.string ""
        |> Pipe.required "terms_of_use" Decode.bool
        |> Pipe.required "token" Decode.string


encode : User -> Encode.Value
encode user =
    Encode.object
        [ ( "email", Encode.string user.email )
        , ( "first_name", Encode.string user.firstname )
        , ( "last_name", Encode.string user.lastname )
        , ( "organization", Encode.string user.company )
        , ( "terms_of_use", Encode.bool user.cgu )
        , ( "token", Encode.string user.token )
        ]


encodeForm : Form User -> Encode.Value
encodeForm user =
    Encode.object
        [ ( "email", Encode.string user.email )
        , ( "first_name", Encode.string user.firstname )
        , ( "last_name", Encode.string user.lastname )
        , ( "organization", Encode.string user.company )
        , ( "terms_of_use", Encode.bool user.cgu )
        , ( "next", Encode.string user.next )
        ]


form : User -> Form User
form user =
    { email = user.email
    , firstname = user.firstname
    , lastname = user.lastname
    , company = user.company
    , cgu = user.cgu
    , token = ""
    , next = "/#/auth/authenticated"
    }
