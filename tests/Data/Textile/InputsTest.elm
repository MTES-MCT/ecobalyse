module Data.Textile.InputsTest exposing (..)

import Data.Country as Country
import Data.Split as Split
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material
import Data.Textile.Query exposing (default, tShirtCotonFrance, materialWithId)
import Data.Unit as Unit
import Expect
import List.Extra as LE
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Inputs"
        (\db ->
            [ describe "Query countries validation"
                [ { default
                    | countryFabric = Just (Country.Code "CN")
                    , countryDyeing = Just (Country.Code "CN")
                    , countryMaking = Just (Country.Code "CN")
                  }
                    |> Inputs.fromQuery db
                    |> Result.map Inputs.countryList
                    |> Result.andThen (LE.getAt 0 >> Maybe.map .code >> Result.fromMaybe "")
                    |> Expect.equal (Ok (Country.codeFromString "CN"))
                    |> asTest "should replace the first country with the material's default country"
                , { default
                    | countryFabric = Just (Country.Code "XX")
                    , countryDyeing = Just (Country.Code "CN")
                    , countryMaking = Just (Country.Code "CN")
                  }
                    |> Inputs.fromQuery db
                    |> Expect.equal (Err "Code pays invalide: XX.")
                    |> asTest "should validate country codes"
                ]
            , let
                testComplementEqual x =
                    Inputs.fromQuery db
                        >> Result.map (Inputs.getOutOfEuropeEOLComplement >> Unit.impactToFloat)
                        >> Result.withDefault 0
                        >> Expect.within (Expect.Absolute 0.001) x
              in
              describe "getOutOfEuropeEOLComplement"
                [ tShirtCotonFrance
                    |> testComplementEqual -41.65
                    |> asTest "should compute OutOfEuropeEOL complement impact for a fully natural garment"
                , { tShirtCotonFrance
                    | materials =
                     case
                            ( Material.idFromString "f0dbe27b-1e74-55d0-88a2-bda812441744"
                            , Material.idFromString "73ef624d-250e-4a9a-af5d-43505b21b527"
                            )
                        of
                            ( Ok cottonId, Ok syntheticId ) ->
                                [ materialWithId cottonId Split.half Nothing Nothing
                                , materialWithId syntheticId Split.half Nothing Nothing
                                ]

                            _ ->
                                []
                  }
                    |> testComplementEqual -102.85
                    |> asTest "should compute OutOfEuropeEOL complement impact for a half-natural, half-synthetic garment"
                ]
            , let
                testComplementEqual x =
                    Inputs.fromQuery db
                        >> Result.map (Inputs.getTotalMicrofibersComplement >> Unit.impactToFloat)
                        >> Result.withDefault 0
                        >> Expect.within (Expect.Absolute 0.001) x
              in
              describe "getMicrofibersComplement"
                [ tShirtCotonFrance
                    |> testComplementEqual -42.5
                    |> asTest "should compute Microfibers complement impact for a fully natural garment"
                , { tShirtCotonFrance
                    | materials =
                        case
                            ( Material.idFromString "f0dbe27b-1e74-55d0-88a2-bda812441744"
                            , Material.idFromString "73ef624d-250e-4a9a-af5d-43505b21b527"
                            )
                        of
                            ( Ok cottonId, Ok syntheticId ) ->
                                [ materialWithId cottonId Split.half Nothing Nothing
                                , materialWithId syntheticId Split.half Nothing Nothing
                                ]

                            _ ->
                                []
                  }
                    |> testComplementEqual -90.95
                    |> asTest "should compute Microfibers complement impact for a half-natural, half-synthetic garment"
                ]
            ]
        )
