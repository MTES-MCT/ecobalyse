module Server.ServerTest exposing (..)

import Data.Food.Process as FoodProcess
import Data.Food.Query as FoodQuery
import Data.Textile.Process as TextileProcess
import Expect
import Json.Encode as Encode
import Server
import Server.Request exposing (Request)
import Static.Db as StaticDb
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
                    |> request dbs "GET" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 404
                    |> asTest "should catch invalid endpoints"

                -- GET queries
                , "/food?ingredients[]=invalid"
                    |> request dbs "GET" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 400
                    |> asTest "should reject an invalid GET query"
                , "/food?ingredients[]=egg-indoor-code3;120"
                    |> request dbs "GET" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 200
                    |> asTest "should accept a valid GET query"

                -- POST queries
                , "/food"
                    |> request dbs "POST" Encode.null
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 400
                    |> asTest "should reject an invalid POST query"
                , "/food"
                    |> request dbs "POST" (FoodQuery.encode FoodQuery.empty)
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 200
                    |> asTest "should accept a valid POST query"
                ]
            ]
        )


request : StaticDb.Db -> String -> Encode.Value -> String -> Request
request dbs method body url =
    { method = method
    , url = url
    , body = body
    , processes = { foodProcesses = Encode.list FoodProcess.encode dbs.food.processes |> Encode.encode 0, textileProcesses = Encode.list TextileProcess.encode dbs.textile.processes |> Encode.encode 0 }
    , jsResponseHandler = Encode.null
    }
