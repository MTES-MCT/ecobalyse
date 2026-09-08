module Data.CountryTest exposing (..)

import Data.Country as Country
import Data.Country.Code as CountryCode
import Data.Scope as Scope
import Expect
import Test exposing (..)
import TestUtils exposing (expectResultErrorContains, it, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Country"
        (\db ->
            [ describe "resolveMaybe"
                [ it "should resolve a known country code"
                    (db.countries
                        |> Country.resolveMaybe (Just CountryCode.france)
                        |> Result.map (Maybe.map .code)
                        |> Expect.equal (Ok (Just CountryCode.france))
                    )
                , it "should return nothing when no country code is provided"
                    (db.countries
                        |> Country.resolveMaybe Nothing
                        |> Expect.equal (Ok Nothing)
                    )
                , it "should fail when the country code is unknown"
                    (db.countries
                        |> Country.resolveMaybe (Just (CountryCode.fromString "ZZ"))
                        |> expectResultErrorContains "Code pays invalide"
                    )
                ]
            , describe "validateForScope"
                [ it "should accept a country available in the scope"
                    (Country.validateForScope Scope.Textile db.countries CountryCode.france
                        |> Expect.equal (Ok CountryCode.france)
                    )
                , it "should reject a country unavailable in the scope"
                    (Country.validateForScope Scope.Textile db.countries (CountryCode.fromString "RMA")
                        |> expectResultErrorContains "n’est pas utilisable dans un contexte Textile"
                    )
                , it "should fail when the country code is unknown"
                    (Country.validateForScope Scope.Textile db.countries (CountryCode.fromString "ZZ")
                        |> expectResultErrorContains "Code pays invalide"
                    )
                ]
            ]
        )
