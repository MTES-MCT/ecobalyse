module Data.BookmarkTest exposing (..)

import Data.Bookmark as Bookmark
import Data.Component as Component
import Data.Sector as Sector
import Data.Session as Session
import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (..)
import TestUtils exposing (it)
import Time


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
            , it "should encode and decode generic food2 bookmarks"
                ([ { created = Time.millisToPosix 1
                   , genericSector = Just Sector.Food2
                   , name = "food2 bookmark"
                   , query = Bookmark.Generic Sector.Food2 Component.emptyQuery
                   }
                 ]
                    |> Bookmark.encodeJsonList
                    |> Encode.encode 0
                    |> expectQueryDecoded (Bookmark.Generic Sector.Food2 Component.emptyQuery)
                )
            , it "should encode and decode generic object bookmarks"
                ([ { created = Time.millisToPosix 1
                   , genericSector = Just Sector.Object
                   , name = "object bookmark"
                   , query = Bookmark.Generic Sector.Object Component.emptyQuery
                   }
                 ]
                    |> Bookmark.encodeJsonList
                    |> Encode.encode 0
                    |> expectQueryDecoded (Bookmark.Generic Sector.Object Component.emptyQuery)
                )
            , it "should encode and decode generic veli bookmarks"
                ([ { created = Time.millisToPosix 1
                   , genericSector = Just Sector.Veli
                   , name = "veli bookmark"
                   , query = Bookmark.Generic Sector.Veli Component.emptyQuery
                   }
                 ]
                    |> Bookmark.encodeJsonList
                    |> Encode.encode 0
                    |> expectQueryDecoded (Bookmark.Generic Sector.Veli Component.emptyQuery)
                )
            , it "should encode and decode generic bookmarks when genericSector field is missing"
                ([ { created = Time.millisToPosix 1
                   , genericSector = Nothing
                   , name = "food2 bookmark"
                   , query = Bookmark.Generic Sector.Food2 Component.emptyQuery
                   }
                 ]
                    |> Bookmark.encodeJsonList
                    |> Encode.encode 0
                    |> expectQueryDecoded (Bookmark.Generic Sector.Food2 Component.emptyQuery)
                )
            , it "should decode a sectored generic bookmark"
                ("""
                 [{
                     "created": 1,
                     "name": "veli bookmark",
                     "query": { "components": [] },
                     "subScope": "veli"
                 }]
                 """
                    |> expectQueryDecoded (Bookmark.Generic Sector.Veli Component.emptyQuery)
                )
            ]
        , describe "findByGenericQuery"
            [ it "should find a bookmark for the matching generic sector"
                (let
                    food2Bookmark =
                        { created = Time.millisToPosix 1
                        , genericSector = Just Sector.Food2
                        , name = "food2 bookmark"
                        , query = Bookmark.Generic Sector.Food2 Component.emptyQuery
                        }

                    objectBookmark =
                        { created = Time.millisToPosix 2
                        , genericSector = Just Sector.Object
                        , name = "object bookmark"
                        , query = Bookmark.Generic Sector.Object Component.emptyQuery
                        }
                 in
                 [ food2Bookmark, objectBookmark ]
                    |> Bookmark.findByGenericQuery Sector.Food2 Component.emptyQuery
                    |> Expect.equal (Just food2Bookmark)
                )
            , it "should not match a bookmark from another generic sector"
                ([ { created = Time.millisToPosix 1
                   , genericSector = Just Sector.Object
                   , name = "object bookmark"
                   , query = Bookmark.Generic Sector.Object Component.emptyQuery
                   }
                 ]
                    |> Bookmark.findByGenericQuery Sector.Veli Component.emptyQuery
                    |> Expect.equal Nothing
                )
            ]
        ]


expectQueryDecoded : Bookmark.Query -> String -> Expect.Expectation
expectQueryDecoded expectedQuery rawBookmarksJson =
    case Decode.decodeString Bookmark.decodeJsonList rawBookmarksJson of
        Ok [ { query } ] ->
            query |> Expect.equal expectedQuery

        Ok _ ->
            Expect.fail "Expected exactly one bookmark"

        Err err ->
            Expect.fail ("Decoding failed: " ++ Decode.errorToString err)


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
