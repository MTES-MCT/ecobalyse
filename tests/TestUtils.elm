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

        Err decodeError ->
            decodeError
                |> Decode.errorToString
                |> expectStringContains pattern


expectStringContains : String -> String -> Expectation
expectStringContains pattern =
    String.contains pattern
        >> Expect.true ("String does not contain \"" ++ pattern ++ "\"")


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
