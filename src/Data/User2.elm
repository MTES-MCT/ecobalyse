module Data.User2 exposing
    ( AccessTokenData
    , FormErrors
    , SignupForm
    , User
    , decodeAccessTokenData
    , decodeUser
    , emptySignupForm
    , encodeAccessTokenData
    , encodeSignupForm
    , encodeUser
    , validateEmail
    , validateSignupForm
    )

import Data.Common.DecodeUtils as DU
import Data.Uuid as Uuid exposing (Uuid)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Regex


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


type alias AccessTokenData =
    { accessToken : String
    , expiresIn : Int
    , refreshToken : Maybe String
    , tokenType : String
    }


type Id
    = Id Uuid


type alias FormErrors =
    Dict String String


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


decodeAccessTokenData : Decoder AccessTokenData
decodeAccessTokenData =
    Decode.succeed AccessTokenData
        |> Pipe.required "access_token" Decode.string
        |> Pipe.required "expires_in" Decode.int
        |> DU.strictOptional "refresh_token" Decode.string
        |> Pipe.required "token_type" Decode.string


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


encodeAccessTokenData : AccessTokenData -> Encode.Value
encodeAccessTokenData v =
    Encode.object
        [ ( "access_token", v.accessToken |> Encode.string )
        , ( "expires_in", v.expiresIn |> Encode.int )
        , ( "refresh_token", v.refreshToken |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        , ( "token_type", v.tokenType |> Encode.string )
        ]


validateEmail : String -> FormErrors
validateEmail email =
    Dict.empty
        |> addFormErrorIf "email"
            "L'adresse e-mail est invalide"
            (Regex.fromString "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
                |> Maybe.map (\re -> email |> Regex.contains re |> not)
                |> Maybe.withDefault False
            )


validateSignupForm : SignupForm -> FormErrors
validateSignupForm form =
    let
        isEmpty =
            String.trim >> String.isEmpty

        requiredMsg =
            "Le champ est obligatoire"
    in
    validateEmail form.email
        |> addFormErrorIf "firstName" requiredMsg (isEmpty form.firstName)
        |> addFormErrorIf "lastName" requiredMsg (isEmpty form.lastName)
        |> addFormErrorIf "organization" requiredMsg (isEmpty form.organization)
        |> addFormErrorIf "termsAccepted" requiredMsg (not form.termsAccepted)


addFormErrorIf : comparable -> b -> Bool -> Dict comparable b -> Dict comparable b
addFormErrorIf field msg check =
    if check then
        Dict.insert field msg

    else
        identity
