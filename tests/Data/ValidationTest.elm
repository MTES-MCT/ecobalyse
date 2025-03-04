module Data.ValidationTest exposing (..)

import Data.Validation as Validation
import Dict
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


type alias Foo =
    { x : Int, y : Int }


type alias Bar =
    { x : Int, y : Maybe Int }


suite : Test
suite =
    describe "Validation"
        [ describe "required"
            [ Ok Foo
                |> Validation.required "x" (Ok 1)
                |> Validation.required "y" (Ok 2)
                |> Expect.equal (Ok { x = 1, y = 2 })
                |> asTest "should validate an Ok result"
            , Ok Foo
                |> Validation.required "x" (Ok 1)
                |> Validation.required "y" (Err "y is bad")
                |> Expect.equal (Err (Dict.fromList [ ( "y", "y is bad" ) ]))
                |> asTest "should invalidate exposing an error dict, 1 error"
            , Ok Foo
                |> Validation.required "x" (Err "x is bad")
                |> Validation.required "y" (Ok 2)
                |> Expect.equal (Err (Dict.fromList [ ( "x", "x is bad" ) ]))
                |> asTest "should invalidate exposing an error dict, 1 error, whatever the order is"
            , Ok Foo
                |> Validation.required "x" (Err "x is bad")
                |> Validation.required "y" (Err "y is bad")
                |> Expect.equal (Err (Dict.fromList [ ( "x", "x is bad" ), ( "y", "y is bad" ) ]))
                |> asTest "should invalidate exposing an error dict, 2 errors"
            ]
        , describe "optional"
            [ Ok Bar
                |> Validation.required "x" (Ok 1)
                |> Validation.optional "y" Nothing (always <| Err "y is bad")
                |> Expect.equal (Ok { x = 1, y = Nothing })
                |> asTest "should allow optional value"
            ]
        ]
