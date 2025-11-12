module Data.Textile.QueryTest exposing (..)

import Data.Country as Country
import Data.Split as Split
import Data.Textile.Inputs as Inputs
import Data.Textile.MakingComplexity as MakingComplexity
import Data.Textile.Material as Material
import Data.Textile.Query as Query exposing (Query)
import Data.Textile.Step.Label as Label
import Expect
import Test exposing (..)
import TestUtils exposing (asTest, jupeCotonAsie, suiteFromResult, suiteFromResult2, suiteFromResult3, suiteWithDb)


sampleQuery : Result String Query
sampleQuery =
    Result.map2
        (\polyesterId jupe ->
            { jupe
                | materials =
                    [ { id = polyesterId
                      , share = Split.full
                      , spinning = Nothing
                      , country = Just (Country.Code "CN")
                      }
                    ]
            }
        )
        (Material.idFromString "9dba0e95-0c35-4f8b-9267-62ddf47d4984")
        jupeCotonAsie


suite : Test
suite =
    suiteWithDb "Data.Query"
        (\db ->
            [ describe "Base64"
                [ suiteFromResult "Encoding and decoding queries"
                    sampleQuery
                    (\query ->
                        [ query
                            |> Inputs.fromQuery db
                            |> Result.map Inputs.toQuery
                            |> Expect.equal (Ok query)
                            |> asTest "encode and decode a query"
                        ]
                    )
                , suiteFromResult "Base64 encoding and decoding queries"
                    sampleQuery
                    (\query ->
                        [ query
                            |> Query.b64encode
                            |> Query.b64decode
                            |> Expect.equal (Ok query)
                            |> asTest "base64 encode and decode a query"
                        ]
                    )
                ]
            , describe "handleUpcycling"
                [ suiteFromResult "should not touch disabled steps when not upcycled"
                    jupeCotonAsie
                    (\query ->
                        [ { query | upcycled = False }
                            |> Query.handleUpcycling
                            |> .disabledSteps
                            |> Expect.equal []
                            |> asTest "not touch disabled steps when not upcycled"
                        ]
                    )
                , suiteFromResult "should not touch making complexity when not upcycled"
                    jupeCotonAsie
                    (\query ->
                        [ { query | upcycled = False }
                            |> Query.handleUpcycling
                            |> .makingComplexity
                            |> Expect.equal query.makingComplexity
                            |> asTest "not touch making complexity when not upcycled"
                        ]
                    )
                , suiteFromResult
                    "should disable specific steps when upcycled"
                    jupeCotonAsie
                    (\query ->
                        [ { query | upcycled = True }
                            |> Query.handleUpcycling
                            |> .disabledSteps
                            |> Expect.equal Label.upcyclables
                            |> asTest "disable specific steps when upcycled"
                        ]
                    )
                , suiteFromResult
                    "should update making complexity to High when upcycled"
                    jupeCotonAsie
                    (\query ->
                        [ { query | upcycled = True }
                            |> Query.handleUpcycling
                            |> .makingComplexity
                            |> Expect.equal (Just MakingComplexity.High)
                            |> asTest "update making complexity to High when upcycled"
                        ]
                    )
                ]
            , describe "validateMaterials"
                [ []
                    |> Query.validateMaterials
                    |> Expect.ok
                    |> asTest "validate the sum of an empty list of materials"
                , suiteFromResult "should validate the sum of an incomplete list of materials"
                    (Material.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84")
                    (\id ->
                        [ [ { id = id
                            , share = Split.tenth
                            , spinning = Nothing
                            , country = Nothing
                            }
                          ]
                            |> Query.validateMaterials
                            |> Expect.err
                            |> asTest "validates sum of an incomplete list of materials"
                        ]
                    )
                , suiteFromResult2 "should validate a complete sum of materials"
                    (Material.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84")
                    (Material.idFromString "73ef624d-250e-4a9a-af5d-43505b21b527")
                    (\cottonId syntheticId ->
                        [ [ { id = cottonId
                                  , share = Split.half
                                  , spinning = Nothing
                                  , country = Nothing
                                  }
                                , { id = syntheticId
                                  , share = Split.half
                                  , spinning = Nothing
                                  , country = Nothing
                                  }
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
                        [ [ { id = polyesterId
                                  , share = Split.sixty
                                  , spinning = Nothing
                                  , country = Nothing
                                  }
                                , { id = polypropyleneId
                                  , share = Split.thirty
                                  , spinning = Nothing
                                  , country = Nothing
                                  }
                                  , { id = cottonId
                                  , share = Split.tenth
                                  , spinning = Nothing
                                  , country = Nothing
                                  }
                                ]
                            |> Query.validateMaterials
                            |> Expect.ok
                            |> asTest "validates complete sum of materials with rounding error"
                        ]
                    )
                ]
            ]
        )
