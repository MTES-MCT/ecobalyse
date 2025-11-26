module Data.User exposing
    ( AccessTokenData
    , FormErrors
    , Organization(..)
    , ProfileForm
    , SignupForm
    , Siren(..)
    , User
    , decodeAccessTokenData
    , decodeOrganization
    , decodeUser
    , emptyProfileForm
    , emptySignupForm
    , encodeAccessTokenData
    , encodeOrganization
    , encodeSignupForm
    , encodeUpdateProfileForm
    , encodeUser
    , getOrganizationName
    , organizationToSirenString
    , organizationToString
    , organizationTypeToString
    , organizationTypes
    , sirenFromString
    , sirenToString
    , updateOrganizationName
    , updateOrganizationSiren
    , updateOrganizationType
    , validateEmailForm
    , validateProfileForm
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
    , joinedAt : Maybe Posix
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
    { emailOptin : Bool
    , firstName : String
    , lastName : String
    , organization : Organization
    , termsAccepted : Bool
    }


type alias ProfileForm =
    { emailOptin : Bool
    , firstName : String
    , lastName : String
    }


type Organization
    = -- Association
      Association String
      -- Entreprise
    | Business String Siren
      -- Enseignement/Recherche
    | Education String
      -- Particulier
    | Individual
      -- Collectivité ou EPCI
    | LocalAuthority String
      -- Media
    | Media String
      -- Autre établissement public et Etat
    | Public String
      -- Étudiant·e
    | Student String


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
    , emailOptin : Bool
    , firstName : String
    , lastName : String
    , organization : Organization
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
        |> DU.strictOptional "joinedAt" DE.datetime
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
            , ( "student", Student )
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
        |> Decode.oneOf


decodeProfile : Decoder Profile
decodeProfile =
    Decode.succeed Profile
        |> DU.strictOptionalWithDefault "emailOptin" Decode.bool False
        |> DU.strictOptionalWithDefault "firstName" Decode.string ""
        |> DU.strictOptionalWithDefault "lastName" Decode.string ""
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


emptyProfileForm : ProfileForm
emptyProfileForm =
    { emailOptin = False
    , firstName = ""
    , lastName = ""
    }


emptySignupForm : SignupForm
emptySignupForm =
    { email = ""
    , emailOptin = False
    , firstName = ""
    , lastName = ""
    , organization = Individual
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
        , ( "joinedAt"
          , user.joinedAt
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
        [ ( "emailOptin", profile.emailOptin |> Encode.bool )
        , ( "firstName", profile.firstName |> Encode.string )
        , ( "lastName", profile.lastName |> Encode.string )
        , ( "organization", profile.organization |> encodeOrganization )
        , ( "termsAccepted", profile.termsAccepted |> Encode.bool )
        ]


encodeOrganization : Organization -> Encode.Value
encodeOrganization organization =
    let
        encodeWithName name =
            Encode.object
                [ ( "type", Encode.string <| organizationTypeToString organization )
                , ( "name", Encode.string name )
                ]
    in
    case organization of
        Association name ->
            encodeWithName name

        Business name (Siren siren) ->
            Encode.object
                [ ( "type", Encode.string <| organizationTypeToString organization )
                , ( "name", Encode.string name )
                , ( "siren", Encode.string siren )
                ]

        Education name ->
            encodeWithName name

        Individual ->
            Encode.object
                [ ( "type", Encode.string <| organizationTypeToString organization )
                ]

        LocalAuthority name ->
            encodeWithName name

        Media name ->
            encodeWithName name

        Public name ->
            encodeWithName name

        Student name ->
            encodeWithName name


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
        , ( "emailOptin", form.emailOptin |> Encode.bool )
        , ( "firstName", form.firstName |> Encode.string )
        , ( "lastName", form.lastName |> Encode.string )
        , ( "organization", form.organization |> encodeOrganization )
        , ( "termsAccepted", form.termsAccepted |> Encode.bool )
        ]


encodeUpdateProfileForm : ProfileForm -> Encode.Value
encodeUpdateProfileForm form =
    Encode.object
        [ ( "emailOptin", form.emailOptin |> Encode.bool )
        , ( "firstName", form.firstName |> Encode.string )
        , ( "lastName", form.lastName |> Encode.string )
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



-- Helpers


getOrganizationName : Organization -> Maybe String
getOrganizationName organization =
    case organization of
        Association name ->
            Just name

        Business name _ ->
            Just name

        Education name ->
            Just name

        Individual ->
            Nothing

        LocalAuthority name ->
            Just name

        Media name ->
            Just name

        Public name ->
            Just name

        Student name ->
            Just name


updateOrganizationName : String -> Organization -> Organization
updateOrganizationName name organization =
    case organization of
        Association _ ->
            Association name

        Business _ siren ->
            Business name siren

        Education _ ->
            Education name

        Individual ->
            Individual

        LocalAuthority _ ->
            LocalAuthority name

        Media _ ->
            Media name

        Public _ ->
            Public name

        Student _ ->
            Student name


updateOrganizationSiren : String -> Organization -> Organization
updateOrganizationSiren siren organization =
    case organization of
        Business name _ ->
            Business name (sirenFromString siren)

        _ ->
            organization


organizationTypes : List ( String, String )
organizationTypes =
    [ ( "association", "Association" )
    , ( "business", "Entreprise" )
    , ( "education", "Enseignement/Recherche" )
    , ( "individual", "Particulier" )
    , ( "localAuthority", "Collectivité ou EPCI" )
    , ( "media", "Média" )
    , ( "public", "Autre établissement public et État" )
    , ( "student", "Étudiant·e" )
    ]


updateOrganizationType : String -> Organization -> Organization
updateOrganizationType type_ organization =
    let
        name =
            getOrganizationName organization |> Maybe.withDefault ""
    in
    case type_ of
        "association" ->
            Association name

        "business" ->
            Business name (sirenFromString "")

        "education" ->
            Education name

        "individual" ->
            Individual

        "localAuthority" ->
            LocalAuthority name

        "media" ->
            Media name

        "public" ->
            Public name

        "student" ->
            Student name

        _ ->
            organization


organizationToSirenString : Organization -> String
organizationToSirenString organization =
    case organization of
        Business _ siren ->
            sirenToString siren

        _ ->
            ""


organizationToString : Organization -> String
organizationToString organization =
    case organization of
        Association name ->
            name ++ " (association)"

        Business name _ ->
            name ++ " (entreprise)"

        Education name ->
            name ++ " (enseignement/recherche)"

        Individual ->
            "Particulier"

        LocalAuthority name ->
            name ++ " (collectivité ou EPCI)"

        Media name ->
            name ++ " (média)"

        Public name ->
            name ++ " (autre établissement public et État)"

        Student name ->
            name ++ " (étudiant·e)"


organizationTypeToString : Organization -> String
organizationTypeToString organization =
    case organization of
        Association _ ->
            "association"

        Business _ _ ->
            "business"

        Education _ ->
            "education"

        Individual ->
            "individual"

        LocalAuthority _ ->
            "localAuthority"

        Media _ ->
            "media"

        Public _ ->
            "public"

        Student _ ->
            "student"



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


validateProfileForm : ProfileForm -> FormErrors
validateProfileForm form =
    let
        isEmpty =
            String.trim >> String.isEmpty

        requiredMsg =
            "Le champ est obligatoire"
    in
    Dict.empty
        |> addFormErrorIf "firstName" requiredMsg (isEmpty form.firstName)
        |> addFormErrorIf "lastName" requiredMsg (isEmpty form.lastName)


validateSignupForm : SignupForm -> FormErrors
validateSignupForm form =
    let
        isEmpty =
            String.trim >> String.isEmpty

        requiredMsg =
            "Le champ est obligatoire"
    in
    validateEmailForm form.email
        |> addFormErrorIf "firstName" requiredMsg (isEmpty form.firstName)
        |> addFormErrorIf "lastName" requiredMsg (isEmpty form.lastName)
        |> addFormErrorIf "organization.name"
            requiredMsg
            (getOrganizationName form.organization
                |> Maybe.map isEmpty
                |> Maybe.withDefault False
            )
        |> addFormErrorFromResult "organization.siren"
            (case form.organization of
                Business _ (Siren siren) ->
                    validateSiren siren

                _ ->
                    Ok (sirenFromString "")
            )
        |> addFormErrorIf "termsAccepted" "Les CGU doivent être acceptées" (not form.termsAccepted)


addFormErrorIf : String -> String -> Bool -> FormErrors -> FormErrors
addFormErrorIf field msg check =
    if check then
        Dict.insert field msg

    else
        identity


addFormErrorFromResult : String -> Result String a -> FormErrors -> FormErrors
addFormErrorFromResult field result errors =
    case result of
        Err msg ->
            addFormErrorIf field msg True errors

        Ok _ ->
            errors
