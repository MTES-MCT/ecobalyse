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
        , updateVersion (Version "hash") (Failure (BadBody "bad body"))
            |> Expect.equal (Version "hash")
            |> asTest "should leave the current version unchanged (Version ...) if the poll failed"
        , updateVersion NewerVersion (Failure (BadBody "bad body"))
            |> Expect.equal NewerVersion
            |> asTest "should leave the current version unchanged (NewerVersion) if the poll failed"

        -- Successful poll
        , updateVersion Unknown (Success "hash")
            |> Expect.equal (Version "hash")
            |> asTest "should go from Unknown to Version ..."
        , updateVersion (Version "hash") (Success "hash")
            |> Expect.equal (Version "hash")
            |> asTest "should leave the version unchanged if it didn't change"
        , updateVersion (Version "hash1") (Success "hash2")
            |> Expect.equal NewerVersion
            |> asTest "should change to NewerVersion if the version changed"
        , updateVersion NewerVersion (Success "hash")
            |> Expect.equal NewerVersion
            |> asTest "should leave the current version unchanged (NewerVersion)"
        ]
