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
            ]
        )
