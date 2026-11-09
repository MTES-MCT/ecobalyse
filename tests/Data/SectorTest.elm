module Data.SectorTest exposing (..)

import Data.Sector as Sector
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Scope"
        [ describe "anyOf should filter records against any of passed scopes"
            [ asTest "test1"
                ([ { scopes = [ Sector.Food ] }, { scopes = [ Sector.Food, Sector.Textile ] } ]
                    |> Sector.anyOf [ Sector.Food ]
                    |> List.length
                    |> Expect.equal 2
                )
            , asTest "test2"
                ([ { scopes = [ Sector.Textile ] }, { scopes = [ Sector.Food, Sector.Textile ] } ]
                    |> Sector.anyOf [ Sector.Food ]
                    |> List.length
                    |> Expect.equal 1
                )
            , asTest "test3"
                ([ { scopes = [ Sector.Generic Sector.Object ] }, { scopes = [ Sector.Generic Sector.Object, Sector.Textile ] } ]
                    |> Sector.anyOf [ Sector.Food ]
                    |> List.length
                    |> Expect.equal 0
                )
            ]
        , describe "allGeneric"
            [ asTest "matches the generic entries of all"
                (Sector.all
                    |> List.filterMap Sector.toGenericScope
                    |> Expect.equal Sector.allGeneric
                )
            ]
        ]
