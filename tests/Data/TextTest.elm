module Data.TextTest exposing (suite)

import Data.Text as Text
import Expect
import Test exposing (..)
import TestUtils exposing (it)


suite : Test
suite =
    describe "Data.Text"
        [ describe "toWords"
            [ it "should transform a string to a list of searchable words"
                ("Abc1 - dE1f / h2Ij (3klM) été-hiver"
                    |> Text.toWords
                    |> Expect.equal [ "abc1", "de1f", "h2ij", "3klm", "ete", "hiver" ]
                )
            ]
        , describe "search"
            [ it "should not search a list when not enough chars are provided"
                (sampleItems
                    |> Text.search { minQueryLength = 2, query = "x", toString = identity }
                    |> Expect.equal sampleItems
                )
            , it "should sort a single result placing exact word match first"
                (sampleItems
                    |> Text.search { minQueryLength = 2, query = "def", toString = identity }
                    |> List.head
                    |> Expect.equal (Just "def")
                )
            , it "should sort multiple results placing exact word matches first"
                (sampleItems
                    |> Text.search { minQueryLength = 2, query = "def", toString = identity }
                    |> Expect.equal [ "def", "abc def", "defy" ]
                )
            ]
        ]


sampleItems : List String
sampleItems =
    [ "abc", "defy", "def", "ghi", "abc def" ]
