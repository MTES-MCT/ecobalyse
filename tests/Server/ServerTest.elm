module Server.ServerTest exposing (..)

import Data.Food.Ingredient as Ingredient
import Data.Food.Query as FoodQuery
import Expect
import Json.Encode as Encode
import Mass
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
                [ Encode.null
                    |> createServerRequest dbs
                        { method = "GET"
                        , protocol = "http"
                        , host = "fqdn"
                        , url = "/invalid"
                        , version = Nothing
                        }
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 404
                    |> asTest "should catch invalid endpoints"

                -- POST queries
                , Encode.null
                    |> createServerRequest dbs
                        { method = "POST"
                        , protocol = "http"
                        , host = "fqdn"
                        , url = "/food"
                        , version = Nothing
                        }
                    |> Server.handleRequest dbs
                    |> Tuple.first
                    |> Expect.equal 400
                    |> asTest "should reject an invalid POST query"
                , asTest "should accept a valid POST query" <|
                    case List.head dbs.food.ingredients |> Maybe.map .id of
                        Just id ->
                            FoodQuery.encode
                                { distribution = Nothing
                                , ingredients =
                                    [ { country = Nothing
                                      , id = id
                                      , mass = Mass.kilogram
                                      , planeTransport = Ingredient.NoPlane
                                      }
                                    ]
                                , packaging = []
                                , preparation = []
                                , transform = Nothing
                                }
                                |> createServerRequest dbs
                                    { method = "POST"
                                    , protocol = "http"
                                    , host = "fqdn"
                                    , url = "/food"
                                    , version = Nothing
                                    }
                                |> Server.handleRequest dbs
                                |> Tuple.first
                                |> Expect.equal 200

                        Nothing ->
                            Expect.fail "No ingredients"
                ]
            ]
        )
