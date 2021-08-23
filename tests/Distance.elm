module Distance exposing (..)

import Data.Country as Country
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Data.Country"
        [ describe "getDistance"
            [ test "should retrieve distance between two countries" <|
                \_ ->
                    Country.getDistance Country.France Country.China
                        |> Expect.equal 21548
            , test "should retrieve distance between two swapped countries" <|
                \_ ->
                    Country.getDistance Country.China Country.France
                        |> Expect.equal 21548
            , test "should fallback to 0 when unknown distance" <|
                \_ ->
                    Country.getDistance Country.Greece Country.Italy
                        |> Expect.equal 0
            ]
        ]
