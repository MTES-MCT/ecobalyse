module Data.Food.Builder.RecipeTest exposing (..)

import Data.Country as Country
import Data.Food.Builder.Query as Query exposing (carrotCake)
import Data.Food.Builder.Recipe as Recipe
import Data.Food.Ingredient as Ingredient
import Data.Food.Preparation as Preparation
import Data.Food.Process as Process
import Data.Food.Retail as Retail
import Data.Impact as Impact
import Data.Split as Split
import Data.Unit as Unit
import Dict
import Dict.Any as AnyDict
import Expect
import Length
import Mass
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


expectImpactEqual : Unit.Impact -> Unit.Impact -> Expect.Expectation
expectImpactEqual expectedImpactUnit =
    let
        expectedImpact =
            Unit.impactToFloat expectedImpactUnit
    in
    Unit.impactToFloat
        >> Expect.within (Expect.Relative 0.0000000000000001) expectedImpact


suite : Test
suite =
    suiteWithDb "Data.Food.Builder.Recipe"
        (\{ builderDb } ->
            [ let
                testComputedBonuses bonuses =
                    Impact.impactsFromDefinitons builderDb.impacts
                        |> Impact.updateImpact (Impact.trg "ecs") (Unit.impact 1000)
                        |> Impact.updateImpact (Impact.trg "ldu") (Unit.impact 100)
                        |> Recipe.computeIngredientBonusesImpacts builderDb.impacts bonuses
              in
              describe "computeIngredientBonusesImpacts"
                [ describe "with zero bonuses applied"
                    (let
                        bonusImpacts =
                            testComputedBonuses
                                { agroDiversity = Split.zero
                                , agroEcology = Split.zero
                                , animalWelfare = Split.zero
                                }
                     in
                     [ bonusImpacts.agroDiversity
                        |> expectImpactEqual (Unit.impact 0)
                        |> asTest "should compute a zero agro-diversity ingredient bonus"
                     , bonusImpacts.agroEcology
                        |> expectImpactEqual (Unit.impact 0)
                        |> asTest "should compute a zero agro-ecology ingredient bonus"
                     , bonusImpacts.animalWelfare
                        |> expectImpactEqual (Unit.impact 0)
                        |> asTest "should compute a zero animal-welfare ingredient bonus"
                     , bonusImpacts.total
                        |> expectImpactEqual (Unit.impact 0)
                        |> asTest "should compute a zero total bonus"
                     ]
                    )
                , describe "with non-zero bonuses applied"
                    (let
                        bonusImpacts =
                            testComputedBonuses
                                { agroDiversity = Split.half
                                , agroEcology = Split.half
                                , animalWelfare = Split.half
                                }
                     in
                     [ bonusImpacts.agroDiversity
                        |> expectImpactEqual (Unit.impact 8.223326963580142)
                        |> asTest "should compute a non-zero agro-diversity ingredient bonus"
                     , bonusImpacts.agroEcology
                        |> expectImpactEqual (Unit.impact 8.223326963580142)
                        |> asTest "should compute a non-zero agro-ecology ingredient bonus"
                     , bonusImpacts.animalWelfare
                        |> expectImpactEqual (Unit.impact 5.3630393240740055)
                        |> asTest "should compute a non-zero animal-welfare ingredient bonus"
                     , bonusImpacts.total
                        |> expectImpactEqual (Unit.impact 21.80969325123429)
                        |> asTest "should compute a non-zero total bonus"
                     ]
                    )
                , describe "with maluses avoided"
                    (let
                        bonusImpacts =
                            Impact.impactsFromDefinitons builderDb.impacts
                                |> Impact.updateImpact (Impact.trg "ecs") (Unit.impact 1000)
                                |> Impact.updateImpact (Impact.trg "ldu") (Unit.impact -100)
                                |> Recipe.computeIngredientBonusesImpacts builderDb.impacts
                                    { agroDiversity = Split.full
                                    , agroEcology = Split.full
                                    , animalWelfare = Split.full
                                    }
                     in
                     [ bonusImpacts.agroDiversity
                        |> expectImpactEqual (Unit.impact 0)
                        |> asTest "should compute a zero agro-diversity ingredient bonus"
                     , bonusImpacts.agroEcology
                        |> expectImpactEqual (Unit.impact 0)
                        |> asTest "should compute a zero agro-ecology ingredient bonus"
                     , bonusImpacts.animalWelfare
                        |> expectImpactEqual (Unit.impact 0)
                        |> asTest "should compute a zero animal-welfare ingredient bonus"
                     , bonusImpacts.total
                        |> expectImpactEqual (Unit.impact 0)
                        |> asTest "should compute a zero total bonus"
                     ]
                    )
                ]
            , let
                recipe =
                    carrotCake
                        |> Recipe.fromQuery builderDb
              in
              describe "fromQuery"
                [ recipe
                    |> Expect.ok
                    |> asTest "should return an Ok for a valid query"
                , { carrotCake
                    | transform =
                        Just
                            { code = Process.codeFromString "not a process"
                            , mass = Mass.kilograms 0
                            }
                  }
                    |> Recipe.fromQuery builderDb
                    |> Result.map .transform
                    |> Expect.err
                    |> asTest "should return an Err for an invalid processing"
                , { carrotCake
                    | ingredients =
                        carrotCake.ingredients
                            |> List.map (\ingredient -> { ingredient | planeTransport = Ingredient.ByPlane })
                  }
                    |> Recipe.fromQuery builderDb
                    |> Expect.err
                    |> asTest "should return an Err for an invalid 'planeTransport' value for an ingredient without a default origin by plane"
                ]
            , describe "compute"
                [ describe "standard carrot cake"
                    (let
                        carrotCakeResults =
                            carrotCake
                                |> Recipe.compute builderDb
                     in
                     [ carrotCakeResults
                        |> Result.map (Tuple.second >> .total >> AnyDict.toDict)
                        |> Result.withDefault Dict.empty
                        |> Dict.map (\_ v -> Unit.impactToFloat v > 0)
                        |> Expect.equal
                            (Dict.fromList
                                -- Note: presented that way to ease diff viewing in test results
                                [ ( "acd", True )
                                , ( "bvi", True )
                                , ( "cch", True )
                                , ( "ecs", True )
                                , ( "etf", True )
                                , ( "fru", True )
                                , ( "fwe", True )
                                , ( "htc", True )
                                , ( "htn", True )
                                , ( "ior", True )
                                , ( "ldu", True )
                                , ( "mru", True )
                                , ( "ozd", True )
                                , ( "pco", True )
                                , ( "pef", True )
                                , ( "pma", True )
                                , ( "swe", True )
                                , ( "tre", True )
                                , ( "wtu", True )
                                , ( "htc-c", True )
                                , ( "etf-c", True )
                                , ( "htn-c", True )
                                ]
                            )
                        |> asTest "should return computed impacts where none equals zero"
                     , carrotCakeResults
                        |> Result.map (Tuple.second >> .scoring)
                        |> (\scoringResult ->
                                case scoringResult of
                                    Err err ->
                                        Expect.fail err
                                            |> asTest "should not fail"

                                    Ok scoring ->
                                        Expect.equal scoring
                                            { all = { impact = Unit.impact 200.6770301483096, letter = "B", outOf100 = 64 }
                                            , biodiversity = { impact = Unit.impact 91.6347570526944, letter = "A", outOf100 = 81 }
                                            , category = "Gâteaux"
                                            , climate = { impact = Unit.impact 42.550812211063175, letter = "B", outOf100 = 64 }
                                            , health = { impact = Unit.impact 32.502308215624524, letter = "A", outOf100 = 92 }
                                            , resources = { impact = Unit.impact 36.12268791220873, letter = "C", outOf100 = 51 }
                                            }
                                            |> asTest "should be properly scored"
                           )
                     ]
                    )
                , describe "raw-to-cooked checks"
                    [ -- Carrot cake is cooked at plant, let's apply oven cooking at consumer: the
                      -- raw-to-cooked ratio should have been applied to resulting mass just once.
                      let
                        withPreps preps =
                            { carrotCake | preparation = preps }
                                |> Recipe.compute builderDb
                                |> Result.map (Tuple.second >> .preparedMass >> Mass.inKilograms)
                                |> Result.withDefault 0
                      in
                      withPreps [ Preparation.Id "oven" ]
                        |> Expect.within (Expect.Absolute 0.0001) (withPreps [])
                        |> asTest "should apply raw-to-cooked ratio once"
                    ]
                ]
            , describe "getMassAtPackaging"
                [ { ingredients =
                        [ { id = Ingredient.idFromString "egg"
                          , mass = Mass.grams 120
                          , variant = Query.DefaultVariant
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          , bonuses = Nothing
                          }
                        , { id = Ingredient.idFromString "wheat"
                          , mass = Mass.grams 140
                          , variant = Query.DefaultVariant
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          , bonuses = Nothing
                          }
                        ]
                  , transform = Nothing
                  , packaging = []
                  , category = Nothing
                  , distribution = Nothing
                  , preparation = []
                  }
                    |> Recipe.compute builderDb
                    |> Result.map (Tuple.first >> Recipe.getMassAtPackaging)
                    |> Expect.equal (Ok (Mass.kilograms 0.26))
                    |> asTest "should compute recipe ingredients mass with no cooking involved"
                , carrotCake
                    |> Recipe.compute builderDb
                    |> Result.map (Tuple.first >> Recipe.getMassAtPackaging)
                    |> Expect.equal (Ok (Mass.kilograms 0.79074))
                    |> asTest "should compute recipe ingredients mass applying raw to cooked ratio"
                ]
            , let
                carrotCakeWithPackaging =
                    carrotCake
                        |> Recipe.compute builderDb
                        |> Result.map (Tuple.first >> Recipe.getTransformedIngredientsMass)

                carrotCakeWithNoPackaging =
                    { carrotCake | packaging = [] }
                        |> Recipe.compute builderDb
                        |> Result.map (Tuple.first >> Recipe.getTransformedIngredientsMass)
              in
              describe "getTransformedIngredientsMass"
                [ carrotCakeWithPackaging
                    |> Expect.equal (Ok (Mass.kilograms 0.68574))
                    |> asTest "should compute recipe treansformed ingredients mass excluding packaging one"
                , carrotCakeWithPackaging
                    |> Expect.equal carrotCakeWithNoPackaging
                    |> asTest "should give the same mass including packaging or not"
                ]
            , let
                mango =
                    { id = Ingredient.idFromString "mango"
                    , mass = Mass.grams 120
                    , variant = Query.DefaultVariant
                    , country = Nothing
                    , planeTransport = Ingredient.ByPlane
                    , bonuses = Nothing
                    }

                firstIngredientAirDistance ( recipe, _ ) =
                    recipe
                        |> .ingredients
                        |> List.head
                        |> Maybe.map (Recipe.computeIngredientTransport builderDb)
                        |> Maybe.map .air
                        |> Maybe.map Length.inKilometers
              in
              describe "computeIngredientTransport"
                [ { ingredients =
                        [ { id = Ingredient.idFromString "egg"
                          , mass = Mass.grams 120
                          , variant = Query.DefaultVariant
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          , bonuses = Nothing
                          }
                        ]
                  , transform = Nothing
                  , packaging = []
                  , category = Nothing
                  , distribution = Nothing
                  , preparation = []
                  }
                    |> Recipe.compute builderDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 0))
                    |> asTest "should have no air transport for standard ingredients"
                , { ingredients = [ mango ]
                  , transform = Nothing
                  , packaging = []
                  , category = Nothing
                  , distribution = Nothing
                  , preparation = []
                  }
                    |> Recipe.compute builderDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 18000))
                    |> asTest "should have air transport for mango from its default origin"
                , { ingredients = [ { mango | country = Just (Country.codeFromString "CN"), planeTransport = Ingredient.ByPlane } ]
                  , transform = Nothing
                  , packaging = []
                  , category = Nothing
                  , distribution = Just Retail.ambient
                  , preparation = []
                  }
                    |> Recipe.compute builderDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 8189))
                    |> asTest "should always have air transport for mango even from other countries if 'planeTransport' is 'byPlane'"
                , { ingredients = [ { mango | country = Just (Country.codeFromString "CN"), planeTransport = Ingredient.NoPlane } ]
                  , transform = Nothing
                  , packaging = []
                  , category = Nothing
                  , distribution = Just Retail.ambient
                  , preparation = []
                  }
                    |> Recipe.compute builderDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 0))
                    |> asTest "should not have air transport for mango from other countries if 'planeTransport' is 'noPlane'"
                ]
            ]
        )
