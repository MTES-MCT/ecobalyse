module Data.Food.RecipeTest exposing (..)

import Data.Country as Country
import Data.Example
import Data.Food.Ingredient as Ingredient
import Data.Food.Preparation as Preparation
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
    Unit.impactToFloat
        >> Expect.within (Expect.Relative 0.000000001) (Unit.impactToFloat expectedImpactUnit)


suite : Test
suite =
    suiteWithDb "Data.Food.Recipe"
        (\db ->
            case
                ( db.food.examples
                    |> Data.Example.findByName "Pizza royale (350g) - 6"
                    |> Result.map .query
                , ( Ingredient.idFromString "9cbc31e9-80a4-4b87-ac4b-ddc051c47f69"
                  , Ingredient.idFromString "db0e5f44-34b4-4160-b003-77c828d75e60"
                  , Ingredient.idFromString "38788025-a65e-4edf-a92f-aab0b89b0d61"
                  )
                )
            of
                ( Ok royalPizza, ( Just eggId, Just mangoId, Just wheatId ) ) ->
                    [ let
                        testComputedComplements complements =
                            Recipe.computeIngredientComplementsImpacts complements (Mass.kilograms 2)
                      in
                      describe "computeIngredientComplementsImpacts"
                        [ describe "with zero complements applied"
                            (let
                                complementsImpacts =
                                    testComputedComplements
                                        { hedges = Unit.noImpacts
                                        , plotSize = Unit.noImpacts
                                        , cropDiversity = Unit.noImpacts
                                        , permanentPasture = Unit.noImpacts
                                        , livestockDensity = Unit.noImpacts
                                        }
                             in
                             [ complementsImpacts.hedges
                                |> expectImpactEqual Unit.noImpacts
                                |> asTest "should compute a zero hedges ingredient complement"
                             , Impact.getTotalComplementsImpacts complementsImpacts
                                |> expectImpactEqual Unit.noImpacts
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
                            | ingredients =
                                royalPizza.ingredients
                                    |> List.map (\ingredient -> { ingredient | planeTransport = Ingredient.ByPlane })
                          }
                            |> Recipe.fromQuery db
                            |> Expect.err
                            |> asTest "should return an Err for an invalid 'planeTransport' value for an ingredient without a default origin by plane"
                        ]
                    , describe "compute"
                        [ describe "standard royal pizza"
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
                                        Unit.impactToFloat result
                                            |> Expect.within (Expect.Absolute 0.1) 127.1
                                )
                             , asTest "should have the ingredients' total ecs impact with the complement taken into account"
                                (case royalPizzaResults |> Result.map (Tuple.second >> .recipe >> .ingredientsTotal >> Impact.getImpact Definition.Ecs) of
                                    Err err ->
                                        Expect.fail err

                                    Ok result ->
                                        Unit.impactToFloat result
                                            |> Expect.within (Expect.Absolute 0.1) 104.0
                                )
                             , describe "Scoring"
                                (case royalPizzaResults |> Result.map (Tuple.second >> .scoring) of
                                    Err err ->
                                        [ Expect.fail err
                                            |> asTest "should not fail"
                                        ]

                                    Ok scoring ->
                                        [ Unit.impactToFloat scoring.all
                                            |> Expect.within (Expect.Absolute 0.01) 445.78
                                            |> asTest "should properly score total impact"
                                        , Unit.impactToFloat scoring.allWithoutComplements
                                            |> Expect.within (Expect.Absolute 0.01) 444.58
                                            |> asTest "should properly score total impact without complements"
                                        , Unit.impactToFloat scoring.complements
                                            |> Expect.within (Expect.Absolute 0.01) -1.2003674159062077
                                            |> asTest "should properly score complement impact"
                                        , (Unit.impactToFloat scoring.allWithoutComplements - Unit.impactToFloat scoring.complements)
                                            |> Expect.within (Expect.Absolute 0.0001) (Unit.impactToFloat scoring.all)
                                            |> asTest "should expose coherent scoring"
                                        , Unit.impactToFloat scoring.biodiversity
                                            |> Expect.within (Expect.Absolute 0.01) 186.65
                                            |> asTest "should properly score impact on biodiversity protected area"
                                        , Unit.impactToFloat scoring.climate
                                            |> Expect.within (Expect.Absolute 0.01) 106.46364692095277
                                            |> asTest "should properly score impact on climate protected area"
                                        , Unit.impactToFloat scoring.health
                                            |> Expect.within (Expect.Absolute 0.01) 48.16
                                            |> asTest "should properly score impact on health protected area"
                                        , Unit.impactToFloat scoring.resources
                                            |> Expect.within (Expect.Absolute 0.01) 103.3
                                            |> asTest "should properly score impact on resources protected area"
                                        ]
                                )
                             ]
                            )
                        , describe "raw-to-cooked checks"
                            [ -- Royal pizza is cooked at plant, let's apply oven cooking at consumer: the
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
                                [ { id = eggId
                                  , mass = Mass.grams 120
                                  , country = Nothing
                                  , planeTransport = Ingredient.PlaneNotApplicable
                                  }
                                , { id = wheatId
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
                            |> Expect.equal (Ok (Mass.kilograms 0.4398824000000001))
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
                            |> Expect.equal (Ok (Mass.kilograms 0.3398824000000001))
                            |> asTest "should compute recipe treansformed ingredients mass excluding packaging one"
                        , royalPizzaWithPackaging
                            |> Expect.equal royalPizzaWithNoPackaging
                            |> asTest "should give the same mass including packaging or not"
                        ]
                    , let
                        mango =
                            { id = mangoId
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
                                [ { id = eggId
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

                _ ->
                    [ Expect.fail "error getting examples"
                        |> asTest "should retrieve Royal Pizza example and ingredients UUIDs"
                    ]
        )
