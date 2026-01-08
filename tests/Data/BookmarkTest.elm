module Data.BookmarkTest exposing (..)

import Data.Session as Session
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Session"
        [ describe "bookmarks should"
            [ asTest "be moved correctly from top to bottom"
                ([ 1, 2, 3, 4 ]
                    |> Session.moveListElement 1 3
                    |> Expect.equal [ 2, 3, 1, 4 ]
                )
            , asTest "be moved correctly from bottom to top"
                ([ 1, 2, 3, 4 ]
                    |> Session.moveListElement 3 1
                    |> Expect.equal [ 3, 1, 2, 4 ]
                )
            , asTest "not be moved if there is nothing to move"
                ([ 1, 2, 3, 4 ]
                    |> Session.moveListElement 1 1
                    |> Expect.equal [ 1, 2, 3, 4 ]
                )
            , asTest "not be moved if indexes are out of bounds"
                ([ 1, 2, 3, 4 ]
                    |> Session.moveListElement 5 6
                    |> Expect.equal [ 1, 2, 3, 4 ]
                )
            ]
        ]
