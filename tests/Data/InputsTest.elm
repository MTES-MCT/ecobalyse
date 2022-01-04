module Data.InputsTest exposing (..)

import Data.Country as Country
import Data.Inputs as Inputs
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
                , describe "A list of countries with a first country different than the material's default country"
                    [ Inputs.tShirtCotonAsie
                        |> (\query ->
                                let
                                    badCountries =
                                        query.countries
                                            |> LE.setAt 0 (Country.codeFromString "FR")
                                in
                                { query | countries = badCountries }
                           )
                        |> Inputs.fromQuery db
                        |> Result.map Inputs.toQuery
                        |> Result.map .countries
                        |> Result.andThen (List.head >> Result.fromMaybe "Couldn't get the first country from the list")
                        |> Expect.equal (Ok (Country.codeFromString "CN"))
                        |> asTest "should replace the first country with the material's default country"
                    ]
                ]

        Err error ->
            describe "Data.Inputs"
                [ test "should load test database" <|
                    \_ -> Expect.fail <| "Couldn't parse test database: " ++ error
                ]
