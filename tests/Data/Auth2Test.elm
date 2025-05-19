module Data.Auth2Test exposing (..)

import Data.User2 as User
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
