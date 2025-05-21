module Data.Common.EncodeUtilsTest exposing (..)

import Data.Common.EncodeUtils as EU
import Expect
import Json.Decode as Decode
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Test exposing (..)
import TestUtils exposing (it)
import Time


suite : Test
suite =
    describe "Data.Common.EncodeUtils"
        [ describe "datetime"
            [ it "should encode a JSON datetime (ISO 8601)"
                (Time.millisToPosix 1747808239192
                    |> EU.datetime
                    |> Encode.encode 0
                    |> Expect.equal "\"2025-05-21T06:17:19.192Z\""
                )
            , it "should generate a JSON datetime that can be decoded back to the original datetime"
                (Time.millisToPosix 1747808239192
                    |> EU.datetime
                    |> Encode.encode 0
                    |> Decode.decodeString DE.datetime
                    |> Expect.equal (Ok (Time.millisToPosix 1747808239192))
                )
            ]
        ]
