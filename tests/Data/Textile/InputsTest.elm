module Data.Textile.InputsTest exposing (..)

import Data.Country as Country
import Data.Split as Split
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material
import Data.Textile.Query exposing (default, materialWithId)
import Data.Unit as Unit
import Expect
import List.Extra as LE
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb, tShirtCotonFrance, suiteFromResult)


suite : Test
suite =
    suiteWithDb "Data.Inputs"
        (\db ->
            [ describe "Query countries validation"
                [ suiteFromResult "should replace the first country with the material's default country" tShirtCotonFrance
                    (\query ->
                        [ { query
                            | countryFabric = Just (Country.Code "CN")
                            , countryDyeing = Just (Country.Code "CN")
                            , countryMaking = Just (Country.Code "CN")
                          }
                            |> Inputs.fromQuery db
                            |> Result.map Inputs.countryList
                            |> Result.andThen (LE.getAt 0 >> Maybe.map .code >> Result.fromMaybe "")
                            |> Expect.equal (Ok (Country.codeFromString "CN"))
                            |> asTest "replace the first country with the material's default country"
                        ]
                    )
                , { default
                    | countryFabric = Just (Country.Code "XX")
                    , countryDyeing = Just (Country.Code "CN")
                    , countryMaking = Just (Country.Code "CN")
                  }
                    |> Inputs.fromQuery db
                    |> Expect.equal (Err "Code pays invalide: XX.")
                    |> asTest "validate country codes"
                ]
            , let
                testComplementEqual x =
                    Inputs.fromQuery db
                        >> Result.map (Inputs.getOutOfEuropeEOLComplement >> Unit.impactToFloat)
                        >> Result.withDefault 0
                        >> Expect.within (Expect.Absolute 0.001) x
              in
              describe "getOutOfEuropeEOLComplement"
                [ TestUtils.suiteFromResult
                    "should compute OutOfEuropeEOL complement impact for a fully natural garment"
                    tShirtCotonFrance
                    (\tshirtCotonFrance_ -> [ testComplementEqual -41.65 tshirtCotonFrance_ |> asTest "compute OutOfEuropeEOL complement impact for a fully natural garment" ])
                , TestUtils.suiteFromResult3
                    "should compute OutOfEuropeEOL complement impact for a half-natural, half-synthetic garment"
                    (Material.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84")
                    (Material.idFromString "73ef624d-250e-4a9a-af5d-43505b21b527")
                    tShirtCotonFrance
                    (\cottonId syntheticId tshirtCotonFrance_ ->
                        [ { tshirtCotonFrance_
                            | materials =
                                [ materialWithId cottonId Split.half Nothing Nothing
                                , materialWithId syntheticId Split.half Nothing Nothing
                                ]
                          }
                            |> testComplementEqual -102.85
                            |> asTest "compute OutOfEuropeEOL complement impact for a half-natural, half-synthetic garment"
                        ]
                    )
                ]
            , let
                testComplementEqual x =
                    Inputs.fromQuery db
                        >> Result.map (Inputs.getTotalMicrofibersComplement >> Unit.impactToFloat)
                        >> Result.withDefault 0
                        >> Expect.within (Expect.Absolute 0.001) x
              in
              describe "getMicrofibersComplement"
              [ TestUtils.suiteFromResult
              "should compute Microfibers complement impact for a fully natural garment"
              tShirtCotonFrance
              (\tShirtCotonFrance_ ->
                [ testComplementEqual -42.5 tShirtCotonFrance_ |> asTest "compute Microfibers complement impact for a fully natural garment" ])
                , TestUtils.suiteFromResult3
                    "should compute Microfibers complement impact for a half-natural, half-synthetic garment"
                    (Material.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84")
                    (Material.idFromString "73ef624d-250e-4a9a-af5d-43505b21b527")
                    tShirtCotonFrance
                    (\cottonId syntheticId tShirtCotonFrance_ ->
                        [ { tShirtCotonFrance_
                            | materials =
                                [ materialWithId cottonId Split.half Nothing Nothing
                                , materialWithId syntheticId Split.half Nothing Nothing
                                ]
                          }
                            |> testComplementEqual -90.95
                            |> asTest "compute Microfibers complement impact for a half-natural, half-synthetic garment"
                        ]
                    )
                ]
            ]
        )
