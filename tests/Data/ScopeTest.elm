module Data.ScopeTest exposing (..)

import Data.Scope as Scope
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Scope"
        [ describe "anyOf should filter records against any of passed scopes"
            [ asTest "test1"
                ([ { scopes = [ Scope.Food ] }, { scopes = [ Scope.Food, Scope.Textile ] } ]
                    |> Scope.anyOf [ Scope.Food ]
                    |> List.length
                    |> Expect.equal 2
                )
            , asTest "test2"
                ([ { scopes = [ Scope.Textile ] }, { scopes = [ Scope.Food, Scope.Textile ] } ]
                    |> Scope.anyOf [ Scope.Food ]
                    |> List.length
                    |> Expect.equal 1
                )
            , asTest "test3"
                ([ { scopes = [ Scope.Object ] }, { scopes = [ Scope.Object, Scope.Textile ] } ]
                    |> Scope.anyOf [ Scope.Food ]
                    |> List.length
                    |> Expect.equal 0
                )
            ]
        ]
