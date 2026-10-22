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
                (Text.toWords "Abc1 - dE1f / h2Ij (3klM) été-hiver"
                    |> Expect.equal [ "abc1", "de1f", "h2ij", "3klm", "ete", "hiver" ]
                )
            ]
        , describe "search"
            [ it "should not search a list when not enough chars are provided"
                (sampleItems
                    |> Text.search { minQueryLength = 2, query = "x", toSearchableText = Text.toSearchable }
                    |> Expect.equal sampleItems
                )
            , it "should search a term placing exact word matches first"
                (sampleItems
                    |> Text.search { minQueryLength = 2, query = "def", toSearchableText = Text.toSearchable }
                    |> List.head
                    |> Expect.equal (Just "def")
                )
            , it "should search a term placing exact word matches first, partial matches second"
                (sampleItems
                    |> Text.search { minQueryLength = 2, query = "def", toSearchableText = Text.toSearchable }
                    |> Expect.equal [ "def", "abc def", "defy" ]
                )
            , it "should require every word of a multiple words query"
                (sampleItems
                    |> Text.search { minQueryLength = 2, query = "abc def", toSearchableText = Text.toSearchable }
                    |> Expect.equal [ "abc def" ]
                )
            , it "should drop items that match neither exactly nor partially"
                (sampleItems
                    |> Text.search { minQueryLength = 2, query = "zzz", toSearchableText = Text.toSearchable }
                    |> Expect.equal []
                )
            , it "should match accented letters as their unaccented form"
                ([ "Été", "ete hiver", "hotel" ]
                    |> Text.search { minQueryLength = 2, query = "été", toSearchableText = Text.toSearchable }
                    |> Expect.equal [ "Été", "ete hiver" ]
                )
            ]
        ]


sampleItems : List String
sampleItems =
    [ "abc", "defy", "def", "ghi", "abc def" ]
