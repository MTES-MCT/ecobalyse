module TestUtils exposing (asTest, suiteWithDb)

import Data.Db exposing (Db)
import Expect exposing (Expectation)
import Test exposing (..)
import TestDb exposing (testDb)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


suiteWithDb : String -> (Db -> List Test) -> Test
suiteWithDb name suite =
    case testDb of
        Ok db ->
            describe name (suite db)

        Err error ->
            describe name
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
