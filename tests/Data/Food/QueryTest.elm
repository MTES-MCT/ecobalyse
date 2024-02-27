module Data.Food.QueryTest exposing (..)

import Data.Food.Query as Query
import Expect
import Json.Encode as Encode
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Food.Query"
        [ describe "encodeExampleProducts"
            [ Query.encodeExampleProducts Query.exampleProducts
                |> Encode.encode 2
                |> String.length
                |> Expect.greaterThan 0
                |> asTest "should encode example products"
            ]
        ]
