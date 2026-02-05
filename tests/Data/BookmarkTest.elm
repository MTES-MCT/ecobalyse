module Data.BookmarkTest exposing (..)

import Data.Bookmark as Bookmark
import Data.Session as Session
import Expect
import Json.Decode as Decode
import Test exposing (..)
import TestUtils exposing (it)


suite : Test
suite =
    describe "Data.Session"
        [ describe "bookmarks should"
            [ it "be moved correctly from top to bottom"
                ([ 1, 2, 3, 4 ]
                    |> Session.moveListElement 1 3
                    |> Expect.equal [ 2, 3, 1, 4 ]
                )
            , it "be moved correctly from bottom to top"
                ([ 1, 2, 3, 4 ]
                    |> Session.moveListElement 3 1
                    |> Expect.equal [ 3, 1, 2, 4 ]
                )
            , it "not be moved if there is nothing to move"
                ([ 1, 2, 3, 4 ]
                    |> Session.moveListElement 1 1
                    |> Expect.equal [ 1, 2, 3, 4 ]
                )
            , it "not be moved if indexes are out of bounds"
                ([ 1, 2, 3, 4 ]
                    |> Session.moveListElement 5 6
                    |> Expect.equal [ 1, 2, 3, 4 ]
                )
            ]
        , describe "decodeJsonList"
            [ it "should exclude invalid bookmarks and retain valid ones"
                (case Decode.decodeString Bookmark.decodeJsonList sampleJsonBookmarks of
                    Ok list ->
                        list
                            |> List.map .name
                            |> Expect.equal [ "first valid bookmark", "second valid bookmark", "third valid bookmark" ]

                    Err err ->
                        Expect.fail ("Erreur de décodage: " ++ Decode.errorToString err)
                )
            ]
        ]


sampleJsonBookmarks =
    """
[
    {
        "created": 1767710889190,
        "name": "first valid bookmark",
        "query": {
            "mass": 0.15,
            "materials": [
                {
                    "id": "62a4d6fb-3276-4ba5-93a3-889ecd3bff84",
                    "share": 1
                }
            ],
            "product": "tshirt"
        }
    },
    {
        "created": 1767710889191,
        "name": "invalid JSON bookmark with missing product category",
        "query": {
            "mass": 0.15,
            "materials": [
                {
                    "id": "62a4d6fb-3276-4ba5-93a3-889ecd3bff84",
                    "share": 1
                }
            ]
        }
    },
    {
        "created": 1767710889192,
        "name": "invalid JSON bookmark with too much material",
        "query": {
            "mass": 0.15,
            "materials": [
                {
                    "id": "62a4d6fb-3276-4ba5-93a3-889ecd3bff84",
                    "share": 1.5
                }
            ]
        }
    },
    {
        "created": 1767710889193,
        "name": "second valid bookmark",
        "query": {
            "mass": 0.15,
            "materials": [
                {
                    "id": "62a4d6fb-3276-4ba5-93a3-889ecd3bff84",
                    "share": 1
                }
            ],
            "product": "pantalon"
        }
    },
    "{\\"created\\":1767710889193,\\"name\\":\\"third valid bookmark\\",\\"query\\":{\\"mass\\":0.15,\\"materials\\":[{\\"id\\":\\"62a4d6fb-3276-4ba5-93a3-889ecd3bff84\\",\\"share\\":1}],\\"product\\":\\"pantalon\\"}}"
]
"""
