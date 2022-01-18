module Data.InputsTest exposing (..)

import Data.Country as Country
import Data.Inputs as Inputs exposing (tShirtCotonAsie)
import Expect exposing (Expectation)
import List.Extra as LE
import Test exposing (..)
import TestDb exposing (testDb)


asTest : String -> Expectation -> Test
asTest label =
    always >> test label


sampleQuery : Inputs.Query
sampleQuery =
    Inputs.jupeCircuitAsie


suite : Test
suite =
    case testDb of
        Ok db ->
            describe "Data.Inputs"
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
                            |> Inputs.b64encode
                            |> Inputs.b64decode
                            |> Expect.equal (Ok sampleQuery)
                            |> asTest "should base64 encode and decode a query"
                        ]
                    ]
                , describe "Query countries validation"
                    [ { tShirtCotonAsie | countryFabric = Country.Code "CN", countryDyeing = Country.Code "CN", countryMaking = Country.Code "CN" }
                        |> Inputs.fromQuery db
                        |> Result.map Inputs.countryList
                        |> Result.andThen (LE.getAt 0 >> Maybe.map .code >> Result.fromMaybe "")
                        |> Expect.equal (Ok (Country.codeFromString "CN"))
                        |> asTest "should replace the first country with the material's default country"
                    , { tShirtCotonAsie | countryFabric = Country.Code "XX", countryDyeing = Country.Code "CN", countryMaking = Country.Code "CN" }
                        |> Inputs.fromQuery db
                        |> Expect.equal (Err "Code pays invalide: XX.")
                        |> asTest "should validate country codes"
                    ]
                ]

        Err error ->
            describe "Data.Inputs"
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
