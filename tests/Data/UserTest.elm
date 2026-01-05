module Data.UserTest exposing (..)

import Data.User as User exposing (emptySignupForm)
import Dict
import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)
import TestUtils as TU exposing (it)


suite : Test
suite =
    describe "Data.Auth2"
        [ describe "decodeUser"
            [ it "should decode a user"
                (userJson
                    |> Decode.decodeString User.decodeUser
                    |> Result.map .email
                    |> Expect.equal (Ok "user@tld.org")
                )
            ]
        , describe "encodeUser"
            [ it "should encode a user"
                (userJson
                    |> Decode.decodeString User.decodeUser
                    |> Result.map (User.encodeUser >> Encode.encode 0)
                    |> Result.andThen (Decode.decodeString User.decodeUser)
                    |> Result.map .email
                    |> Expect.equal (Ok "user@tld.org")
                )
            ]
        , describe "decodeOrganization"
            [ it "should decode a business"
                ("""{"type": "business", "name": "Ecobalyse", "siren": "{siren}"}"""
                    |> String.replace "{siren}" sampleValidSiren
                    |> Decode.decodeString User.decodeOrganization
                    |> Expect.equal (Ok (User.Business "Ecobalyse" (User.sirenFromString sampleValidSiren)))
                )
            , it "should fail to decode a business with an invalid siren"
                ("""{"type": "business", "name": "Ecobalyse", "siren": "invalid"}"""
                    |> Decode.decodeString User.decodeOrganization
                    |> Result.mapError Decode.errorToString
                    |> TU.expectResultErrorContains "exactement 9 chiffres"
                )
            , it "should decode an individual"
                ("""{"type": "individual"}"""
                    |> Decode.decodeString User.decodeOrganization
                    |> Expect.equal (Ok User.Individual)
                )
            , it
                "should decode an association"
                ("""{"type": "association", "name": "Ecobalyse"}"""
                    |> Decode.decodeString User.decodeOrganization
                    |> Expect.equal (Ok (User.Association "Ecobalyse"))
                )
            , it "should decode an education organization"
                ("""{"type": "education", "name": "Université Paris VIII"}"""
                    |> Decode.decodeString User.decodeOrganization
                    |> Expect.equal (Ok (User.Education "Université Paris VIII"))
                )
            , it "should decode an local authority"
                ("""{"type": "localAuthority", "name": "Région Île-de-France"}"""
                    |> Decode.decodeString User.decodeOrganization
                    |> Expect.equal (Ok (User.LocalAuthority "Région Île-de-France"))
                )
            , it "should decode a media"
                ("""{"type": "media", "name": "Le Monde"}"""
                    |> Decode.decodeString User.decodeOrganization
                    |> Expect.equal (Ok (User.Media "Le Monde"))
                )
            , it "should decode a public organization"
                ("""{"type": "public", "name": "Ministère de l'Ecologie"}"""
                    |> Decode.decodeString User.decodeOrganization
                    |> Expect.equal (Ok (User.Public "Ministère de l'Ecologie"))
                )
            , it "should fail on unmatched expectation"
                ("""{"type": "other"}"""
                    |> Decode.decodeString User.decodeOrganization
                    |> Result.mapError Decode.errorToString
                    |> TU.expectResultErrorContains "Unmatched expected value"
                )
            ]
        , describe "encodeOrganization"
            [ it "should encode a business"
                (User.Business "Ecobalyse" (User.sirenFromString sampleValidSiren)
                    |> User.encodeOrganization
                    |> Expect.equal
                        (Encode.object
                            [ ( "type", Encode.string "business" )
                            , ( "name", Encode.string "Ecobalyse" )
                            , ( "siren", Encode.string sampleValidSiren )
                            ]
                        )
                )
            ]
        , describe "validateEmail"
            [ it "should validate a well-formed email"
                (User.validateEmailForm "user@tld.org"
                    |> Expect.equal Dict.empty
                )
            , it "should invalidate an email with no @ symbol"
                (User.validateEmailForm "user.tld.org"
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            , it "should invalidate an email with a space"
                (User.validateEmailForm "user@tld. org"
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            , it "should invalidate an email with spaces"
                (User.validateEmailForm "  @  .  "
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            , it "should invalidate an email without ext"
                (User.validateEmailForm "user@tld"
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            , it "should invalidate a totally invalid email"
                (User.validateEmailForm "invalid-email"
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            ]
        , let
            validForm =
                { ecoinventTermsAccepted = False
                , email = "user@tld.org"
                , firstName = "John"
                , lastName = "Doe"
                , emailOptin = True
                , organization = User.Public "Ecobalyse"
                , termsAccepted = True
                }
          in
          describe "validateSignupForm"
            [ it "should validate a well-formed signup form"
                (User.validateSignupForm validForm
                    |> Expect.equal Dict.empty
                )
            , it "should invalidate a signup form with an invalid email"
                (User.validateSignupForm { validForm | email = "user.tld.org" }
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            , it "should invalidate a signup form with an empty first name"
                (User.validateSignupForm { validForm | firstName = "" }
                    |> Expect.equal (Dict.singleton "firstName" "Le champ est obligatoire")
                )
            , it "should invalidate a signup form with an empty last name"
                (User.validateSignupForm { validForm | lastName = "" }
                    |> Expect.equal (Dict.singleton "lastName" "Le champ est obligatoire")
                )
            , it "should invalidate a signup form with an invalid organization"
                (User.validateSignupForm { validForm | organization = User.Public "" }
                    |> Expect.equal (Dict.singleton "organization.name" "Le champ est obligatoire")
                )
            , it "should invalidate a signup form with several erroneous field values"
                (User.validateSignupForm { emptySignupForm | organization = User.Business "" (User.sirenFromString sampleValidSiren) }
                    |> Expect.equal
                        (Dict.fromList
                            [ ( "email", "L'adresse e-mail est invalide" )
                            , ( "firstName", "Le champ est obligatoire" )
                            , ( "lastName", "Le champ est obligatoire" )
                            , ( "organization.name", "Le champ est obligatoire" )
                            , ( "termsAccepted", "Les CGU doivent être acceptées" )
                            ]
                        )
                )
            ]
        , describe "validateSiren"
            [ it "should validate a well-formed siren"
                (User.validateSiren sampleValidSiren
                    |> Expect.equal (Ok (User.sirenFromString sampleValidSiren))
                )
            , [ ( "732829321", "Le numéro SIREN est invalide" )
              , ( "12345678", "Le numéro SIREN doit contenir exactement 9 chiffres" )
              , ( "1234567890", "Le numéro SIREN doit contenir exactement 9 chiffres" )
              , ( "12345678a", "Le numéro SIREN ne doit contenir que des chiffres" )
              , ( "110068011", "Le numéro SIREN est invalide" )
              ]
                |> List.map
                    (\( input, expectedError ) ->
                        User.validateSiren input
                            |> TU.expectResultErrorContains expectedError
                            |> it ("should discard " ++ input ++ " with error " ++ expectedError)
                    )
                |> describe "should handle error messages"
            ]
        ]


sampleValidSiren : String
sampleValidSiren =
    -- Note: MTE siret number
    "110068012"


userJson : String
userJson =
    """
    {
        "email": "user@tld.org",
        "id": "8c1f1647-eccd-4fe6-a11b-0a049cc46d9f",
        "isActive": true,
        "isSuperuser": false,
        "isVerified": false,
        "magicLinkSentAt": null,
        "hasActiveToken": false,
        "profile": {
            "firstName": "John",
            "lastName": "Doe",
            "emailOptin": false,
            "organization": {"type": "public", "name": "Ecobalyse"},
            "termsAccepted": true
        },
        "roles": []
    }
    """
