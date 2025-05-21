module Data.User2Test exposing (..)

import Data.User2 as User
import Dict
import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)
import TestUtils exposing (it)


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
        , describe "validateEmail"
            [ it "should validate a well-formed email"
                (User.validateEmail "user@tld.org"
                    |> Expect.equal Dict.empty
                )
            , it "should invalidate an email with no @ symbol"
                (User.validateEmail "user.tld.org"
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            , it "should invalidate an email with a space"
                (User.validateEmail "user@tld. org"
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            , it "should invalidate an email with spaces"
                (User.validateEmail "  @  .  "
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            , it "should invalidate an email without ext"
                (User.validateEmail "user@tld"
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            , it "should invalidate a totally invalid email"
                (User.validateEmail "invalid-email"
                    |> Expect.equal (Dict.singleton "email" "L'adresse e-mail est invalide")
                )
            ]
        , let
            validForm =
                { email = "user@tld.org"
                , firstName = "John"
                , lastName = "Doe"
                , organization = "Ecobalyse"
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
            , it "should invalidate a signup form with an empty organization"
                (User.validateSignupForm { validForm | organization = "" }
                    |> Expect.equal (Dict.singleton "organization" "Le champ est obligatoire")
                )
            , it "should invalidate a signup form with termsAccepted set to False"
                (User.validateSignupForm { validForm | termsAccepted = False }
                    |> Expect.equal (Dict.singleton "termsAccepted" "Les CGU doivent être acceptées")
                )
            , it "should invalidate a signup form with several erroneous field values"
                (User.validateSignupForm User.emptySignupForm
                    |> Expect.equal
                        (Dict.fromList
                            [ ( "email", "L'adresse e-mail est invalide" )
                            , ( "firstName", "Le champ est obligatoire" )
                            , ( "lastName", "Le champ est obligatoire" )
                            , ( "organization", "Le champ est obligatoire" )
                            , ( "termsAccepted", "Les CGU doivent être acceptées" )
                            ]
                        )
                )
            ]
        ]


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
        "profile": {
            "firstName": "John",
            "lastName": "Doe",
            "organization": "Ecobalyse",
            "termsAccepted": true
        },
        "roles": []
    }
    """
