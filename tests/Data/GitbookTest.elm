module Data.GitbookTest exposing (..)

import Data.Env as Env
import Data.Gitbook as Gitbook
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Gitbook"
        [ describe "handleMarkdownLink"
            [ Gitbook.handleMarkdownGitbookLink Nothing "http://google.com"
                |> Expect.equal "http://google.com"
                |> asTest "should resolve an external link"
            , Gitbook.handleMarkdownGitbookLink (Just Gitbook.TextileMaterialAndSpinning) "http://google.com"
                |> Expect.equal "http://google.com"
                |> asTest "should resolve an external link even with a path provided"
            , Gitbook.handleMarkdownGitbookLink (Just Gitbook.TextileMaterialAndSpinning) "filature.md"
                |> Expect.equal (Env.gitbookUrl ++ "/textile/filature")
                |> asTest "should resolve an internal link from current page path"
            , Gitbook.handleMarkdownGitbookLink (Just Gitbook.TextileMaterialAndSpinning) "../faq.md"
                |> Expect.equal (Env.gitbookUrl ++ "/textile/../faq")
                |> asTest "should resolve an internal link from current page path down a folder level"
            , Gitbook.handleMarkdownGitbookLink (Just Gitbook.TextileMaterialAndSpinning) "foo/bar.md"
                |> Expect.equal (Env.gitbookUrl ++ "/textile/foo/bar")
                |> asTest "should resolve an internal link from current page path up a folder level"
            ]
        ]
