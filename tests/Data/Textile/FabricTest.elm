module Data.Textile.FabricTest exposing (..)

import Data.Textile.Fabric as Fabric
import Data.Textile.MakingComplexity as MakingComplexity
import Expect
import Test exposing (..)
import TestUtils exposing (asTest)


suite : Test
suite =
    describe "Data.Textile.Fabric"
        [ describe "getMakingCOmplexity"
            [ Fabric.getMakingComplexity MakingComplexity.NotApplicable Nothing Nothing
                |> Expect.equal MakingComplexity.NotApplicable
                |> asTest "should retrieve a default making complexity"
            , Fabric.getMakingComplexity MakingComplexity.NotApplicable Nothing (Just Fabric.KnittingFullyFashioned)
                |> Expect.equal MakingComplexity.VeryLow
                |> asTest "should retrieve a making complexity matching provided fabric"
            , Fabric.getMakingComplexity MakingComplexity.NotApplicable (Just MakingComplexity.VeryHigh) (Just Fabric.KnittingFullyFashioned)
                |> Expect.equal MakingComplexity.VeryHigh
                |> asTest "should always retrieve provided custom complexity even when a fabric is provided"
            , Fabric.getMakingComplexity MakingComplexity.NotApplicable (Just MakingComplexity.VeryHigh) Nothing
                |> Expect.equal MakingComplexity.VeryHigh
                |> asTest "should retrieve provided custom complexity when no fabric is specified"
            ]
        ]
