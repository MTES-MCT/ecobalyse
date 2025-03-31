module Request.VersionTest exposing (..)

import Expect
import Http exposing (Error(..))
import RemoteData exposing (RemoteData(..))
import Request.Version as Version exposing (Version(..))
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Request.Version"
        [ describe "updateVersion"
            [ describe "Failed poll"
                [ Failure (BadBody "bad body")
                    |> Version.updateVersion Unknown
                    |> Expect.equal Unknown
                    |> asTest "should leave the current version unchanged (Unknown) if the poll failed"
                , Failure (BadBody "bad body")
                    |> Version.updateVersion (Version { hash = "hash", tag = Nothing })
                    |> Expect.equal (Version { hash = "hash", tag = Nothing })
                    |> asTest "should leave the current version unchanged (Version ...) if the poll failed"
                , Failure (BadBody "bad body")
                    |> Version.updateVersion (NewerVersion { hash = "hash", tag = Just "tag" } { hash = "hash", tag = Just "tag" })
                    |> Expect.equal (NewerVersion { hash = "hash", tag = Just "tag" } { hash = "hash", tag = Just "tag" })
                    |> asTest "should leave the current version unchanged (NewerVersion) if the poll failed"
                ]
            , describe "Successful poll"
                [ Success { hash = "hash", tag = Nothing }
                    |> Version.updateVersion Unknown
                    |> Expect.equal (Version { hash = "hash", tag = Nothing })
                    |> asTest "should go from Unknown to Version ..."
                , Success { hash = "hash", tag = Just "tag" }
                    |> Version.updateVersion (Version { hash = "hash", tag = Just "tag" })
                    |> Expect.equal (Version { hash = "hash", tag = Just "tag" })
                    |> asTest "should leave the version unchanged if it didn't change"
                , Success { hash = "hash2", tag = Nothing }
                    |> Version.updateVersion (Version { hash = "hash1", tag = Nothing })
                    |> Expect.equal (NewerVersion { hash = "hash1", tag = Nothing } { hash = "hash2", tag = Nothing })
                    |> asTest "should change to NewerVersion if the hash changed"
                , Success { hash = "hash1", tag = Just "tag" }
                    |> Version.updateVersion (Version { hash = "hash1", tag = Nothing })
                    |> Expect.equal (NewerVersion { hash = "hash1", tag = Nothing } { hash = "hash1", tag = Just "tag" })
                    |> asTest "should change to NewerVersion if the tag changed"
                , Success { hash = "hash", tag = Nothing }
                    |> Version.updateVersion (NewerVersion { hash = "hash", tag = Just "tag" } { hash = "hash", tag = Just "tag" })
                    |> Expect.equal (NewerVersion { hash = "hash", tag = Just "tag" } { hash = "hash", tag = Just "tag" })
                    |> asTest "should leave the current version unchanged (NewerVersion)"
                ]
            ]
        , describe "toMaybe"
            [ Version { hash = "hash", tag = Nothing }
                |> Version.toMaybe
                |> Expect.equal (Just { hash = "hash", tag = Nothing })
                |> asTest "should map to Just a version"
            , NewerVersion { hash = "oldHash", tag = Just "oldTag" } { hash = "newHash", tag = Just "newTag" }
                |> Version.toMaybe
                |> Expect.equal (Just { hash = "oldHash", tag = Just "oldTag" })
                |> asTest "should map to Just the current version even when a new one is available"
            , Unknown
                |> Version.toMaybe
                |> Expect.equal Nothing
                |> asTest "should map to Nothing when the version is unknown"
            ]
        ]
