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
        , """{"mass":1000,"ingredients":[{"id":"mango","mass":500,"share":100,"country":"BR"}],"transform":null,"packaging":[],"distribution":"ambient","preparation":[]}"""
            |> Decode.decodeString Query.decode
            |> Expect.ok
            |> asTest "should decode a null transform"
        , """{"mass":1000,"ingredients":[{"id":"mango","mass":500,"share":100,"country":"BR"}],"packaging":[],"distribution":"ambient","preparation":[]}"""
            |> Decode.decodeString Query.decode
            |> Expect.ok
            |> asTest "should decode a missing transform"
        , """{"mass":1000,"ingredients":[{"id":"mango","mass":500,"share":100,"country":"BR"}],"packaging":[],"distribution":"invalid","preparation":[]}"""
            |> Decode.decodeString Query.decode
            |> Expect.err
            |> asTest "should fail on invalid distribution"
        ]
