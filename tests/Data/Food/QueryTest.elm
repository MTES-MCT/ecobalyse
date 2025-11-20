module Data.Food.QueryTest exposing (..)

import Data.Food.Query as Query
import Expect
import Json.Decode as Decode
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Food.Query"
        [ "<invalid json>"
            |> Decode.decodeString Query.decode
            |> Expect.err
            |> asTest "should fail on invalid JSON"
        , """{"ingredients": [{"id":"db0e5f44-34b4-4160-b003-77c828d75e60","mass":500,"geoZone":"BR"}],"transform":null,"packaging":[],"distribution":"ambient","preparation":[]}"""
            |> Decode.decodeString Query.decode
            |> Expect.ok
            |> asTest "should decode a null transform"
        , """{"ingredients": [{"id":"db0e5f44-34b4-4160-b003-77c828d75e60","mass":500,"geoZone":"BR"}],"packaging":[],"distribution":"ambient","preparation":[]}"""
            |> Decode.decodeString Query.decode
            |> Expect.ok
            |> asTest "should decode a missing transform"
        , """{"ingredients": [{"id":"db0e5f44-34b4-4160-b003-77c828d75e60","mass":500,"geoZone":"BR"}],"packaging":[],"distribution":"invalid","preparation":[]}"""
            |> Decode.decodeString Query.decode
            |> Expect.err
            |> asTest "should fail an invalid distribution"
        ]
