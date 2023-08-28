module Data.Textile.InputsTest exposing (..)

import Data.Country as Country
import Data.Textile.Inputs as Inputs exposing (tShirtCotonAsie)
import Data.Textile.LifeCycle as LifeCycle
import Data.Textile.Product as Product
import Data.Textile.Simulator as Simulator
import Data.Textile.Step.Label as Label
import Expect
import List.Extra as LE
import Quantity
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


sampleQuery : Inputs.Query
sampleQuery =
    Inputs.jupeCircuitAsie


suite : Test
suite =
    suiteWithDb "Data.Inputs"
        (\{ textileDb } ->
            [ describe "Base64"
                [ describe "Encoding and decoding queries"
                    [ sampleQuery
                        |> Inputs.fromQuery textileDb
                        |> Result.map Inputs.toQuery
                        |> Expect.equal (Ok sampleQuery)
                        |> asTest "should encode and decode a query"
                    ]
                , describe "Base64 encoding and decoding queries"
                    [ sampleQuery
                        |> Inputs.b64encode
                        |> Inputs.b64decode
                        |> Expect.equal (Ok sampleQuery)
                        |> asTest "should base64 encode and decode a query"
                    ]
                ]
            , describe "Query countries validation"
                [ { tShirtCotonAsie
                    | countryFabric = Country.Code "CN"
                    , countryDyeing = Country.Code "CN"
                    , countryMaking = Country.Code "CN"
                  }
                    |> Inputs.fromQuery textileDb
                    |> Result.map Inputs.countryList
                    |> Result.andThen (LE.getAt 0 >> Maybe.map .code >> Result.fromMaybe "")
                    |> Expect.equal (Ok (Country.codeFromString "CN"))
                    |> asTest "should replace the first country with the material's default country"
                , { tShirtCotonAsie
                    | countryFabric = Country.Code "XX"
                    , countryDyeing = Country.Code "CN"
                    , countryMaking = Country.Code "CN"
                  }
                    |> Inputs.fromQuery textileDb
                    |> Expect.equal (Err "Code pays invalide: XX.")
                    |> asTest "should validate country codes"
                ]
            , describe "Product update"
                [ asTest "should update step masses"
                    (case Product.findById (Product.Id "jean") textileDb.textileProducts of
                        Ok jean ->
                            tShirtCotonAsie
                                |> Inputs.updateProduct jean
                                |> Simulator.compute textileDb
                                |> Result.map (.lifeCycle >> LifeCycle.getStepProp Label.Distribution .inputMass Quantity.zero)
                                |> Expect.equal (Ok jean.mass)

                        Err error ->
                            Expect.fail error
                    )
                ]
            ]
        )
