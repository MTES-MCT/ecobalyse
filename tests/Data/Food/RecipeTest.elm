module Data.Food.RecipeTest exposing (..)

import Data.Country as Country
import Data.Food.Fixtures exposing (royalPizza)
import Data.Food.Ingredient as Ingredient
import Data.Food.Preparation as Preparation
import Data.Food.Process as Process
import Data.Food.Recipe as Recipe
import Data.Food.Retail as Retail
import Data.Impact as Impact
import Data.Impact.Definition as Definition
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
    suiteWithDb "Data.Food.Recipe"
        (\db ->
            [ let
                testComputedComplements complements =
                    Recipe.computeIngredientComplementsImpacts complements (Mass.kilograms 2)
              in
              describe "computeIngredientComplementsImpacts"
                [ describe "with zero complements applied"
                    (let
                        complementsImpacts =
                            testComputedComplements
                                { hedges = Unit.impact 0
                                , plotSize = Unit.impact 0
                                , cropDiversity = Unit.impact 0
                                , permanentPasture = Unit.impact 0
                                , livestockDensity = Unit.impact 0
                                }
                     in
                     [ complementsImpacts.hedges
                        |> expectImpactEqual (Unit.impact 0)
                        |> asTest "should compute a zero hedges ingredient complement"
                     , Impact.getTotalComplementsImpacts complementsImpacts
                        |> expectImpactEqual (Unit.impact 0)
                        |> asTest "should compute a zero total complement"
                     ]
                    )
                , describe "with non-zero complements applied"
                    (let
                        complementsImpacts =
                            testComputedComplements
                                { hedges = Unit.impact 1
                                , plotSize = Unit.impact 1
                                , cropDiversity = Unit.impact 1
                                , permanentPasture = Unit.impact 1
                                , livestockDensity = Unit.impact 1
                                }
                     in
                     [ complementsImpacts.hedges
                        |> expectImpactEqual (Unit.impact 6)
                        |> asTest "should compute a non-zero hedges ingredient complement"
                     , Impact.getTotalComplementsImpacts complementsImpacts
                        |> expectImpactEqual (Unit.impact 6031)
                        |> asTest "should compute a non-zero total complement"
                     ]
                    )
                ]
            , let
                recipe =
                    royalPizza
                        |> Recipe.fromQuery db
              in
              describe "fromQuery"
                [ recipe
                    |> Expect.ok
                    |> asTest "should return an Ok for a valid query"
                , { royalPizza
                    | transform =
                        Just
                            { code = Process.codeFromString "not a process"
                            , mass = Mass.kilograms 0
                            }
                  }
                    |> Recipe.fromQuery db
                    |> Result.map .transform
                    |> Expect.err
                    |> asTest "should return an Err for an invalid processing"
                , { royalPizza
                    | ingredients =
                        royalPizza.ingredients
                            |> List.map (\ingredient -> { ingredient | planeTransport = Ingredient.ByPlane })
                  }
                    |> Recipe.fromQuery db
                    |> Expect.err
                    |> asTest "should return an Err for an invalid 'planeTransport' value for an ingredient without a default origin by plane"
                ]
            , describe "compute"
                [ describe "standard carrot cake"
                    (let
                        royalPizzaResults =
                            royalPizza
                                |> Recipe.compute db
                     in
                     [ royalPizzaResults
                        |> Result.map (Tuple.second >> .total)
                        |> Result.withDefault Impact.empty
                        |> TestUtils.expectImpactsEqual
                            { acd = Expect.greaterThan 0
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
                     , royalPizzaResults
                        |> Result.map (Tuple.second >> .recipe >> .edibleMass >> Mass.inKilograms)
                        |> Result.withDefault -99
                        |> Expect.within (Expect.Absolute 0.01) 0.3439
                        |> asTest "should compute ingredients total edible mass"
                     , asTest "should have the total ecs impact with the complement taken into account"
                        (case royalPizzaResults |> Result.map (Tuple.second >> .recipe >> .total >> Impact.getImpact Definition.Ecs) of
                            Err err ->
                                Expect.fail err

                            Ok result ->
                                expectImpactEqual (Unit.impact 132.53791738069046) result
                        )
                     , asTest "should have the ingredients' total ecs impact with the complement taken into account"
                        (case royalPizzaResults |> Result.map (Tuple.second >> .recipe >> .ingredientsTotal >> Impact.getImpact Definition.Ecs) of
                            Err err ->
                                Expect.fail err

                            Ok result ->
                                expectImpactEqual (Unit.impact 106.16420108745277) result
                        )
                     , describe "Scoring"
                        (case royalPizzaResults |> Result.map (Tuple.second >> .scoring) of
                            Err err ->
                                [ Expect.fail err
                                    |> asTest "should not fail"
                                ]

                            Ok scoring ->
                                [ Unit.impactToFloat scoring.all
                                    |> Expect.within (Expect.Absolute 0.01) 484.3239828902635
                                    |> asTest "should properly score total impact"
                                , Unit.impactToFloat scoring.allWithoutComplements
                                    |> Expect.within (Expect.Absolute 0.01) 483.11174570602225
                                    |> asTest "should properly score total impact without complements"
                                , Unit.impactToFloat scoring.complements
                                    |> Expect.within (Expect.Absolute 0.01) -1.2122371842412405
                                    |> asTest "should properly score complement impact"
                                , (Unit.impactToFloat scoring.allWithoutComplements - Unit.impactToFloat scoring.complements)
                                    |> Expect.within (Expect.Absolute 0.0001) (Unit.impactToFloat scoring.all)
                                    |> asTest "should expose coherent scoring"
                                , Unit.impactToFloat scoring.biodiversity
                                    |> Expect.within (Expect.Absolute 0.01) 194.37931247785687
                                    |> asTest "should properly score impact on biodiversity protected area"
                                , Unit.impactToFloat scoring.climate
                                    |> Expect.within (Expect.Absolute 0.01) 108.35763169433548
                                    |> asTest "should properly score impact on climate protected area"
                                , Unit.impactToFloat scoring.health
                                    |> Expect.within (Expect.Absolute 0.01) 62.08054112486502
                                    |> asTest "should properly score impact on health protected area"
                                , Unit.impactToFloat scoring.resources
                                    |> Expect.within (Expect.Absolute 0.01) 118.29596222120665
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
                            { royalPizza | preparation = preps }
                                |> Recipe.compute db
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
                        [ { id = Ingredient.idFromString "egg-indoor-code3"
                          , mass = Mass.grams 120
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          }
                        , { id = Ingredient.idFromString "soft-wheat-fr"
                          , mass = Mass.grams 140
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          }
                        ]
                  , transform = Nothing
                  , packaging = []
                  , distribution = Nothing
                  , preparation = []
                  }
                    |> Recipe.compute db
                    |> Result.map (Tuple.first >> Recipe.getMassAtPackaging)
                    |> Expect.equal (Ok (Mass.kilograms 0.23600000000000002))
                    |> asTest "should compute recipe ingredients mass with no cooking involved"
                , royalPizza
                    |> Recipe.compute db
                    |> Result.map (Tuple.first >> Recipe.getMassAtPackaging)
                    |> Expect.equal (Ok (Mass.kilograms 0.4365544000000001))
                    |> asTest "should compute recipe ingredients mass applying raw to cooked ratio"
                ]
            , let
                royalPizzaWithPackaging =
                    royalPizza
                        |> Recipe.compute db
                        |> Result.map (Tuple.first >> Recipe.getTransformedIngredientsMass)

                royalPizzaWithNoPackaging =
                    { royalPizza | packaging = [] }
                        |> Recipe.compute db
                        |> Result.map (Tuple.first >> Recipe.getTransformedIngredientsMass)
              in
              describe "getTransformedIngredientsMass"
                [ royalPizzaWithPackaging
                    |> Expect.equal (Ok (Mass.kilograms 0.3365544000000001))
                    |> asTest "should compute recipe treansformed ingredients mass excluding packaging one"
                , royalPizzaWithPackaging
                    |> Expect.equal royalPizzaWithNoPackaging
                    |> asTest "should give the same mass including packaging or not"
                ]
            , let
                mango =
                    { id = Ingredient.idFromString "mango-non-eu"
                    , mass = Mass.grams 120
                    , country = Nothing
                    , planeTransport = Ingredient.ByPlane
                    }

                firstIngredientAirDistance ( recipe, _ ) =
                    recipe
                        |> .ingredients
                        |> List.head
                        |> Maybe.map (Recipe.computeIngredientTransport db)
                        |> Maybe.map .air
                        |> Maybe.map Length.inKilometers
              in
              describe "computeIngredientTransport"
                [ { ingredients =
                        [ { id = Ingredient.idFromString "egg-indoor-code3"
                          , mass = Mass.grams 120
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          }
                        ]
                  , transform = Nothing
                  , packaging = []
                  , distribution = Nothing
                  , preparation = []
                  }
                    |> Recipe.compute db
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 0))
                    |> asTest "should have no air transport for standard ingredients"
                , { ingredients = [ mango ]
                  , transform = Nothing
                  , packaging = []
                  , distribution = Nothing
                  , preparation = []
                  }
                    |> Recipe.compute db
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 18000))
                    |> asTest "should have air transport for mango from its default origin"
                , { ingredients = [ { mango | country = Just (Country.codeFromString "CN"), planeTransport = Ingredient.ByPlane } ]
                  , transform = Nothing
                  , packaging = []
                  , distribution = Just Retail.ambient
                  , preparation = []
                  }
                    |> Recipe.compute db
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 8189))
                    |> asTest "should always have air transport for mango even from other countries if 'planeTransport' is 'byPlane'"
                , { ingredients = [ { mango | country = Just (Country.codeFromString "CN"), planeTransport = Ingredient.NoPlane } ]
                  , transform = Nothing
                  , packaging = []
                  , distribution = Just Retail.ambient
                  , preparation = []
                  }
                    |> Recipe.compute db
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 0))
                    |> asTest "should not have air transport for mango from other countries if 'planeTransport' is 'noPlane'"
                ]
            ]
        )
