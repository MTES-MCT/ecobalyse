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
    { cgu : Bool
    , company : String
    , email : String
    , firstname : String
    , lastname : String
    , token : String
    }


type alias Form a =
    { a | next : String }


decode : Decoder User
decode =
    Decode.succeed User
        |> Pipe.required "terms_of_use" Decode.bool
        |> Pipe.optional "organization" Decode.string ""
        |> Pipe.required "email" Decode.string
        |> Pipe.required "first_name" Decode.string
        |> Pipe.required "last_name" Decode.string
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
    { cgu = user.cgu
    , company = user.company
    , email = user.email
    , firstname = user.firstname
    , lastname = user.lastname
    , next = "/#/auth/authenticated"
    , token = ""
    }
