module Data.User exposing
    ( AccessTokenData
    , FormErrors
    , Organization(..)
    , SignupForm
    , Siren(..)
    , User
    , decodeAccessTokenData
    , decodeOrganization
    , decodeUser
    , emptySignupForm
    , encodeAccessTokenData
    , encodeOrganization
    , encodeSignupForm
    , encodeUser
    , sirenFromString
    , sirenToString
    , validateEmailForm
    , validateSignupForm
    , validateSiren
    )

import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Uuid as Uuid exposing (Uuid)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import Regex
import Time exposing (Posix)


type alias User =
    { email : String
    , id : Id
    , isActive : Bool
    , isSuperuser : Bool
    , isVerified : Bool
    , magicLinkSentAt : Maybe Posix
    , profile : Profile
    , roles : List Role
    }


type alias AccessTokenData =
    { accessToken : String
    , expiresIn : Maybe Int
    , refreshToken : Maybe String
    , tokenType : String
    }


type alias Profile =
    { firstName : String
    , lastName : String
    , organization : Organization
    , termsAccepted : Bool
    }


type Organization
    = -- Association
      Association String
      -- Entreprise
    | Business String Siren
      -- Enseignant/ Recherche/ Etudiant
    | Education String
      -- Particulier
    | Individual
      -- Collectivité ou EPCI
    | LocalAuthority String
      -- Media
    | Media String
      -- Autre établissement public et Etat
    | Public String


type Siren
    = Siren String


type alias Role =
    { assignedAt : Posix
    , roleId : String
    , roleName : String
    , roleSlug : String
    }


type alias SignupForm =
    { email : String
    , firstName : String
    , lastName : String
    , organization : String
    , termsAccepted : Bool
    }


type Id
    = Id Uuid


type alias FormErrors =
    Dict String String



-- Decoders


decodeUser : Decoder User
decodeUser =
    Decode.succeed User
        |> JDP.required "email" Decode.string
        |> JDP.required "id" (Decode.map Id Uuid.decoder)
        |> JDP.required "isActive" Decode.bool
        |> JDP.required "isSuperuser" Decode.bool
        |> JDP.required "isVerified" Decode.bool
        |> DU.strictOptional "magicLinkSentAt" DE.datetime
        |> JDP.required "profile" decodeProfile
        |> JDP.required "roles" (Decode.list decodeRole)


decodeAccessTokenData : Decoder AccessTokenData
decodeAccessTokenData =
    Decode.succeed AccessTokenData
        |> JDP.required "access_token" Decode.string
        |> DU.strictOptional "expires_in" Decode.int
        |> DU.strictOptional "refresh_token" Decode.string
        |> JDP.required "token_type" Decode.string


decodeOrganization : Decoder Organization
decodeOrganization =
    Decode.oneOf <|
        -- decode business
        (Decode.succeed (\_ name siren -> Business name siren)
            |> JDP.required "type" (DU.decodeExpected Decode.string "business")
            |> JDP.required "name" Decode.string
            |> JDP.required "siren" decodeSiren
        )
            -- decode named entities
            :: ([ ( "association", Association )
                , ( "education", Education )
                , ( "localAuthority", LocalAuthority )
                , ( "media", Media )
                , ( "public", Public )
                ]
                    |> List.map
                        (\( orgString, orgType ) ->
                            Decode.succeed (\_ name -> orgType name)
                                |> JDP.required "type" (DU.decodeExpected Decode.string orgString)
                                |> JDP.required "name" Decode.string
                        )
               )
            -- decode individual
            ++ [ Decode.succeed (always Individual)
                    |> JDP.required "type" (DU.decodeExpected Decode.string "individual")
               ]


decodeProfile : Decoder Profile
decodeProfile =
    Decode.succeed Profile
        |> JDP.required "firstName" Decode.string
        |> JDP.required "lastName" Decode.string
        |> JDP.required "organization" decodeOrganization
        |> JDP.required "termsAccepted" Decode.bool


decodeRole : Decoder Role
decodeRole =
    Decode.succeed Role
        |> JDP.required "assignedAt" DE.datetime
        |> JDP.required "roleId" Decode.string
        |> JDP.required "roleName" Decode.string
        |> JDP.required "roleSlug" Decode.string


decodeSiren : Decoder Siren
decodeSiren =
    Decode.string
        |> Decode.andThen (validateSiren >> DE.fromResult)


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
        , ( "magicLinkSentAt"
          , user.magicLinkSentAt
                |> Maybe.map EU.datetime
                |> Maybe.withDefault Encode.null
          )
        , ( "profile", user.profile |> encodeProfile )
        , ( "roles", user.roles |> Encode.list encodeRole )
        ]



