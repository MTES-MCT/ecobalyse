module Data.SectorTest exposing (..)

import Data.Sector as Sector
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Sector"
        [ describe "anyOf should filter records against any of passed sectors"
            [ asTest "test1"
                ([ { sectors = [ Sector.Food ] }, { sectors = [ Sector.Food, Sector.Textile ] } ]
                    |> Sector.anyOf [ Sector.Food ]
                    |> List.length
                    |> Expect.equal 2
                )
            , asTest "test2"
                ([ { sectors = [ Sector.Textile ] }, { sectors = [ Sector.Food, Sector.Textile ] } ]
                    |> Sector.anyOf [ Sector.Food ]
                    |> List.length
                    |> Expect.equal 1
                )
            , asTest "test3"
                ([ { sectors = [ Sector.Generic Sector.Object ] }, { sectors = [ Sector.Generic Sector.Object, Sector.Textile ] } ]
                    |> Sector.anyOf [ Sector.Food ]
                    |> List.length
                    |> Expect.equal 0
                )
            ]
        , describe "allGeneric"
            [ asTest "matches the generic entries of all"
                (Sector.all
                    |> List.filterMap Sector.toGenericSector
                    |> Expect.equal Sector.allGeneric
                )
            ]
        ]
