module Data.Textile.ProductTest exposing (..)

import Data.Textile.Inputs as Inputs
import Data.Textile.Knitting as Knitting
import Data.Textile.Product as Product
import Data.Unit as Unit
import Duration
import Expect
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


sampleQuery : Inputs.Query
sampleQuery =
    Inputs.tShirtCotonAsie


suite : Test
suite =
    suiteWithDb "Data.Simulator"
        (\{ textileDb } ->
            [ describe "Data.Product"
                [ describe "customDaysOfWear"
                    [ { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                        |> Product.customDaysOfWear (Just (Unit.quality 1)) Nothing
                        |> Expect.equal
                            { daysOfWear = Duration.days 100
                            , useNbCycles = 5
                            }
                        |> asTest "should compute custom number of days of wear"
                    , { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                        |> Product.customDaysOfWear (Just (Unit.quality 0.8)) Nothing
                        |> Expect.equal
                            { daysOfWear = Duration.days 80
                            , useNbCycles = 4
                            }
                        |> asTest "should compute custom number of days of wear with custom quality"
                    , { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                        |> Product.customDaysOfWear Nothing (Just (Unit.reparability 1.2))
                        |> Expect.equal
                            { daysOfWear = Duration.days 120
                            , useNbCycles = 6
                            }
                        |> asTest "should compute custom number of days of wear with custom reparability"
                    , { daysOfWear = Duration.days 100, wearsPerCycle = 20 }
                        |> Product.customDaysOfWear (Just (Unit.quality 1.2)) (Just (Unit.reparability 1.2))
                        |> Expect.equal
                            { daysOfWear = Duration.days 144
                            , useNbCycles = 7
                            }
                        |> asTest "should compute custom number of days of wear with custom quality & reparability"
                    ]
                , let
                    tshirtResult =
                        sampleQuery
                            |> Inputs.fromQuery textileDb
                            |> Result.map .product
                  in
                  describe "getFabricProcess"
                    [ Result.map
                        (\product ->
                            let
                                fabricProcess =
                                    Product.getFabricProcess Nothing product textileDb.wellKnown
                            in
                            Expect.equal product.fabric (Product.Knitted fabricProcess)
                        )
                        tshirtResult
                        |> Result.withDefault (Expect.fail "test failed")
                        |> asTest "should return the default product fabric process when no knitting process is specified"
                    , Result.map
                        (\product ->
                            let
                                fabricProcess =
                                    Product.getFabricProcess (Just Knitting.Seamless) product textileDb.wellKnown
                            in
                            Expect.equal textileDb.wellKnown.knittingSeamless fabricProcess
                        )
                        tshirtResult
                        |> Result.withDefault (Expect.fail "test failed")
                        |> asTest "should return the selected knitting process over the default product fabric process"
                    ]
                ]
            ]
        )
