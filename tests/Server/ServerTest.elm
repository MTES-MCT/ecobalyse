module Server.ServerTest exposing (..)

import Data.Food.Query as FoodQuery
import Expect
import Json.Encode as Encode
import Server
import Test exposing (..)
import TestUtils exposing (asTest, createServerRequest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Server"
        (\dbs ->
            [ describe "ports"
                -- Note: these prevent false elm-review reports
                [ Server.input (always Sub.none)
                    |> Expect.notEqual Sub.none
                    |> asTest "should apply input subscription"
                , Server.output Encode.null
                    |> Expect.notEqual Cmd.none
                    |> asTest "should apply output command"
                ]
            , describe "handleRequest"
                [ "/invalid"
                    |> createServerRequest dbs "GET" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 404
                    |> asTest "should catch invalid endpoints"

                -- GET queries
                , "/food?ingredients[]=invalid"
                    |> createServerRequest dbs "GET" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 400
                    |> asTest "should reject an invalid GET query"
                , "/food?ingredients[]=9cbc31e9-80a4-4b87-ac4b-ddc051c47f69;120"
                    |> createServerRequest dbs "GET" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 200
                    |> asTest "should accept a valid GET query"

                -- POST queries
                , "/food"
                    |> createServerRequest dbs "POST" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 400
                    |> asTest "should reject an invalid POST query"
                , "/food"
                    |> createServerRequest dbs "POST" (FoodQuery.encode FoodQuery.empty)
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 200
                    |> asTest "should accept a valid POST query"
                ]
            ]
        )
