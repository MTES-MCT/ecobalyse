module Data.User2 exposing
    ( SignupForm
    , User
    , decodeUser
    , emptySignupForm
    , encodeSignupForm
    , encodeUser
    )

import Data.Common.DecodeUtils as DU
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type Id
    = Id Uuid


type alias User =
    { email : String
    , id : Id
    , isActive : Bool
    , isSuperuser : Bool
    , isVerified : Bool
    , magicLinkSentAt : Maybe String
    , profile : Profile
    , roles : List Role
    , termsAccepted : Bool
    }


type alias Profile =
    { firstName : String
    , lastName : String
    , organization : String
    }


type alias Role =
    { roleName : String
    , roleSlug : String
    }


type alias SignupForm =
    { email : String
    , firstName : String
    , lastName : String
    , organization : String
    , termsAccepted : Bool
    }


decodeUser : Decoder User
decodeUser =
    Decode.succeed User
        |> Pipe.required "email" Decode.string
        |> Pipe.required "id" (Decode.map Id Uuid.decoder)
        |> Pipe.required "isActive" Decode.bool
        |> Pipe.required "isSuperuser" Decode.bool
        |> Pipe.required "isVerified" Decode.bool
        |> DU.strictOptional "magicLinkSentAt" Decode.string
        |> Pipe.required "profile" decodeProfile
        |> Pipe.required "roles" (Decode.list decodeRole)
        |> Pipe.required "termsAccepted" Decode.bool


decodeProfile : Decoder Profile
decodeProfile =
    Decode.succeed Profile
        |> Pipe.required "firstName" Decode.string
        |> Pipe.required "lastName" Decode.string
        |> Pipe.required "organization" Decode.string


decodeRole : Decoder Role
decodeRole =
    Decode.succeed Role
        |> Pipe.required "roleName" Decode.string
        |> Pipe.required "roleSlug" Decode.string


emptySignupForm : SignupForm
emptySignupForm =
    { email = ""
    , firstName = ""
    , lastName = ""
    , organization = ""
    , termsAccepted = False
    }


encodeUser : User -> Encode.Value
encodeUser user =
    Encode.object
        [ ( "email", user.email |> Encode.string )
        , ( "id", user.id |> encodeId )
        , ( "isActive", user.isActive |> Encode.bool )
        , ( "isSuperuser", user.isSuperuser |> Encode.bool )
        , ( "isVerified", user.isVerified |> Encode.bool )
        , ( "magicLinkSentAt", user.magicLinkSentAt |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        , ( "profile", user.profile |> encodeProfile )
        , ( "roles", user.roles |> Encode.list encodeRole )
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


encodeRole : Role -> Encode.Value
encodeRole role =
    Encode.object
        [ ( "roleName", role.roleName |> Encode.string )
        , ( "roleSlug", role.roleSlug |> Encode.string )
        ]


encodeSignupForm : SignupForm -> Encode.Value
encodeSignupForm form =
    Encode.object
        [ ( "email", form.email |> Encode.string )
        , ( "firstName", form.firstName |> Encode.string )
        , ( "lastName", form.lastName |> Encode.string )
        , ( "organization", form.organization |> Encode.string )
        , ( "termsAccepted", form.termsAccepted |> Encode.bool )
        ]