-- Encoders


encodeId : Id -> Encode.Value
encodeId (Id uuid) =
    Uuid.encoder uuid


encodeProfile : Profile -> Encode.Value
encodeProfile profile =
    Encode.object
        [ ( "firstName", profile.firstName |> Encode.string )
        , ( "lastName", profile.lastName |> Encode.string )
        , ( "organization", profile.organization |> encodeOrganization )
        , ( "termsAccepted", profile.termsAccepted |> Encode.bool )
        ]


encodeOrganization : Organization -> Encode.Value
encodeOrganization organization =
    case organization of
        Association name ->
            Encode.object
                [ ( "type", Encode.string "association" )
                , ( "name", Encode.string name )
                ]

        Business name (Siren siren) ->
            Encode.object
                [ ( "type", Encode.string "business" )
                , ( "name", Encode.string name )
                , ( "siren", Encode.string siren )
                ]

        Education name ->
            Encode.object
                [ ( "type", Encode.string "education" )
                , ( "name", Encode.string name )
                ]

        Individual ->
            Encode.object
                [ ( "type", Encode.string "individual" )
                ]

        LocalAuthority name ->
            Encode.object
                [ ( "type", Encode.string "localAuthority" )
                , ( "name", Encode.string name )
                ]

        Media name ->
            Encode.object
                [ ( "type", Encode.string "media" )
                , ( "name", Encode.string name )
                ]

        Public name ->
            Encode.object
                [ ( "type", Encode.string "public" )
                , ( "name", Encode.string name )
                ]


encodeRole : Role -> Encode.Value
encodeRole role =
    Encode.object
        [ ( "assignedAt", role.assignedAt |> EU.datetime )
        , ( "roleId", role.roleId |> Encode.string )
        , ( "roleName", role.roleName |> Encode.string )
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
        , ( "expires_in", v.expiresIn |> Maybe.map Encode.int |> Maybe.withDefault Encode.null )
        , ( "refresh_token", v.refreshToken |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        , ( "token_type", v.tokenType |> Encode.string )
        ]


sirenToString : Siren -> String
sirenToString (Siren siren) =
    siren


sirenFromString : String -> Siren
sirenFromString =
    Siren



-- Validation


validateEmailForm : String -> FormErrors
validateEmailForm email =
    Dict.empty
        |> addFormErrorIf "email"
            "L'adresse e-mail est invalide"
            (Regex.fromString "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
                |> Maybe.map (\re -> email |> Regex.contains re |> not)
                |> Maybe.withDefault False
            )


{-| Validates a French SIREN number

@see <https://fr.wikipedia.org/wiki/Syst%C3%A8me_d%27identification_du_r%C3%A9pertoire_des_entreprises>

-}
validateSiren : String -> Result String Siren
validateSiren siren =
    if String.length siren /= 9 then
        Err "Le numéro SIREN doit contenir exactement 9 chiffres"

    else if not (String.all Char.isDigit siren) then
        Err "Le numéro SIREN ne doit contenir que des chiffres"

    else
        let
            digits =
                siren
                    |> String.toList
                    |> List.map (String.fromChar >> String.toInt >> Maybe.withDefault 0)

            sum =
                digits
                    |> List.indexedMap
                        (\index digit ->
                            if modBy 2 index == 1 then
                                let
                                    doubled =
                                        digit * 2
                                in
                                if doubled > 9 then
                                    doubled - 9

                                else
                                    doubled

                            else
                                digit
                        )
                    |> List.sum
        in
        if modBy 10 sum == 0 then
            Ok (Siren siren)

        else
            Err "Le numéro SIREN est invalide"


validateSignupForm : SignupForm -> FormErrors
validateSignupForm form =
    -- TODO: validate org type conditionnalities
    let
        isEmpty =
            String.trim >> String.isEmpty

        requiredMsg =
            "Le champ est obligatoire"
    in
    validateEmailForm form.email
        |> addFormErrorIf "firstName" requiredMsg (isEmpty form.firstName)
        |> addFormErrorIf "lastName" requiredMsg (isEmpty form.lastName)
        |> addFormErrorIf "organization" requiredMsg (isEmpty form.organization)
        |> addFormErrorIf "termsAccepted" "Les CGU doivent être acceptées" (not form.termsAccepted)


addFormErrorIf : comparable -> b -> Bool -> Dict comparable b -> Dict comparable b
addFormErrorIf field msg check =
    if check then
        Dict.insert field msg

    else
        identity
