module Data.Food.Builder.RecipeTest exposing (..)

import Data.Country as Country
import Data.Food.Builder.Query as Query exposing (carrotCake)
import Data.Food.Builder.Recipe as Recipe
import Data.Food.Ingredient as Ingredient
import Data.Food.Process as Process
import Data.Food.Retail as Retail
import Data.Unit as Unit
import Dict
import Dict.Any as AnyDict
import Expect
import Length
import Mass
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Data.Food.Builder.Recipe"
        (\{ builderDb } ->
            [ let
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
                            ]
                        )
                    |> asTest "should return computed impacts where none equals zero"
                 , carrotCakeResults
                    |> Result.map (Tuple.second >> .scoring)
                    |> Expect.equal
                        (Ok
                            { category = "Gâteaux"
                            , climate = { impact = Unit.impact 31.465751984674757, letter = "B", outOf100 = 79 }
                            , all = { impact = Unit.impact 169.83232687747997, letter = "B", outOf100 = 72 }
                            , biodiversity = { impact = Unit.impact 131.39490621544522, letter = "B", outOf100 = 62 }
                            , health = { impact = Unit.impact 46.77851948542256, letter = "B", outOf100 = 73 }
                            , resources = { impact = Unit.impact 23.268322876906748, letter = "B", outOf100 = 74 }
                            }
                        )
                    |> asTest "should return expected scoring"
                 ]
                )
            , describe "getMassAtPackaging"
                [ { ingredients =
                        [ { id = Ingredient.idFromString "egg"
                          , name = "Oeuf"
                          , mass = Mass.grams 120
                          , variant = Query.Default
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          }
                        , { id = Ingredient.idFromString "wheat"
                          , name = "Blé tendre"
                          , mass = Mass.grams 140
                          , variant = Query.Default
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          }
                        ]
                  , transform = Nothing
                  , packaging = []
                  , category = Nothing
                  , distribution = Retail.ambient
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
                    , name = "Mangue"
                    , mass = Mass.grams 120
                    , variant = Query.Default
                    , country = Nothing
                    , planeTransport = Ingredient.ByPlane
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
                          , name = "Oeuf"
                          , mass = Mass.grams 120
                          , variant = Query.Default
                          , country = Nothing
                          , planeTransport = Ingredient.PlaneNotApplicable
                          }
                        ]
                  , transform = Nothing
                  , packaging = []
                  , category = Nothing
                  , distribution = Retail.ambient
                  }
                    |> Recipe.compute builderDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 0))
                    |> asTest "should have no air transport for standard ingredients"
                , { ingredients = [ mango ]
                  , transform = Nothing
                  , packaging = []
                  , category = Nothing
                  , distribution = Retail.ambient
                  }
                    |> Recipe.compute builderDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 18000))
                    |> asTest "should have air transport for mango from its default origin"
                , { ingredients = [ { mango | country = Just (Country.codeFromString "CN"), planeTransport = Ingredient.ByPlane } ]
                  , transform = Nothing
                  , packaging = []
                  , category = Nothing
                  , distribution = Retail.ambient
                  }
                    |> Recipe.compute builderDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 8189))
                    |> asTest "should always have air transport for mango even from other countries if 'planeTransport' is 'byPlane'"
                , { ingredients = [ { mango | country = Just (Country.codeFromString "CN"), planeTransport = Ingredient.NoPlane } ]
                  , transform = Nothing
                  , packaging = []
                  , category = Nothing
                  , distribution = Retail.ambient
                  }
                    |> Recipe.compute builderDb
                    |> Result.map firstIngredientAirDistance
                    |> Expect.equal (Ok (Just 0))
                    |> asTest "should not have air transport for mango from other countries if 'planeTransport' is 'noPlane'"
                ]
            ]
        )
