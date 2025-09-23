module Data.Textile.QueryTest exposing (..)

import Data.Country as Country
import Data.Split as Split
import Data.Textile.Inputs as Inputs
import Data.Textile.MakingComplexity as MakingComplexity
import Data.Textile.Material as Material
import Data.Textile.Query as Query exposing (Query, jupeCotonAsie, materialWithId)
import Data.Textile.Step.Label as Label
import Expect
import Test exposing (..)
import TestUtils exposing (asTest, suiteFromResult, suiteFromResult2, suiteFromResult3, suiteWithDb)


sampleQuery : Query
sampleQuery =
    { jupeCotonAsie
        | materials =
            case Material.idFromString "9dba0e95-0c35-4f8b-9267-62ddf47d4984" of
                Ok id ->
                    [ materialWithId id Split.full Nothing (Just (Country.Code "CN")) ]

                Err _ ->
                    []
    }


suite : Test
suite =
    suiteWithDb "Data.Query"
        (\db ->
            [ describe "Base64"
                [ describe "Encoding and decoding queries"
                    [ sampleQuery
                        |> Inputs.fromQuery db
                        |> Result.map Inputs.toQuery
                        |> Expect.equal (Ok sampleQuery)
                        |> asTest "should encode and decode a query"
                    ]
                , describe "Base64 encoding and decoding queries"
                    [ sampleQuery
                        |> Query.b64encode
                        |> Query.b64decode
                        |> Expect.equal (Ok sampleQuery)
                        |> asTest "should base64 encode and decode a query"
                    ]
                ]
            , describe "handleUpcycling"
                [ { jupeCotonAsie | upcycled = False }
                    |> Query.handleUpcycling
                    |> .disabledSteps
                    |> Expect.equal []
                    |> asTest "should not touch disabled steps when not upcycled"
                , { jupeCotonAsie | upcycled = False }
                    |> Query.handleUpcycling
                    |> .makingComplexity
                    |> Expect.equal jupeCotonAsie.makingComplexity
                    |> asTest "should not touch making complexity when not upcycled"
                , { jupeCotonAsie | upcycled = True }
                    |> Query.handleUpcycling
                    |> .disabledSteps
                    |> Expect.equal Label.upcyclables
                    |> asTest "should disable specific steps when upcycled"
                , { jupeCotonAsie | upcycled = True }
                    |> Query.handleUpcycling
                    |> .makingComplexity
                    |> Expect.equal (Just MakingComplexity.High)
                    |> asTest "should update making complexity to High when upcycled"
                ]
            , describe "validateMaterials"
                [ []
                    |> Query.validateMaterials
                    |> Expect.ok
                    |> asTest "should validate the sum of an empty list of materials"
                , suiteFromResult "should validate the sum of an incomplete list of materials"
                    (Material.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84")
                    (\id ->
                        [ [ materialWithId id Split.tenth Nothing Nothing ]
                            |> Query.validateMaterials
                            |> Expect.err
                            |> asTest "validates sum of an incomplete list of materials"
                        ]
                    )
                , suiteFromResult2 "should validate a complete sum of materials"
                    (Material.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84")
                    (Material.idFromString "73ef624d-250e-4a9a-af5d-43505b21b527")
                    (\cottonId syntheticId ->
                        [ [ materialWithId cottonId Split.half Nothing Nothing
                          , materialWithId syntheticId Split.half Nothing Nothing
                          ]
                            |> Query.validateMaterials
                            |> Expect.ok
                            |> asTest "validates complete sum of materials"
                        ]
                    )
                , -- Testing for float number rounding precision errors https://en.wikipedia.org/wiki/Round-off_error
                  suiteFromResult3 "should validate a complete sum of materials with rounding error"
                    (Material.idFromString "9dba0e95-0c35-4f8b-9267-62ddf47d4984")
                    (Material.idFromString "73ef624d-250e-4a9a-af5d-43505b21b527")
                    (Material.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84")
                    (\polyesterId polypropyleneId cottonId ->
                        [ [ materialWithId polyesterId Split.sixty Nothing Nothing
                          , materialWithId polypropyleneId Split.thirty Nothing Nothing
                          , materialWithId cottonId Split.tenth Nothing Nothing
                          ]
                            |> Query.validateMaterials
                            |> Expect.ok
                            |> asTest "validates complete sum of materials with rounding error"
                        ]
                    )
                ]
            ]
        )
