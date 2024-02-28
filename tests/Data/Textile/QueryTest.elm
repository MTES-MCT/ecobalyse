module Data.Textile.QueryTest exposing (..)

import Data.Country as Country
import Data.Split as Split
import Data.Textile.Inputs as Inputs
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Data.Textile.Query as Query exposing (Query, default, jupeCotonAsie)
import Data.Textile.Simulator as Simulator
import Data.Textile.Step.Label as Label
import Expect
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


sampleQuery : Query
sampleQuery =
    { jupeCotonAsie
        | materials = [ { id = Material.Id "acrylique", share = Split.full, spinning = Nothing, country = Just (Country.Code "CN") } ]
    }


suite : Test
suite =
    suiteWithDb "Data.Inputs"
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
            , describe "Product update"
                [ asTest "should update step masses"
                    (case Product.findById (Product.Id "jean") db.textile.products of
                        Ok jean ->
                            default
                                |> Query.updateProduct jean
                                |> Simulator.compute db
                                |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Distribution .inputMass Quantity.zero)
                                |> Expect.equal (Ok jean.mass)

                        Err error ->
                            Expect.fail error
                    )
                ]
            ]
        )
