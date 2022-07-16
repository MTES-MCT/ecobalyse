module TestUtils exposing
    ( asTest
    , expectDecodeErrorContains
    , suiteWithTextileDb
    )

import Data.Textile.Db as TextileDb
import Expect exposing (Expectation)
import Json.Decode as Decode
import Test exposing (..)
import TestDb exposing (textileDb)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


expectDecodeErrorContains : String -> Result Decode.Error a -> Expectation
expectDecodeErrorContains pattern result =
    case result of
        Ok _ ->
            Expect.fail "This operation should not have succeeded"

        Err err ->
            err
                |> Decode.errorToString
                |> String.contains pattern
                |> Expect.equal True


suiteWithTextileDb : String -> (TextileDb.Db -> List Test) -> Test
suiteWithTextileDb name suite =
    case textileDb of
        Ok db ->
            describe name (suite db)

        Err error ->
            describe name
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
