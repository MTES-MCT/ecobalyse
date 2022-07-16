module Data.Textile.ProductTest exposing (..)

import Codec
import Data.Textile.Db as TextileDb
import Data.Textile.Process as Process
import Data.Textile.Product as Product
import Data.Unit as Unit
import Duration
import Expect
import Json.Decode as Decode
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithTextileDb)


suite : Test
suite =
    suiteWithTextileDb "Data.Product"
        (\db ->
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
            , codecSuite db
            ]
        )


codecSuite : TextileDb.Db -> Test
codecSuite db =
    describe "Codecs"
        [ case
            ( -- Knitting process
              Process.findByUuid (Process.Uuid "2e16787c-7a89-4883-acdf-37d3d362bdab") db.processes
              -- Weaving process
            , Process.findByUuid (Process.Uuid "f9686809-f55e-4b96-b1f0-3298959de7d0") db.processes
            )
          of
            ( Ok knittingProcess, Ok weavingProcess ) ->
                describe "fabricOptionsCodec"
                    [ describe "encoders"
                        [ Product.Knitted knittingProcess
                            |> Codec.encodeToString 0 (Product.fabricOptionsCodec db.processes)
                            |> Expect.equal "{\"processUuid\":\"2e16787c-7a89-4883-acdf-37d3d362bdab\"}"
                            |> asTest "should encode a knitting product fabric process 2"
                        , Product.Weaved weavingProcess (Unit.pickPerMeter 1000) (Unit.surfaceMass 75)
                            |> Codec.encodeToString 0 (Product.fabricOptionsCodec db.processes)
                            |> Expect.equal "{\"processUuid\":\"f9686809-f55e-4b96-b1f0-3298959de7d0\",\"picking\":1000,\"surfaceMass\":75}"
                            |> asTest "should encode a weaving product fabric process 2"
                        ]
                    , describe "decoder"
                        [ "{\"processUuid\":\"2e16787c-7a89-4883-acdf-37d3d362bdab\"}"
                            |> Decode.decodeString (Codec.decoder (Product.fabricOptionsCodec db.processes))
                            |> Expect.equal (Ok (Product.Knitted knittingProcess))
                            |> asTest "should decode a knitting product fabric process 2"
                        , "{\"processUuid\":\"f9686809-f55e-4b96-b1f0-3298959de7d0\",\"picking\":1000,\"surfaceMass\":75}"
                            |> Decode.decodeString (Codec.decoder (Product.fabricOptionsCodec db.processes))
                            |> Expect.equal (Ok (Product.Weaved weavingProcess (Unit.pickPerMeter 1000) (Unit.surfaceMass 75)))
                            |> asTest "should decode a weaving product fabric process 2"
                        , "{\"processUuid\":\"f9686809-f55e-4b96-b1f0-3298959de7d0\",\"picking\":0,\"surfaceMass\":75}"
                            |> Decode.decodeString (Codec.decoder (Product.fabricOptionsCodec db.processes))
                            |> TestUtils.expectDecodeErrorContains "Le duitage spécifié (0) doit être compris entre"
                            |> asTest "should validate decoded weaving product fabric data"
                        , "{\"processUuid\":\"xxx\"}"
                            |> Decode.decodeString (Codec.decoder (Product.fabricOptionsCodec db.processes))
                            |> TestUtils.expectDecodeErrorContains "introuvable par UUID: xxx"
                            |> asTest "should discard non-existing fabric process"
                        , "{\"processUuid\":\"493c32d2-506d-48c1-b8d7-0646fba88571\"}"
                            |> Decode.decodeString (Codec.decoder (Product.fabricOptionsCodec db.processes))
                            |> TestUtils.expectDecodeErrorContains "pas un procédé de production d'étoffe"
                            |> asTest "should discard invalid fabric process"
                        , "{\"processUuid\":\"f9686809-f55e-4b96-b1f0-3298959de7d0\"}"
                            |> Decode.decodeString (Codec.decoder (Product.fabricOptionsCodec db.processes))
                            |> TestUtils.expectDecodeErrorContains "Expecting an OBJECT with a field named `surfaceMass`"
                            |> asTest "should discard incomplete weaving fabric process"
                        ]
                    ]

            _ ->
                test "should load fabric processes" <|
                    \_ -> Expect.fail "error"
        ]
