module Data.User2 exposing
    ( User
    , decode
    , encode
    )

import Data.Common.DecodeUtils as DU
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type Id
    = Id Uuid


type alias User =
    -- {
    --     "email": "user@tld.org",
    --     "id": "8c1f1647-ecbd-4fe6-a11b-0a049cc46d9f",
    --     "isActive": true,
    --     "isSuperuser": false,
    --     "isVerified": false,
    --     "magicLinkSentAt": null,
    --     "profile": {
    --         "firstName": "John",
    --         "lastName": "Doe",
    --         "organization": "Ecobalyse"
    --     },
    --     "roles": [],
    --     "termsAccepted": true
    -- }
    { email : String
    , id : Id
    , isActive : Bool
    , isSuperuser : Bool
    , isVerified : Bool
    , magicLinkSentAt : Maybe String
    , profile : Profile
    , roles : List String
    , termsAccepted : Bool
    }


type alias Profile =
    { firstName : String
    , lastName : String
    , organization : String
    }


decode : Decoder User
decode =
    Decode.succeed User
        |> Pipe.required "email" Decode.string
        |> Pipe.required "id" (Decode.map Id Uuid.decoder)
        |> Pipe.required "isActive" Decode.bool
        |> Pipe.required "isSuperuser" Decode.bool
        |> Pipe.required "isVerified" Decode.bool
        |> DU.strictOptional "magicLinkSentAt" Decode.string
        |> Pipe.required "profile" decodeProfile
        |> Pipe.required "roles" (Decode.list Decode.string)
        |> Pipe.required "termsAccepted" Decode.bool


decodeProfile : Decoder Profile
decodeProfile =
    Decode.succeed Profile
        |> Pipe.required "firstName" Decode.string
        |> Pipe.required "lastName" Decode.string
        |> Pipe.required "organization" Decode.string


encode : User -> Encode.Value
encode user =
    Encode.object
        [ ( "email", user.email |> Encode.string )
        , ( "id", user.id |> encodeId )
        , ( "isActive", user.isActive |> Encode.bool )
        , ( "isSuperuser", user.isSuperuser |> Encode.bool )
        , ( "isVerified", user.isVerified |> Encode.bool )
        , ( "magicLinkSentAt", user.magicLinkSentAt |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        , ( "profile", user.profile |> encodeProfile )
        , ( "roles", user.roles |> Encode.list Encode.string )
        , ( "termsAccepted", user.termsAccepted |> Encode.bool )
        ]


encodeId : Id -> Encode.Value
encodeId (Id uuid) =
    Uuid.encoder uuid


encodeProfile : Profile -> Encode.Value
encodeProfile profile =
    Encode.object
        [ ( "firstName", profile.firstName |> Encode.string )
        , ( "lastName", profile.lastName |> Encode.string )
        , ( "organization", profile.organization |> Encode.string )
        ]
