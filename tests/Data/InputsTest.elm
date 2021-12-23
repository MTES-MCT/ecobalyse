module Data.InputsTest exposing (..)

import Data.Inputs as Inputs
import Expect exposing (Expectation)
import Test exposing (..)
import TestDb exposing (testDb)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


sampleQuery : Inputs.Query
sampleQuery =
    Inputs.jupeCircuitAsie


suite : Test
suite =
    case testDb of
        Ok db ->
            describe "Data.Inputs"
                [ describe "Encoding and decoding queries"
                    [ sampleQuery
                        |> Inputs.fromQuery db
                        |> Result.map Inputs.toQuery
                        |> Expect.equal (Ok sampleQuery)
                        |> asTest "should encode and decode a query"
                    ]
                , describe "Base64 encoding and decoding queries"
                    [ sampleQuery
                        |> Inputs.b64encode
                        |> Inputs.b64decode
                        |> Expect.equal (Ok sampleQuery)
                        |> asTest "should base64 encode and decode a query"
                    ]
                ]

        Err error ->
            describe "Data.Inputs"
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
