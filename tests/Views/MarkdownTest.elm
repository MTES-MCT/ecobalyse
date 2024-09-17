module Views.MarkdownTest exposing (..)

import Expect
import Html exposing (..)
import Test exposing (..)
import TestUtils exposing (asTest)
import Views.Markdown as Markdown


suite : Test
suite =
    describe "Views.Markdown"
        [ describe "Markdown.parse"
            -- NOTE: unfortunately, failing test results will show <internals> in diffs,
            -- making it super hard to debug. I couldn't identify any solution to this,
            -- yet it's important to have this test ensuring the very basics work.
            [ "plop"
                |> Markdown.parse
                |> Expect.equal (Ok [ p [] [ text "plop" ] ])
                |> asTest "should parse the simplest Markdown string"
            ]
        ]
