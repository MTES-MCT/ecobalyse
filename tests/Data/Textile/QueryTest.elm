module Data.Textile.QueryTest exposing (..)

import Data.Country as Country
import Data.Split as Split
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material
import Data.Textile.Query as Query exposing (Query, jupeCotonAsie)
import Expect
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


sampleQuery : Query
sampleQuery =
    { jupeCotonAsie
        | materials =
            [ { id = Material.Id "ei-pet"
              , share = Split.full
              , spinning = Nothing
              , country = Just (Country.Code "CN")
              }
            ]
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
            , describe "validateMaterials"
                [ []
                    |> Query.validateMaterials
                    |> Expect.ok
                    |> asTest "should validate the sum of an empty list of materials"
                , [ { id = Material.Id "ei-coton"
                    , share = Split.tenth
                    , spinning = Nothing
                    , country = Nothing
                    }
                  ]
                    |> Query.validateMaterials
                    |> Expect.err
                    |> asTest "should validate the sum of an incomplete list of materials"
                , [ { id = Material.Id "ei-pu"
                    , share = Split.half
                    , spinning = Nothing
                    , country = Nothing
                    }
                  , { id = Material.Id "ei-coton"
                    , share = Split.half
                    , spinning = Nothing
                    , country = Nothing
                    }
                  ]
                    |> Query.validateMaterials
                    |> Expect.ok
                    |> asTest "should validate a complete sum of materials"
                , -- Testing for float number rounding precision errors https://en.wikipedia.org/wiki/Round-off_error
                  [ { id = Material.Id "ei-pet"
                    , share = Split.sixty
                    , spinning = Nothing
                    , country = Nothing
                    }
                  , { id = Material.Id "ei-pu"
                    , share = Split.thirty
                    , spinning = Nothing
                    , country = Nothing
                    }
                  , { id = Material.Id "ei-coton"
                    , share = Split.tenth
                    , spinning = Nothing
                    , country = Nothing
                    }
                  ]
                    |> Query.validateMaterials
                    |> Expect.ok
                    |> asTest "should validate a complete sum of materials with rounding error"
                ]
            ]
        )
