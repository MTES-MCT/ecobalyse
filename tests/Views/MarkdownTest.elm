module Views.MarkdownTest exposing (..)

import Data.Gitbook as Gitbook
import Expect
import Html exposing (..)
import Test exposing (..)
import TestUtils exposing (asTest)
import Views.Markdown as Markdown


gitbookPage : String -> Gitbook.Page
gitbookPage md =
    { title = ""
    , description = Nothing
    , path = Gitbook.TextileUse
    , markdown = md
    }


suite : Test
suite =
    describe "Views.Markdown"
        [ describe "Markdown.parse"
            -- NOTE: unfortunately, failing test results will show <internals> in diffs,
            -- making it super hard to debug. I couldn't identify any solution to this,
            -- yet it's important to have this test ensuring the very basics work.
            [ "plop"
                |> Markdown.Simple
                |> Markdown.parse
                |> Expect.equal (Ok [ p [] [ text "plop" ] ])
                |> asTest "should parse the simplest Markdown string"
            , gitbookPage "plop"
                |> Markdown.Gitbook
                |> Markdown.parse
                |> Expect.equal (Ok [ p [] [ text "plop" ] ])
                |> asTest "should parse the simplest Gitbook page Markdown string"
            , gitbookPage "Foo & Bar"
                |> Markdown.Gitbook
                |> Markdown.parse
                |> Expect.equal (Ok [ p [] [ text "Foo & Bar" ] ])
                |> asTest "should handle Gitbook page HTML entities in Markdown string"
            ]
        ]
