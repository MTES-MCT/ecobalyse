module TestUtils exposing
    ( asTest
    , suiteWithDb
    )

import Expect exposing (Expectation)
import Static.Db as StaticDb
import Test exposing (..)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


suiteWithDb : String -> (StaticDb.Db -> List Test) -> Test
suiteWithDb name suite =
    case StaticDb.db of
        Ok db ->
            describe name (suite db)

        Err error ->
            describe name
                [ test "should load static database" <|
                    \_ -> Expect.fail <| "Couldn't parse static database: " ++ error
                ]
