module Data.Food.RecipeTest exposing (..)

import Data.Country as Country
import Data.Food.Ingredient as Ingredient
import Data.Food.Preparation as Preparation
import Data.Food.Process as Process
import Data.Food.Query exposing (carrotCake)
import Data.Food.Recipe as Recipe
import Data.Food.Retail as Retail
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Split as Split
import Data.Unit as Unit
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
        (\{ foodDb } ->
            [ let
                testComputedBonuses bonuses =
                    Impact.empty
                        |> Impact.updateImpact foodDb.impactDefinitions Definition.Ecs (Unit.impact 1000)
                        |> Impact.updateImpact foodDb.impactDefinitions Definition.Ldu (Unit.impact 100)
                        |> Recipe.computeIngredientComplementsImpacts foodDb.impactDefinitions bonuses
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
                            Impact.empty
                                |> Impact.updateImpact foodDb.impactDefinitions Definition.Ecs (Unit.impact 1000)
                                |> Impact.updateImpact foodDb.impactDefinitions Definition.Ldu (Unit.impact -100)
                                |> Recipe.computeIngredientComplementsImpacts foodDb.impactDefinitions
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
                        |> Recipe.fromQuery foodDb
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
                    |> Recipe.fromQuery foodDb
                    |> Result.map .transform
                    |> Expect.err
                    |> asTest "should return an Err for an invalid processing"
                , { carrotCake
                    | ingredients =
                        carrotCake.ingredients
                            |> List.map (\ingredient -> { ingredient | planeTransport = Ingredient.ByPlane })
                  }
                    |> Recipe.fromQuery foodDb
                    |> Expect.err
                    |> asTest "should return an Err for an invalid 'planeTransport' value for an ingredient without a default origin by plane"
                ]
            , describe "compute"
                [ describe "standard carrot cake"
                    (let
                        carrotCakeResults =
                            carrotCake
                                |> Recipe.compute foodDb
                     in
                     [ carrotCakeResults
                        |> Result.map (Tuple.second >> .total)
                        |> Result.withDefault Impact.empty
                        |> TestUtils.expectImpactsEqual
                            { acd = Expect.greaterThan 0
                            , bvi = Expect.greaterThan 0
                            , cch = Expect.greaterThan 0
                            , ecs = Expect.greaterThan 0
                            , etf = Expect.greaterThan 0
                            , etfc = Expect.greaterThan 0
                            , fru = Expect.greaterThan 0
                            , fwe = Expect.greaterThan 0
                            , htc = Expect.greaterThan 0
                            , htcc = Expect.greaterThan 0
                            , htn = Expect.greaterThan 0
                            , htnc = Expect.greaterThan 0
                            , ior = Expect.greaterThan 0
                            , ldu = Expect.greaterThan 0
                            , mru = Expect.greaterThan 0
                            , ozd = Expect.greaterThan 0
                            , pco = Expect.greaterThan 0
                            , pef = Expect.greaterThan 0
                            , pma = Expect.greaterThan 0
                            , swe = Expect.greaterThan 0
                            , tre = Expect.greaterThan 0
                            , wtu = Expect.greaterThan 0
                            }
                        |> asTest "should return computed impacts where none equals zero"
                     , carrotCakeResults
                        |> Result.map (Tuple.second >> .recipe >> .edibleMass >> Mass.inKilograms)
                        |> Result.withDefault -99
                        |> Expect.within (Expect.Absolute 0.01) 0.498
                        |> asTest "should compute ingredients total edible mass"
                     , asTest "should have the total ecs impact with the bonus taken into account"
                        (case carrotCakeResults |> Result.map (Tuple.second >> .recipe >> .total >> Impact.getImpact Definition.Ecs) of
                            Err err ->
                                Expect.fail err

                            Ok result ->
                                expectImpactEqual (Unit.impact 105.29418862349635) result
                        )
                     , asTest "should have the ingredients' total ecs impact with the bonus taken into account"
                        (case carrotCakeResults |> Result.map (Tuple.second >> .recipe >> .ingredientsTotal >> Impact.getImpact Definition.Ecs) of
                            Err err ->
                                Expect.fail err

                            Ok result ->
                                expectImpactEqual (Unit.impact 70.09274662006072) result
                        )
                     , describe "Scoring"
                        (case carrotCakeResults |> Result.map (Tuple.second >> .scoring) of
                            Err err ->
                                [ Expect.fail err
                                    |> asTest "should not fail"
                                ]

                            Ok scoring ->
                                [ Unit.impactToFloat scoring.all
                                    |> Expect.within (Expect.Absolute 0.01) 197.5434382752016
                                    |> asTest "should properly score total impact"
                                , Unit.impactToFloat scoring.allWithoutComplements
                                    |> Expect.within (Expect.Absolute 0.01) 199.6747135759378
                                    |> asTest "should properly score total impact without bonuses"
                                , Unit.impactToFloat scoring.complements
                                    |> Expect.within (Expect.Absolute 0.01) 2.131275300736198
                                    |> asTest "should properly score bonuses impact"
                                , (Unit.impactToFloat scoring.allWithoutComplements - Unit.impactToFloat scoring.complements)
                                    |> Expect.within (Expect.Absolute 0.0001) (Unit.impactToFloat scoring.all)
                                    |> asTest "should expose coherent scoring"
                                , Unit.impactToFloat scoring.biodiversity
                                    |> Expect.within (Expect.Absolute 0.01) 82.01286082017239
                                    |> asTest "should properly score impact on biodiversity protected area"
                                , Unit.impactToFloat scoring.climate
                                    |> Expect.within (Expect.Absolute 0.01) 44.68689760990337
                                    |> asTest "should properly score impact on climate protected area"
                                , Unit.impactToFloat scoring.health
                                    |> Expect.within (Expect.Absolute 0.01) 39.895732543122364
                                    |> asTest "should properly score impact on health protected area"
                                , Unit.impactToFloat scoring.resources
                                    |> Expect.within (Expect.Absolute 0.01) 33.07922260273967
                                    |> asTest "should properly score impact on resources protected area"
                                ]
                        )
                     ]
                    )
                , describe "raw-to-cooked checks"
                    [ -- Carrot cake is cooked at plant, let's apply oven cooking at consumer: the
                      -- raw-to-cooked ratio should have been applied to resulting mass just once.
                      let
                        withPreps preps =
                            { carrotCake | preparation = preps }
                                |> Recipe.compute foodDb
                                |> Result.map (Tuple.second >> .preparedMass >> Mass.inKilograms)
                                |> Result.withDefault 0
                      in
                      withPreps [ Preparation.Id "oven" ]
                        |> Expect.within (Expect.Absolute 0.0001) (withPreps [])
                        |> asTest "should apply raw-to-cooked ratio once"
                    ]
                , describe "custom ingredient bonuses"
                    [ let
                        computeEcoscore =
                            Recipe.compute foodDb
                                >> Result.map (Tuple.second >> .total >> Impact.getImpact Definition.Ecs >> Unit.impactToFloat)
                                >> Result.withDefault 0

                        carrotCakeResults =
                            computeEcoscore carrotCake

                        customBonusesResults =
                            computeEcoscore
                                { carrotCake
                                    | ingredients =
                                        carrotCake.ingredients
                                            |> List.map
                                                (\ingredientQuery ->
                                                    if ingredientQuery.id == Ingredient.Id "carrot" then
                                                        { ingredientQuery
                                                            | complements =
                                                                Just
                                                                    { agroDiversity = Split.full
                                                                    , agroEcology = Split.zero
                                                                    , animalWelfare = Split.zero
                                                                    }
                                                        }

                                                    else
                                                        ingredientQuery
                                                )
                                }
                      in
                      carrotCakeResults
                        |> Expect.greaterThan customBonusesResults
                        |> asTest "should apply custom bonuses"
                    ]
                ]
            , describe "getMassAtPackaging"
                [ { ingredients =
                        [ { id = Ingredient.idFromString "egg"
                          , mass = Mass.grams 120
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          , complements = Nothing
                          }
                        , { id = Ingredient.idFromString "wheat"
                          , mass = Mass.grams 140
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          , complements = Nothing
                          }
                        ]
                  , transform = Nothing
                  , packaging = []
                  , distribution = Nothing
                  , preparation = []
                  }
                    |> Recipe.compute foodDb
                    |> Result.map (Tuple.first >> Recipe.getMassAtPackaging)
                    |> Expect.equal (Ok (Mass.kilograms 0.23600000000000002))
                    |> asTest "should compute recipe ingredients mass with no cooking involved"
                , carrotCake
                    |> Recipe.compute foodDb
                    |> Result.map (Tuple.first >> Recipe.getMassAtPackaging)
                    |> Expect.equal (Ok (Mass.kilograms 0.748104))
                    |> asTest "should compute recipe ingredients mass applying raw to cooked ratio"
                ]
            , let
                carrotCakeWithPackaging =
                    carrotCake
                        |> Recipe.compute foodDb
                        |> Result.map (Tuple.first >> Recipe.getTransformedIngredientsMass)

                carrotCakeWithNoPackaging =
                    { carrotCake | packaging = [] }
                        |> Recipe.compute foodDb
                        |> Result.map (Tuple.first >> Recipe.getTransformedIngredientsMass)
              in
              describe "getTransformedIngredientsMass"
                [ carrotCakeWithPackaging
                    |> Expect.equal (Ok (Mass.kilograms 0.643104))
                    |> asTest "should compute recipe treansformed ingredients mass excluding packaging one"
                , carrotCakeWithPackaging
                    |> Expect.equal carrotCakeWithNoPackaging
                    |> asTest "should give the same mass including packaging or not"
                ]
            , let
                mango =
                    { id = Ingredient.idFromString "mango"
                    , mass = Mass.grams 120
                    , country = Nothing
                    , planeTransport = Ingredient.ByPlane
                    , complements = Nothing
                    }

                firstIngredientAirDistance ( recipe, _ ) =
                    recipe
                        |> .ingredients
                        |> List.head
                        |> Maybe.map (Recipe.computeIngredientTransport foodDb)
                        |> Maybe.map .air
                        |> Maybe.map Length.inKilometers
              in
              describe "computeIngredientTransport"
                [ { ingredients =
                        [ { id = Ingredient.idFromString "egg"
                          , mass = Mass.grams 120
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          , complements = Nothing
                          }
                        ]
                  , transform = Nothing
                  , packaging = []
                  , distribution = Nothing
                  , preparation = []
                  }
                    |> Recipe.compute foodDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 0))
                    |> asTest "should have no air transport for standard ingredients"
                , { ingredients = [ mango ]
                  , transform = Nothing
                  , packaging = []
                  , distribution = Nothing
                  , preparation = []
                  }
                    |> Recipe.compute foodDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 18000))
                    |> asTest "should have air transport for mango from its default origin"
                , { ingredients = [ { mango | country = Just (Country.codeFromString "CN"), planeTransport = Ingredient.ByPlane } ]
                  , transform = Nothing
                  , packaging = []
                  , distribution = Just Retail.ambient
                  , preparation = []
                  }
                    |> Recipe.compute foodDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 8189))
                    |> asTest "should always have air transport for mango even from other countries if 'planeTransport' is 'byPlane'"
                , { ingredients = [ { mango | country = Just (Country.codeFromString "CN"), planeTransport = Ingredient.NoPlane } ]
                  , transform = Nothing
                  , packaging = []
                  , distribution = Just Retail.ambient
                  , preparation = []
                  }
                    |> Recipe.compute foodDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 0))
                    |> asTest "should not have air transport for mango from other countries if 'planeTransport' is 'noPlane'"
                ]
            ]
        )
