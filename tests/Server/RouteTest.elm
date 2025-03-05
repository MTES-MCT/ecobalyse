module Server.RouteTest exposing (..)

import Data.Component as Component
import Data.Country as Country
import Data.Example as Example
import Data.Food.Query as FoodQuery
import Data.Split as Split
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Data.Textile.Query as Query exposing (tShirtCotonFrance)
import Data.Unit as Unit
import Dict
import Expect
import Json.Encode as Encode
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
            [--     describe "POST endpoints"
             --     [ "/food"
             --         |> testEndpoint db "POST" (FoodQuery.encode royalPizza)
             --         |> Expect.equal (Just (Route.FoodPostRecipe (Ok royalPizza)))
             --         |> asTest "should map the POST /food endpoint"
             --     , "/food"
             --         |> testEndpoint db "POST" Encode.null
             --         |> expectFoodSingleErrorContains "ingredients"
             --         |> asTest "should fail on invalid query passed"
             --     ]
             -- , describe "validation"
             --     [ testEndpoint db "GET" Encode.null "/food?ingredients[]=9cbc31e9-80a4-4b87-ac4b-ddc051c47f69|0"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "ingredients")
             --         |> Expect.equal (Just "Format d'ingrédient invalide : 9cbc31e9-80a4-4b87-ac4b-ddc051c47f69|0.")
             --         |> asTest "should validate ingredient format"
             --     , testEndpoint db "GET" Encode.null "/food?ingredients[]=invalid;100"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "ingredients")
             --         |> Expect.equal (Just "Identifiant d’ingrédient invalide\u{202F}: invalid. Un `uuid` est attendu.")
             --         |> asTest "should validate that an ingredient id is valid"
             --     , testEndpoint db "GET" Encode.null "/food?ingredients[]=9cbc31e9-80a4-4b87-ac4b-ddc051c47f69;-1"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "ingredients")
             --         |> Expect.equal (Just "La masse doit être supérieure ou égale à zéro.")
             --         |> asTest "should validate that an ingredient mass is greater than zero"
             --     , testEndpoint db "GET" Encode.null "/food?ingredients[]=9cbc31e9-80a4-4b87-ac4b-ddc051c47f69;1;invalidCountry"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "ingredients")
             --         |> Expect.equal (Just "Code pays invalide: invalidCountry.")
             --         |> asTest "should validate that an ingredient country is valid"
             --     , testEndpoint db "GET" Encode.null "/food?ingredients[]=9cbc31e9-80a4-4b87-ac4b-ddc051c47f69;1;FR;byPlane"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "ingredients")
             --         |> Expect.equal (Just "Impossible de spécifier un acheminement par avion pour cet ingrédient, son origine par défaut ne le permet pas.")
             --         |> asTest "should validate that an ingredient can be transported by plane"
             --     , testEndpoint db "GET" Encode.null "/food?ingredients[]=9cbc31e9-80a4-4b87-ac4b-ddc051c47f69;1;BD"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "ingredients")
             --         |> Expect.equal (Just "Le code pays BD n'est pas utilisable dans un contexte Alimentaire.")
             --         |> asTest "should validate that an ingredient country scope is valid"
             --     , testEndpoint db "GET" Encode.null "/food?transform=7541cf94-1d4d-4d1c-99e3-a9d5be0e7569;-1"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "transform")
             --         |> Expect.equal (Just "La masse doit être supérieure ou égale à zéro.")
             --         |> asTest "should validate that a transform mass is greater than zero"
             --     , testEndpoint db "GET" Encode.null "/food?transform=invalid;100"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "transform")
             --         |> Expect.equal (Just "Identifiant invalide: invalid")
             --         |> asTest "should validate that a transform code is valid"
             --     , testEndpoint db "GET" Encode.null "/food?packaging[]=c352add7-8037-464e-bff2-7da517419f88;-1"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "packaging")
             --         |> Expect.equal (Just "La masse doit être supérieure ou égale à zéro.")
             --         |> asTest "should validate that a packaging mass is greater than zero"
             --     , testEndpoint db "GET" Encode.null "/food?packaging[]=invalid;100"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "packaging")
             --         |> Expect.equal (Just "Identifiant invalide: invalid")
             --         |> asTest "should validate that a packaging code is valid"
             --     , testEndpoint db "GET" Encode.null "/food?distribution=invalid"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "distribution")
             --         |> Expect.equal (Just "Choix invalide pour la distribution : invalid")
             --         |> asTest "should validate that a distribution is valid"
             --     , testEndpoint db "GET" Encode.null "/food?preparation[]=invalid"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "preparation")
             --         |> Expect.equal (Just "Préparation inconnue: invalid")
             --         |> asTest "should validate that a preparation list entry is valid"
             --     , testEndpoint db "GET" Encode.null "/food?preparation[]=freezing&preparation[]=frying&preparation[]=oven"
             --         |> Maybe.andThen extractFoodErrors
             --         |> Maybe.andThen (Dict.get "preparation")
             --         |> Expect.equal (Just "Deux techniques de préparation maximum.")
             --         |> asTest "should validate preparation list length"
             --     ]
            ]


