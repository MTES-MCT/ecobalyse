module Request.VersionTest exposing (..)

import Expect
import Http exposing (Error(..))
import RemoteData exposing (RemoteData(..))
import Request.Version exposing (Version(..), updateVersion)
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "updateVersion"
        -- Failed poll
        [ updateVersion Unknown (Failure (BadBody "bad body"))
            |> Expect.equal Unknown
            |> asTest "should leave the current version unchanged (Unknown) if the poll failed"
        , updateVersion (Version { hash = "hash", tag = Nothing }) (Failure (BadBody "bad body"))
            |> Expect.equal (Version { hash = "hash", tag = Nothing })
            |> asTest "should leave the current version unchanged (Version ...) if the poll failed"
        , updateVersion NewerVersion (Failure (BadBody "bad body"))
            |> Expect.equal NewerVersion
            |> asTest "should leave the current version unchanged (NewerVersion) if the poll failed"

        -- Successful poll
        , updateVersion Unknown (Success { hash = "hash", tag = Nothing })
            |> Expect.equal (Version { hash = "hash", tag = Nothing })
            |> asTest "should go from Unknown to Version ..."
        , updateVersion (Version { hash = "hash", tag = Just "tag" }) (Success { hash = "hash", tag = Just "tag" })
            |> Expect.equal (Version { hash = "hash", tag = Just "tag" })
            |> asTest "should leave the version unchanged if it didn't change"
        , updateVersion (Version { hash = "hash1", tag = Nothing }) (Success { hash = "hash2", tag = Nothing })
            |> Expect.equal NewerVersion
            |> asTest "should change to NewerVersion if the hash changed"
        , updateVersion (Version { hash = "hash1", tag = Nothing }) (Success { hash = "hash1", tag = Just "tag" })
            |> Expect.equal NewerVersion
            |> asTest "should change to NewerVersion if the tag changed"
        , updateVersion NewerVersion (Success { hash = "hash", tag = Nothing })
            |> Expect.equal NewerVersion
            |> asTest "should leave the current version unchanged (NewerVersion)"
        ]
