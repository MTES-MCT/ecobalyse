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


type alias Baz =
    { x : List Int }


suite : Test
suite =
    describe "Validation"
        [ describe "list"
            [ Ok Baz
                |> Validation.list "x" [ 1 ] Ok
                |> Expect.equal (Ok { x = [ 1 ] })
                |> asTest "should accept a valid list"
            , Ok Baz
                |> Validation.list "x"
                    [ 1, 2 ]
                    (\int ->
                        if int > 1 then
                            Err "too high"

                        else
                            Ok int
                    )
                |> Expect.equal (Err (Dict.fromList [ ( "x", "too high" ) ]))
                |> asTest "should reject an invalid list"
            ]
        , describe "maybe"
            [ Ok Bar
                |> Validation.validate "x" (Ok 1)
                |> Validation.maybe "y" (Just 2) Ok
                |> Expect.equal (Ok { x = 1, y = Just 2 })
                |> asTest "should accept an optional value"
            , Ok Bar
                |> Validation.validate "x" (Ok 1)
                |> Validation.maybe "y" Nothing (always <| Err "y is bad")
                |> Expect.equal (Ok { x = 1, y = Nothing })
                |> asTest "should reject an invalid optional value"
            ]
        , describe "nonEmptyList"
            [ Ok Baz
                |> Validation.nonEmptyList "x" [ 1 ] Ok
                |> Expect.equal (Ok { x = [ 1 ] })
                |> asTest "should accept a non-empty list"
            , Ok Baz
                |> Validation.nonEmptyList "x" [] Ok
                |> Expect.equal (Err (Dict.fromList [ ( "x", "La liste 'x' ne peut pas être vide." ) ]))
                |> asTest "should reject an empty list"
            ]
        , describe "validate"
            [ Ok Foo
                |> Validation.validate "x" (Ok 1)
                |> Validation.validate "y" (Ok 2)
                |> Expect.equal (Ok { x = 1, y = 2 })
                |> asTest "should validate an Ok result"
            , Ok Foo
                |> Validation.validate "x" (Ok 1)
                |> Validation.validate "y" (Err "y is bad")
                |> Expect.equal (Err (Dict.fromList [ ( "y", "y is bad" ) ]))
                |> asTest "should invalidate exposing an error dict, 1 error"
            , Ok Foo
                |> Validation.validate "x" (Err "x is bad")
                |> Validation.validate "y" (Ok 2)
                |> Expect.equal (Err (Dict.fromList [ ( "x", "x is bad" ) ]))
                |> asTest "should invalidate exposing an error dict, 1 error, whatever the order is"
            , Ok Foo
                |> Validation.validate "x" (Err "x is bad")
                |> Validation.validate "y" (Err "y is bad")
                |> Expect.equal (Err (Dict.fromList [ ( "x", "x is bad" ), ( "y", "y is bad" ) ]))
                |> asTest "should invalidate exposing an error dict, 2 errors"
            ]
        ]
