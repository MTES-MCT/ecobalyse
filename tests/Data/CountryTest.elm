module Data.CountryTest exposing (..)

import Data.Country as Country
import Data.Country.Code as CountryCode
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
            , describe "resolveMaybeWithFallback"
                [ it "should resolve with primary country code when both are known"
                    (db.countries
                        |> Country.resolveMaybeWithFallback (Just CountryCode.france) (Just CountryCode.china)
                        |> Result.map (Maybe.map .code)
                        |> Expect.equal (Ok (Just CountryCode.france))
                    )
                , it "should resolve with fallback when primary is missing"
                    (db.countries
                        |> Country.resolveMaybeWithFallback Nothing (Just CountryCode.china)
                        |> Result.map (Maybe.map .code)
                        |> Expect.equal (Ok (Just CountryCode.china))
                    )
                , it "should return nothing when both are missing"
                    (db.countries
                        |> Country.resolveMaybeWithFallback Nothing Nothing
                        |> Expect.equal (Ok Nothing)
                    )
                , it "should fail on primary even when fallback is known"
                    (db.countries
                        |> Country.resolveMaybeWithFallback (Just (CountryCode.fromString "ZZ")) (Just CountryCode.china)
                        |> expectResultErrorContains "Code pays invalide"
                    )
                ]
            ]
        )