textileEndpoints : StaticDb.Db -> List Test
textileEndpoints db =
    [ describe "POST endpoints"
        [ Query.encode tShirtCotonFrance
            |> testTextileEndpoint db
            |> Expect.equal (Just (Route.TextilePostSimulator (Ok tShirtCotonFrance)))
            |> asTest "should map the POST /textile/simulator endpoint with the body parsed as a valid query"
        , Encode.null
            |> testTextileEndpoint db
            |> expectTextileValidationError "decoding" "Problem with the given value: null Expecting an OBJECT with a field named `product`"
            |> asTest "should map the POST /textile/simulator endpoint with an error when json body is invalid"
        , Query.encode
            { tShirtCotonFrance
                | product = Product.idFromString "invalid"
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "product" "Produit non trouvé id=invalid."
            |> asTest "should reject invalid product"
        , Query.encode
            { tShirtCotonFrance
                | surfaceMass =
                    Just <| Unit.gramsPerSquareMeter 999
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "surfaceMass" "La masse surfacique doit être compris(e) entre 80 et 500."
            |> asTest "should reject invalid surfaceMass"
        , Query.encode
            { tShirtCotonFrance
                | physicalDurability =
                    Just <| Unit.physicalDurability 9900000
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "physicalDurability" "Le coefficient de durabilité physique doit être compris(e) entre 0.67 et 1.45."
            |> asTest "should reject invalid physicalDurability"
        , Query.encode
            { tShirtCotonFrance
                | countrySpinning = Just (Country.Code "invalid")
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "countrySpinning" "Code pays invalide: invalid."
            |> asTest "should reject invalid spinning country"
        , Query.encode
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
        [ Query.encode
            { tShirtCotonFrance
                | materials = []
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "materials" "La liste 'materials' ne peut pas être vide."
            |> asTest "should validate empty material list"
        , Query.encode
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
        , Query.encode
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
        , Query.encode
            { tShirtCotonFrance
                | countryDyeing = Just <| Country.Code "US"
            }
            |> testTextileEndpoint db
            |> expectTextileValidationError "countryDyeing" "Le code pays US n'est pas utilisable dans un contexte Textile."
            |> asTest "should validate that an ingredient country scope is valid"
        , asTest "should validate that a trim item id is valid" <|
            -- Note: this component UUID doesn't exist
            case Component.idFromString "ed3db03c-f56e-48a8-879c-df522c74d410" of
                Just nonExistentId ->
                    Query.encode
                        { tShirtCotonFrance
                            | trims = [ { id = nonExistentId, quantity = Component.quantityFromInt 1 } ]
                        }
                        |> testTextileEndpoint db
                        |> expectTextileValidationError "trims" "Aucun composant avec id=ed3db03c-f56e-48a8-879c-df522c74d410"

                Nothing ->
                    Expect.fail "Invalid component id"
        , asTest "should validate that a trim item quantity is a positive integer" <|
            case Component.idFromString "0e8ea799-9b06-490c-a925-37564746c454" of
                Just id ->
                    Query.encode
                        { tShirtCotonFrance
                            | trims = [ { id = id, quantity = Component.quantityFromInt -1 } ]
                        }
                        |> testTextileEndpoint db
                        |> expectTextileValidationError "trims" "La quantité doit être un nombre entier positif"

                Nothing ->
                    Expect.fail "Invalid component id"
        ]
    ]


testEndpoint : StaticDb.Db -> String -> Encode.Value -> String -> Maybe Route.Route
testEndpoint dbs method body =
    createServerRequest dbs method body
        >> Route.endpoint dbs


testTextileEndpoint : StaticDb.Db -> Encode.Value -> Maybe Route.Route
testTextileEndpoint dbs body =
    "/textile/simulator"
        |> testEndpoint dbs "POST" body


expectFoodValidationError : String -> String -> Maybe Route.Route -> Expect.Expectation
expectFoodValidationError key message route =
    case route of
        Just (Route.FoodPostRecipe (Err dict)) ->
            case Dict.get key dict of
                Just val ->
                    Expect.equal val message

                Nothing ->
                    Expect.fail <| "key " ++ key ++ " is missing from errors dict: " ++ Debug.toString dict

        _ ->
            Expect.fail <| "No matching error found: " ++ Debug.toString route


expectTextileValidationError : String -> String -> Maybe Route.Route -> Expect.Expectation
expectTextileValidationError key message route =
    case route of
        Just (Route.TextilePostSimulator (Err dict)) ->
            case Dict.get key dict of
                Just val ->
                    Expect.equal val message

                Nothing ->
                    Expect.fail <| "key " ++ key ++ " is missing from errors dict: " ++ Debug.toString dict

        _ ->
            Expect.fail <| "No matching error found: " ++ Debug.toString route
