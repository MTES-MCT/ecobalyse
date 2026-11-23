module Views.FormatTest exposing (..)

import Data.Split as Split
import Expect
import Html exposing (text)
import Test exposing (..)
import TestUtils exposing (asTest)
import Views.Format as RichFormat


suite : Test
suite =
    describe "Views.Format"
        [ describe "Format.percentage"
            [ 0.12
                |> Split.fromFloat
                |> Result.map (RichFormat.splitAsPercentage 0)
                |> Expect.equal (Ok (text "12\u{202F}%"))
                |> asTest "should properly format a Split as percentage"
            , 0.12
                |> Split.fromFloat
                |> Result.map (RichFormat.splitAsFloat 1)
                |> Expect.equal (Ok (text "0,1"))
                |> asTest "should properly format a Split as float"
            ]
        ]
