module Server.RouteTest exposing (..)

import Data.Component as Component
import Data.Country as Country
import Data.Example as Example
import Data.Food.Preparation as Preparation
import Data.Food.Query as FoodQuery
import Data.Split as Split
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Data.Textile.Query as TextileQuery exposing (tShirtCotonFrance)
import Data.Unit as Unit
import Dict
import Expect
import Json.Encode as Encode
import Mass
import Server.Route as Route
import Static.Db as StaticDb
import Test exposing (..)
import TestUtils exposing (asTest, createServerRequest, suiteWithDb)


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
                |> asTest "should retrieve Royal Pizza example"
            ]

        Ok royalPizza ->
            [ describe "POST endpoints"
                [ FoodQuery.encode royalPizza
                    |> testFoodEndpoint db
                    |> Expect.equal (Just (Route.FoodPostRecipe (Ok royalPizza)))
                    |> asTest "should map the POST /food endpoint"
                , Encode.null
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "decoding" "Expecting an OBJECT with a field named `ingredients`"
                    |> asTest "should fail on invalid query passed"
                , FoodQuery.encode royalPizza
                    |> testFoodEndpoint db
                    |> Expect.equal (Just (Route.FoodPostRecipe (Ok royalPizza)))
                    |> asTest "should map the POST /food endpoint with the body parsed as a valid query"
                ]
            , describe "validation"
                [ FoodQuery.encode
                    { royalPizza
                        | ingredients =
                            royalPizza.ingredients |> List.map (\i -> { i | mass = Mass.grams -1 })
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "ingredients" "La masse doit être supérieure à zéro"
                    |> asTest "should validate an ingredient invalid mass"
                , FoodQuery.encode
                    { royalPizza
                        | ingredients =
                            royalPizza.ingredients |> List.map (\i -> { i | country = Just <| Country.Code "XX" })
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "ingredients" "Code pays invalide: XX."
                    |> asTest "should validate an ingredient invalid country code"
                , FoodQuery.encode
                    { royalPizza
                        | ingredients =
                            royalPizza.ingredients |> List.map (\i -> { i | country = Just <| Country.Code "BD" })
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "ingredients" "Le code pays BD n'est pas utilisable dans un contexte Alimentaire."
                    |> asTest "should validate an ingredient incompatible country code"
                , FoodQuery.encode
                    { royalPizza
                        | transform = royalPizza.transform |> Maybe.map (\t -> { t | mass = Mass.grams -1 })
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "transform" "La masse doit être supérieure à zéro"
                    |> asTest "should validate a transform mass"
                , FoodQuery.encode
                    { royalPizza
                        | packaging = royalPizza.packaging |> List.map (\p -> { p | mass = Mass.grams -1 })
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "packaging" "La masse doit être supérieure à zéro"
                    |> asTest "should validate a packaging mass"
                , FoodQuery.encode
                    { royalPizza
                        | preparation = Preparation.all |> List.map .id
                    }
                    |> testFoodEndpoint db
                    |> expectFoodValidationError "preparation" "La liste 'preparation' doit contenir 2 élément(s) maximum."
                    |> asTest "should validate a preparation list length"
                ]
            ]


textileEndpoints : StaticDb.Db -> List Test
textileEndpoints db =
    [ describe "POST endpoints"
        [ TextileQuery.encode tShirtCotonFrance
            |> testTextileEndpoint db
            |> Expect.equal (Just (Route.TextilePostSimulator (Ok tShirtCotonFrance)))
            |> asTest "should map the POST /textile/simulator endpoint with the body parsed as a valid query"
        , Encode.null
            |> testTextileEndpoint db
            |> expectTextileValidationError "decoding" "Expecting an OBJECT with a field named `product`"
            |> asTest "should map the POST /textile/simulator endpoint with an error when json body is invalid"
        , TextileQuery.encode
            { tShirtCotonFrance
                | product = Product.idFromString "invalid"
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "product" "Produit non trouvé id=invalid."
            |> asTest "should reject invalid product"
        , TextileQuery.encode
            { tShirtCotonFrance
                | surfaceMass =
                    Just <| Unit.gramsPerSquareMeter 999
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "surfaceMass" "La masse surfacique doit être compris(e) entre 80 et 500."
            |> asTest "should reject invalid surfaceMass"
        , TextileQuery.encode
            { tShirtCotonFrance
                | physicalDurability =
                    Just <| Unit.physicalDurability 9900000
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "physicalDurability" "Le coefficient de durabilité physique doit être compris(e) entre 0.67 et 1.45."
            |> asTest "should reject invalid physicalDurability"
        , TextileQuery.encode
            { tShirtCotonFrance
                | countrySpinning = Just (Country.Code "invalid")
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "countrySpinning" "Code pays invalide: invalid."
            |> asTest "should reject invalid spinning country"
        , TextileQuery.encode
            { tShirtCotonFrance
                | materials =
                    [ { country = Just (Country.Code "invalid")
                      , id = Material.Id "ei-coton"
                      , share = Split.full
                      , spinning = Nothing
                      }
                    ]
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "materials" "Code pays invalide: invalid."
            |> asTest "should reject invalid materials country"
        ]
    , describe "materials param checks"
        [ TextileQuery.encode
            { tShirtCotonFrance
                | materials = []
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "materials" "La liste 'materials' doit contenir 1 élément(s) minimum."
            |> asTest "should validate empty material list"
        , TextileQuery.encode
            { tShirtCotonFrance
                | materials =
                    [ { country = Nothing
                      , id = Material.Id "notAnID"
                      , share = Split.full
                      , spinning = Nothing
                      }
                    ]
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "materials" "Matière non trouvée id=notAnID."
            |> asTest "should validate invalid material format"
        , TextileQuery.encode
            { tShirtCotonFrance
                | materials =
                    [ { country = Just <| Country.Code "NotACountryCode"
                      , id = Material.Id "ei-coton"
                      , share = Split.full
                      , spinning = Nothing
                      }
                    ]
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "materials" "Code pays invalide: NotACountryCode."
            |> asTest "should validate a material country code"
        , TextileQuery.encode
            { tShirtCotonFrance
                | countryDyeing = Just <| Country.Code "US"
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "countryDyeing" "Le code pays US n'est pas utilisable dans un contexte Textile."
            |> asTest "should validate that an ingredient country scope is valid"
        , asTest "should validate that a trim item id is valid" <|
            -- Note: this component UUID doesn't exist
            case Component.idFromString "ed3db03c-f56e-48a8-879c-df522c74d410" of
                Ok nonExistentId ->
                    TextileQuery.encode
                        { tShirtCotonFrance
                            | trims = Just [ { custom = Nothing, id = nonExistentId, quantity = Component.quantityFromInt 1 } ]
                        }
                        |> testTextileEndpoint db
                        |> expectTextileValidationError "trims" "Aucun composant avec id=ed3db03c-f56e-48a8-879c-df522c74d410"

                Err err ->
                    Expect.fail err
        , asTest "should validate that a trim item quantity is a positive integer" <|
            case Component.idFromString "0e8ea799-9b06-490c-a925-37564746c454" of
                Ok id ->
                    TextileQuery.encode
                        { tShirtCotonFrance
                            | trims = Just [ { custom = Nothing, id = id, quantity = Component.quantityFromInt -1 } ]
                        }
                        |> testTextileEndpoint db
                        |> expectTextileValidationError "decoding" "La quantité doit être un nombre entier positif"

                Err err ->
                    Expect.fail err
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
