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
                ("Abc1 - dE1f / h2Ij (3klM) été"
                    |> Text.toWords
                    |> Expect.equal [ "abc1", "de1f", "h2ij", "3klm", "ete" ]
                )
            ]
        ]
