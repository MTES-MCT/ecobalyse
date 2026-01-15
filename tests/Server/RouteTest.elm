module Server.RouteTest exposing (..)

import Data.Component as Component
import Data.Country as Country
import Data.Example as Example
import Data.Food.Preparation as Preparation
import Data.Food.Query as FoodQuery exposing (PackagingAmount(..))
import Data.Split as Split
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Data.Textile.Query as TextileQuery
import Data.Unit as Unit
import Dict
import Expect
import Json.Encode as Encode
import Mass
import Server.Route as Route
import Static.Db as StaticDb
import Test exposing (..)
import TestUtils exposing (asTest, createServerRequest, suiteFromResult, suiteWithDb, tShirtCotonFrance)


suite : Test
suite =
    suiteWithDb "Route"
        (\db ->
            [ foodEndpoints db
                |> describe "Food"
            , textileEndpoints db
                |> describe "Textile"
            ]
        )


foodEndpoints : StaticDb.Db -> List Test
foodEndpoints db =
    case
        db.food.examples
            |> Example.findByName "Pizza royale (350g) - 6"
            |> Result.map .query
    of
        Err err ->
            [ Expect.fail err
                |> asTest "retrieve Royal Pizza example"
            ]

        Ok royalPizza ->
            [ describe "POST endpoints"
                [ FoodQuery.encode royalPizza
                    |> testFoodEndpoint db
                    |> Expect.equal (Just (Route.FoodPostRecipe (Ok royalPizza)))
                    |> asTest "map the POST /food endpoint"
                , Encode.null
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "decoding" "Expecting an OBJECT with a field named `ingredients`"
                    |> asTest "fail on invalid query passed"
                , FoodQuery.encode royalPizza
                    |> testFoodEndpoint db
                    |> Expect.equal (Just (Route.FoodPostRecipe (Ok royalPizza)))
                    |> asTest "map the POST /food endpoint with the body parsed as a valid query"
                ]
            , describe "validation"
                [ FoodQuery.encode
                    { royalPizza
                        | ingredients =
                            royalPizza.ingredients |> List.map (\i -> { i | mass = Mass.grams -1 })
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "ingredients" "La masse doit être supérieure à zéro"
                    |> asTest "validate an ingredient invalid mass"
                , FoodQuery.encode
                    { royalPizza
                        | ingredients =
                            royalPizza.ingredients |> List.map (\i -> { i | country = Just <| Country.Code "XX" })
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "ingredients" "Code pays invalide: XX."
                    |> asTest "validate an ingredient invalid country code"
                , FoodQuery.encode
                    { royalPizza
                        | ingredients =
                            royalPizza.ingredients |> List.map (\i -> { i | country = Just <| Country.Code "BD" })
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "ingredients" "Le code pays BD n'est pas utilisable dans un contexte Alimentaire."
                    |> asTest "validate an ingredient incompatible country code"
                , FoodQuery.encode
                    { royalPizza
                        | transform = royalPizza.transform |> Maybe.map (\t -> { t | mass = Mass.grams -1 })
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "transform" "La masse doit être supérieure à zéro"
                    |> asTest "validate a transform mass"
                , FoodQuery.encode
                    { royalPizza
                        | packaging = royalPizza.packaging |> List.map (\p -> { p | amount = ItemAmount -1 })
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "packaging" "La quantité doit être supérieure à zéro"
                    |> asTest "validate a packaging mass"
                , FoodQuery.encode
                    { royalPizza
                        | preparation = Preparation.all |> List.map .id
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "preparation" "La liste 'preparation' doit contenir 2 élément(s) maximum."
                    |> asTest "validate a preparation list length"
                ]
            ]


textileEndpoints : StaticDb.Db -> List Test
textileEndpoints db =
    [ describe "POST endpoints"
        [ suiteFromResult "should map the POST /textile/simulator endpoint with the body parsed as a valid query"
            tShirtCotonFrance
            (\query ->
                [ TextileQuery.encode query
                    |> testTextileEndpoint db
                    |> Expect.equal (Just (Route.TextilePostSimulator (Ok query)))
                    |> asTest "map the POST /textile/simulator endpoint with the body parsed as a valid query"
                ]
            )
        , Encode.null
            |> testTextileEndpoint db
            |> expectTextileValidationError "decoding" "Expecting an OBJECT with a field named `product`"
            |> asTest "map the POST /textile/simulator endpoint with an error when json body is invalid"
        , suiteFromResult "should reject invalid product"
            tShirtCotonFrance
            (\query ->
                [ TextileQuery.encode
                    { query
                        | product = Product.idFromString "invalid"
                    }
                    |> testTextileEndpoint db
                    |> expectTextileValidationError "product" "Produit non trouvé id=invalid."
                    |> asTest "reject invalid product"
                ]
            )
        , suiteFromResult "should reject invalid surfaceMass"
            tShirtCotonFrance
            (\query ->
                [ TextileQuery.encode
                    { query
                        | surfaceMass =
                            Just <| Unit.gramsPerSquareMeter 999
                    }
                    |> testTextileEndpoint db
                    |> expectTextileValidationError "surfaceMass" "La masse surfacique doit être compris(e) entre 80 et 500."
                    |> asTest "reject invalid surfaceMass"
                ]
            )
        , suiteFromResult "should reject invalid physicalDurability"
            tShirtCotonFrance
            (\query ->
                [ TextileQuery.encode
                    { query
                        | physicalDurability =
                            Just <| Unit.physicalDurability 9900000
                    }
                    |> testTextileEndpoint db
                    |> expectTextileValidationError "physicalDurability" "Le coefficient de durabilité physique doit être compris(e) entre 0.67 et 1.45."
                    |> asTest "reject invalid physicalDurability"
                ]
            )
        , suiteFromResult "should reject invalid spinning country"
            tShirtCotonFrance
            (\query ->
                [ TextileQuery.encode
                    { query
                        | countrySpinning = Just (Country.Code "invalid")
                    }
                    |> testTextileEndpoint db
                    |> expectTextileValidationError "countrySpinning" "Code pays invalide: invalid."
                    |> asTest "reject invalid spinning country"
                ]
            )
        , TestUtils.suiteFromResult2
            "should reject invalid materials country"
            tShirtCotonFrance
            (Material.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84")
            (\query decodedId ->
                [ TextileQuery.encode
                    { query
                        | materials =
                            [ { id = decodedId
                              , share = Split.full
                              , spinning = Nothing
                              , country = Just (Country.Code "invalid")
                              }
                            ]
                    }
                    |> testTextileEndpoint db
                    |> expectTextileValidationError "materials" "Code pays invalide: invalid."
                    |> asTest "reject invalid materials country"
                ]
            )
        ]
    , describe "materials param checks"
        [ suiteFromResult "should validate empty material list"
            tShirtCotonFrance
            (\query ->
                [ TextileQuery.encode
                    { query
                        | materials = []
                    }
                    |> testTextileEndpoint db
                    |> expectTextileValidationError "materials" "La liste 'materials' doit contenir 1 élément(s) minimum."
                    |> asTest "validate empty material list"
                ]
            )
        , TestUtils.suiteFromResult2
            "should validate invalid material format"
            tShirtCotonFrance
            (Material.idFromString "1c686e00-6db8-469e-8d7f-3864bd3238bd")
            (\query decodedId ->
                [ TextileQuery.encode
                    { query
                        | materials =
                            [ { id = decodedId
                              , share = Split.full
                              , spinning = Nothing
                              , country = Nothing
                              }
                            ]
                    }
                    |> testTextileEndpoint db
                    |> expectTextileValidationError "materials" "Matière non trouvée id=1c686e00-6db8-469e-8d7f-3864bd3238bd."
                    |> asTest "validate invalid material format"
                ]
            )
        , TestUtils.suiteFromResult2
            "should validate a material country code"
            tShirtCotonFrance
            (Material.idFromString "62a4d6fb-3276-4ba5-93a3-889ecd3bff84")
            (\query decodedId ->
                [ TextileQuery.encode
                    { query
                        | materials =
                            [ { id = decodedId
                              , share = Split.full
                              , spinning = Nothing
                              , country = Just (Country.Code "NotACountryCode")
                              }
                            ]
                    }
                    |> testTextileEndpoint db
                    |> expectTextileValidationError "materials" "Code pays invalide: NotACountryCode."
                    |> asTest "validate a material country code"
                ]
            )
        , suiteFromResult "should validate that an ingredient country scope is valid"
            tShirtCotonFrance
            (\query ->
                [ TextileQuery.encode
                    { query
                        | countryDyeing = Just <| Country.Code "US"
                    }
                    |> testTextileEndpoint db
                    |> expectTextileValidationError "countryDyeing" "Le code pays US n'est pas utilisable dans un contexte Textile."
                    |> asTest "validate that an ingredient country scope is valid"
                ]
            )
        , suiteFromResult "should validate that a trim item id is valid"
            tShirtCotonFrance
            (\query ->
                [ asTest "validate that a trim item id is valid" <|
                    -- Note: this component UUID doesn't exist
                    case Component.idFromString "ed3db03c-f56e-48a8-879c-df522c74d410" of
                        Ok nonExistentId ->
                            TextileQuery.encode
                                { query
                                    | trims =
                                        Just
                                            [ { country = Nothing
                                              , custom = Nothing
                                              , id = nonExistentId
                                              , quantity = Component.quantityFromInt 1
                                              }
                                            ]
                                }
                                |> testTextileEndpoint db
                                |> expectTextileValidationError "trims" "Aucun composant avec id=ed3db03c-f56e-48a8-879c-df522c74d410"

                        Err err ->
                            Expect.fail err
                ]
            )
        , suiteFromResult "should validate that a trim item quantity is a positive integer"
            tShirtCotonFrance
            (\query ->
                [ asTest "validate that a trim item quantity is a positive integer" <|
                    case Component.idFromString "0e8ea799-9b06-490c-a925-37564746c454" of
                        Ok id ->
                            TextileQuery.encode
                                { query
                                    | trims =
                                        Just
                                            [ { country = Nothing
                                              , custom = Nothing
                                              , id = id
                                              , quantity = Component.quantityFromInt -1
                                              }
                                            ]
                                }
                                |> testTextileEndpoint db
                                |> expectTextileValidationError "decoding" "La quantité doit être un nombre entier positif"

                        Err err ->
                            Expect.fail err
                ]
            )
        ]
    ]


testEndpoint :
    StaticDb.Db
    ->
        { method : String
        , protocol : String
        , host : String
        , url : String
        , version : Maybe String
        }
    -> Encode.Value
    -> Maybe Route.Route
testEndpoint dbs params =
    createServerRequest dbs params
        >> Route.endpoint dbs


testFoodEndpoint : StaticDb.Db -> Encode.Value -> Maybe Route.Route
testFoodEndpoint dbs =
    testEndpoint dbs
        { method = "POST"
        , protocol = "http"
        , host = "fqdn"
        , url = "/food"
        , version = Nothing
        }


testTextileEndpoint : StaticDb.Db -> Encode.Value -> Maybe Route.Route
testTextileEndpoint dbs =
    testEndpoint dbs
        { method = "POST"
        , protocol = "http"
        , host = "fqdn"
        , url = "/textile/simulator"
        , version = Nothing
        }


expectFoodValidationError : String -> String -> Maybe Route.Route -> Expect.Expectation
expectFoodValidationError key message route =
    case route of
        Just (Route.FoodPostRecipe (Err errors)) ->
            errors |> expectValidationError key message

        _ ->
            Expect.fail <| "No matching error found: " ++ Debug.toString route


expectTextileValidationError : String -> String -> Maybe Route.Route -> Expect.Expectation
expectTextileValidationError key message route =
    case route of
        Just (Route.TextilePostSimulator (Err errors)) ->
            errors |> expectValidationError key message

        _ ->
            Expect.fail <| "No matching error found: " ++ Debug.toString route


expectValidationError : String -> String -> Dict.Dict String String -> Expect.Expectation
expectValidationError key message errors =
    case Dict.get key errors of
        Just error ->
            if String.contains message error then
                Expect.pass

            else
                Expect.fail <| "String `" ++ message ++ "` not found in `" ++ error ++ "`"

        Nothing ->
            Expect.fail <| "Key `key` " ++ key ++ " is missing from errors dict: " ++ Debug.toString errors
