module TestUtils exposing (asTest, suiteWithTextileDb)

import Data.Textile.Db as TextileDb
import Expect exposing (Expectation)
import Test exposing (..)
import TestDb exposing (textileDb)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


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
