module Data.GitbookTest exposing (..)

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
            , Gitbook.handleMarkdownGitbookLink (Just Gitbook.MaterialAndSpinning) "http://google.com"
                |> Expect.equal "http://google.com"
                |> asTest "should resolve an external link even with a path provided"
            , Gitbook.handleMarkdownGitbookLink (Just Gitbook.MaterialAndSpinning) "filature.md"
                -- FIXME-RENAME
                |> Expect.equal "https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/filature"
                |> asTest "should resolve an internal link from current page path"
            , Gitbook.handleMarkdownGitbookLink (Just Gitbook.MaterialAndSpinning) "../faq.md"
                -- FIXME-RENAME
                |> Expect.equal "https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/../faq"
                |> asTest "should resolve an internal link from current page path down a folder level"
            , Gitbook.handleMarkdownGitbookLink (Just Gitbook.MaterialAndSpinning) "foo/bar.md"
                -- FIXME-RENAME
                |> Expect.equal "https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/foo/bar"
                |> asTest "should resolve an internal link from current page path up a folder level"
            ]
        , describe "parseIsIsnt"
            [ let
                sampleMarkdown =
                    String.join "\n\n"
                        [ "# title"
                        , "stuff"
                        , "## is"
                        , "### isitem1"
                        , "desc_is_item1"
                        , "### isitem2"
                        , "desc_is_item2"
                        , "## isnt"
                        , "### isntitem1"
                        , "desc_isnt_item1"
                        , "### isntitem2"
                        , "desc_isnt_item2"
                        ]
              in
              Gitbook.parseIsIsnt sampleMarkdown
                |> Expect.equal
                    (Just
                        { is =
                            ( "is"
                            , [ ( "isitem1", "desc_is_item1" )
                              , ( "isitem2", "desc_is_item2" )
                              ]
                            )
                        , isnt =
                            ( "isnt"
                            , [ ( "isntitem1", "desc_isnt_item1" )
                              , ( "isntitem2", "desc_isnt_item2" )
                              ]
                            )
                        }
                    )
                |> asTest "should parse Ecobalyse is/isn't Markown content"
            ]
        ]
