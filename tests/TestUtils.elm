module TestUtils exposing (asTest, suiteWithFoodDb, suiteWithTextileDb)

import Data.Food.Db as FoodDb
import Data.Textile.Db as TextileDb
import Expect exposing (Expectation)
import Test exposing (..)
import Static.Db exposing (foodDb, textileDb)


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


suiteWithFoodDb : String -> (FoodDb.Db -> List Test) -> Test
suiteWithFoodDb name suite =
    case foodDb of
        Ok db ->
            describe name (suite db)

        Err error ->
            describe name
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
