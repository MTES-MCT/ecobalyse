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
        , """{"ingredients": [{"id":"mango","mass":500,"country":"BR"}],"transform":null,"packaging":[],"distribution":"ambient","preparation":[]}"""
            |> Decode.decodeString Query.decode
            |> Expect.ok
            |> asTest "should decode a null transform"
        , """{"ingredients": [{"id":"mango","mass":500,"country":"BR"}],"packaging":[],"distribution":"ambient","preparation":[]}"""
            |> Decode.decodeString Query.decode
            |> Expect.ok
            |> asTest "should decode a missing transform"
        , """{"ingredients": [{"id":"mango","mass":500,"country":"BR"}],"packaging":[],"distribution":"invalid","preparation":[]}"""
            |> Decode.decodeString Query.decode
            |> Expect.err
            |> asTest "should fail an invalid distribution"
        ]
