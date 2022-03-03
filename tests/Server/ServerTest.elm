module Server.ServerTest exposing (..)

import Expect
import Json.Encode as Encode
import Server
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Server"
        [ describe "ports"
            -- Note: these prevent false elm-review reports
            [ Server.input (always Sub.none)
                |> Expect.notEqual Sub.none
                |> asTest "should apply input subscription"
            , Server.output Encode.null
                |> Expect.notEqual Cmd.none
                |> asTest "should apply output command"
            ]
        ]
