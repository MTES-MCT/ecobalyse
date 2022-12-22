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
        , describe "parseIsIsnt"
            [ let
                sampleMarkdown =
                    String.join "\n\n"
                        [ String.join "\n"
                            [ "---"
                            , "description: >-"
                            , "  Accélérer la mise en place de l'affichage environnemental autour d'un"
                            , "  calculateur pédagogique et collaboratif."
                            , "---"
                            ]
                        , "# title"
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
                    (Ok
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
