module Data.Textile.InputsTest exposing (..)

import Data.Country as Country
import Data.Split as Split
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material
import Data.Textile.Query exposing (Query, default, jupeCotonAsie, tShirtCotonFrance)
import Data.Unit as Unit
import Expect
import List.Extra as LE
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
            [ describe "Query countries validation"
                [ { default
                    | countryFabric = Country.Code "CN"
                    , countryDyeing = Country.Code "CN"
                    , countryMaking = Country.Code "CN"
                  }
                    |> Inputs.fromQuery db
                    |> Result.map Inputs.countryList
                    |> Result.andThen (LE.getAt 0 >> Maybe.map .code >> Result.fromMaybe "")
                    |> Expect.equal (Ok (Country.codeFromString "CN"))
                    |> asTest "should replace the first country with the material's default country"
                , { default
                    | countryFabric = Country.Code "XX"
                    , countryDyeing = Country.Code "CN"
                    , countryMaking = Country.Code "CN"
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
                    |> testComplementEqual -42.5
                    |> asTest "should compute OutOfEuropeEOL complement impact for a fully natural garment"
                , { tShirtCotonFrance
                    | materials =
                        [ { id = Material.Id "coton", share = Split.half, spinning = Nothing, country = Nothing }
                        , { id = Material.Id "pu", share = Split.half, spinning = Nothing, country = Nothing }
                        ]
                  }
                    |> testComplementEqual -102
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
                        [ { id = Material.Id "coton", share = Split.half, spinning = Nothing, country = Nothing }
                        , { id = Material.Id "pu", share = Split.half, spinning = Nothing, country = Nothing }
                        ]
                  }
                    |> testComplementEqual -90.95
                    |> asTest "should compute Microfibers complement impact for a half-natural, half-synthetic garment"
                ]
            ]
        )
