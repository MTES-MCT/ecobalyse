module Server.ServerTest exposing (..)

import Data.Food.Query as BuilderQuery
import Expect
import Json.Encode as Encode
import Server
import Server.Request exposing (Request)
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


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
                    |> request "GET" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 404
                    |> asTest "should catch invalid endpoints"

                -- GET queries
                , "/food/recipe?ingredients[]=invalid"
                    |> request "GET" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 400
                    |> asTest "should reject an invalid GET query"
                , "/food/recipe?ingredients[]=egg;120"
                    |> request "GET" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 200
                    |> asTest "should accept a valid GET query"

                -- POST queries
                , "/food/recipe"
                    |> request "POST" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 400
                    |> asTest "should reject an invalid POST query"
                , "/food/recipe"
                    |> request "POST" (BuilderQuery.encode BuilderQuery.carrotCake)
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 200
                    |> asTest "should accept a valid POST query"
                ]
            ]
        )


request : String -> Encode.Value -> String -> Request
request method body url =
    { method = method
    , url = url
    , body = body
    , jsResponseHandler = Encode.null
    }
