module Server.RouteTest exposing (..)

import Data.Food.Recipe as Recipe
import Data.Impact as Impact
import Data.Textile.Inputs as Inputs exposing (tShirtCotonFrance)
import Data.Textile.Material as Material
import Data.Textile.Step.Label as Label
import Data.Unit as Unit
import Dict exposing (Dict)
import Expect
import Json.Encode as Encode
import Server.Route as Route
import Static.Db as StaticDb
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


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
    [ describe "endpoints"
        [ getEndpoint db "GET" "/food/ingredients"
            |> Expect.equal (Just (Route.Get Route.FoodIngredientList))
            |> asTest "should handle the /food/ingredients endpoint"
        , getEndpoint db "GET" "/food/transforms"
            |> Expect.equal (Just (Route.Get Route.FoodTransformList))
            |> asTest "should handle the /food/transforms endpoint"
        , [ "/food/recipe?1"

          -- Here goes our "famous" tuna pizza…
          , "ingredients[]=2e3f03c6de1e43900e09ae852182e9c7;268"
          , "ingredients[]=83da330027d4b25dbc7817f06b738571;30"
          , "ingredients[]=568c715f977f32948813855d5efd95ba;149"
          , "ingredients[]=65e2a1f81e8525d74bc3d4d5bd559114;100"
          , "ingredients[]=a343353e431d7dddc7bb25cbc41e179a;168"
          , "ingredients[]=3af9739fc89492167dd0d273daac957a;425"
          , "transform=aded2490573207ec7ad5a3813978f6a4;1140"
          , "packaging[]=23b2754e5943bc77916f8f871edc53b6;105"
          ]
            |> String.join "&"
            |> getEndpoint db "GET"
            |> Expect.equal (Just <| Route.Get (Route.FoodRecipe (Ok Recipe.tunaPizza)))
            |> asTest "should handle the /food/recipe endpoint"
        ]
    , describe "validation"
        [ getEndpoint db "GET" "/food/recipe?"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "La liste des ingrédients est vide.")
            |> asTest "should validate an empty ingredients list"
        , getEndpoint db "GET" "/food/recipe?ingredients[]=2e3f03c6de1e43900e09ae852182e9c7|0"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Format d'ingrédient invalide : 2e3f03c6de1e43900e09ae852182e9c7|0.")
            |> asTest "should validate ingredient format"
        , getEndpoint db "GET" "/food/recipe?ingredients[]=invalid;100"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Procédé introuvable par code : invalid")
            |> asTest "should validate that an ingredient code is valid"
        , getEndpoint db "GET" "/food/recipe?ingredients[]=2e3f03c6de1e43900e09ae852182e9c7;-1"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "La masse doit être supérieure ou égale à zéro.")
            |> asTest "should validate that an ingredient mass is greater than zero"
        , getEndpoint db "GET" "/food/recipe?transform=aded2490573207ec7ad5a3813978f6a4;-1"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "transform")
            |> Expect.equal (Just "La masse doit être supérieure ou égale à zéro.")
            |> asTest "should validate that a transform mass is greater than zero"
        , getEndpoint db "GET" "/food/recipe?transform=invalid;100"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "transform")
            |> Expect.equal (Just "Procédé introuvable par code : invalid")
            |> asTest "should validate that a transform code is valid"
        , getEndpoint db "GET" "/food/recipe?packaging[]=23b2754e5943bc77916f8f871edc53b6;-1"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "packaging")
            |> Expect.equal (Just "La masse doit être supérieure ou égale à zéro.")
            |> asTest "should validate that a packaging mass is greater than zero"
        , getEndpoint db "GET" "/food/recipe?packaging[]=invalid;100"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "packaging")
            |> Expect.equal (Just "Procédé introuvable par code : invalid")
            |> asTest "should validate that a packaging code is valid"
        ]
    ]


textileEndpoints : StaticDb.Db -> List Test
textileEndpoints db =
    [ describe "endpoints"
        [ [ "/simulator?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;1"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          ]
            |> String.join "&"
            |> getEndpoint db "GET"
            |> Expect.equal
                (Just <|
                    Route.Get <|
                        Route.TextileSimulator <|
                            Ok tShirtCotonFrance
                )
            |> asTest "should handle the /simulator endpoint"
        , [ "/simulator?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;1"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          , "quality=1.2"
          ]
            |> String.join "&"
            |> getEndpoint db "GET"
            |> Expect.equal
                (Just <|
                    Route.Get <|
                        Route.TextileSimulator <|
                            Ok { tShirtCotonFrance | quality = Just (Unit.quality 1.2) }
                )
            |> asTest "should handle the /simulator endpoint with the quality parameter set"
        , [ "/simulator?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;1"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          , "disabledSteps=making,ennobling"
          ]
            |> String.join "&"
            |> getEndpoint db "GET"
            |> Expect.equal
                (Just <|
                    Route.Get <|
                        Route.TextileSimulator <|
                            Ok { tShirtCotonFrance | disabledSteps = [ Label.Making, Label.Ennobling ] }
                )
            |> asTest "should handle the /simulator endpoint with the disabledSteps parameter set"
        , [ "/simulator/fwe?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;1"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          ]
            |> String.join "&"
            |> getEndpoint db "GET"
            |> Expect.equal
                (Just <|
                    Route.Get <|
                        Route.TextileSimulatorSingle (Impact.trg "fwe") <|
                            Ok tShirtCotonFrance
                )
            |> asTest "should handle the /simulator/{impact} endpoint"
        , [ "/simulator/detailed?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;1"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          ]
            |> String.join "&"
            |> getEndpoint db "GET"
            |> Expect.equal
                (Just <|
                    Route.Get <|
                        Route.TextileSimulatorDetailed <|
                            Ok tShirtCotonFrance
                )
            |> asTest "should handle the /simulator/detailed endpoint"
        ]
    , describe "materials param checks"
        [ [ "/simulator?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;0.3"
          , "materials[]=coton-rdp;0.3"
          , "materials[]=acrylique;0.4"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          ]
            |> String.join "&"
            |> getEndpoint db "GET"
            |> Maybe.andThen extractQuery
            |> Maybe.map .materials
            |> Expect.equal
                (Just
                    [ { id = Material.Id "coton"
                      , share = Unit.Ratio 0.3
                      }
                    , { id = Material.Id "coton-rdp"
                      , share = Unit.Ratio 0.3
                      }
                    , { id = Material.Id "acrylique"
                      , share = Unit.Ratio 0.4
                      }
                    ]
                )
            |> asTest "should handle the /simulator endpoint with the list of materials"
        , getEndpoint db "GET" "/simulator?"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "La liste des matières est vide.")
            |> asTest "should validate an empty materials list"
        , getEndpoint db "GET" "/simulator?materials[]="
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Format de matière vide.")
            |> asTest "should validate empty material format"
        , getEndpoint db "GET" "/simulator?materials[]=notAnID"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Format de matière invalide : notAnID.")
            |> asTest "should validate invalid material format"
        , getEndpoint db "GET" "/simulator?materials[]=coton"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Format de matière invalide : coton.")
            |> asTest "should validate invalid material format even when valid material id"
        , getEndpoint db "GET" "/simulator?materials[]=coton;12"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Un ratio doit être compris entre 0 et 1 inclus (ici : 12).")
            |> asTest "should validate invalid material ratios"
        , getEndpoint db "GET" "/simulator?printing=plop"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "printing")
            |> Expect.equal (Just "Format de type et surface d'impression invalide: plop")
            |> asTest "should validate invalid printing method identifier"
        , getEndpoint db "GET" "/simulator?printing=substantive;1.2"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "printing")
            |> Expect.equal (Just "Le ratio de surface d'impression doit être supérieur à zéro et inférieur à 1.")
            |> asTest "should validate invalid printing ratio"
        ]
    , describe "multiple parameters checks"
        [ getEndpoint db "GET" "/simulator"
            |> Maybe.andThen extractTextileErrors
            |> Expect.equal
                (Dict.fromList
                    [ ( "countryFabric", "Code pays manquant." )
                    , ( "countryDyeing", "Code pays manquant." )
                    , ( "countryMaking", "Code pays manquant." )
                    , ( "mass", "La masse est manquante." )
                    , ( "materials", "La liste des matières est vide." )
                    , ( "product", "Identifiant du type de produit manquant." )
                    ]
                    |> Just
                )
            |> asTest "should expose query validation errors"
        , [ "/simulator?mass=-0.17"
          , "product=notAProductID"
          , "material=notAnID"
          , "materials[]=notAnID"
          , "surfaceMass=-2"
          , "countryFabric=notACountryCode"
          , "countryDyeing=notACountryCode"
          , "countryMaking=notACountryCode"
          , "disabledSteps=invalid"
          , "disabledFading=untrue"
          , "dyeingMedium=yolo"
          , "printing=yolo"
          ]
            |> String.join "&"
            |> getEndpoint db "GET"
            |> Maybe.andThen extractTextileErrors
            |> Expect.equal
                (Dict.fromList
                    [ ( "countryFabric", "Code pays invalide: notACountryCode." )
                    , ( "countryDyeing", "Code pays invalide: notACountryCode." )
                    , ( "countryMaking", "Code pays invalide: notACountryCode." )
                    , ( "mass", "La masse doit être supérieure ou égale à zéro." )
                    , ( "materials", "Format de matière invalide : notAnID." )
                    , ( "surfaceMass", "Le grammage (surfaceMass) doit être compris entre 30 et 500 gr/m²." )
                    , ( "product", "Produit non trouvé id=notAProductID." )
                    , ( "disabledSteps", "Impossible d'interpréter la liste des étapes désactivées; Code étape inconnu: invalid" )
                    , ( "disabledFading", "La valeur ne peut être que true ou false." )
                    , ( "dyeingMedium", "Type de support de teinture inconnu: yolo" )
                    , ( "printing", "Format de type et surface d'impression invalide: yolo" )
                    ]
                    |> Just
                )
            |> asTest "should expose detailed query validation errors"
        ]
    ]


getEndpoint : StaticDb.Db -> String -> String -> Maybe Route.Endpoint
getEndpoint dbs method url =
    Route.endpoint dbs
        { method = method
        , url = url
        , jsResponseHandler = Encode.null
        }


extractQuery : Route.Endpoint -> Maybe Inputs.Query
extractQuery route =
    case route of
        Route.Get (Route.TextileSimulator (Ok query)) ->
            Just query

        _ ->
            Nothing


extractFoodErrors : Route.Endpoint -> Maybe (Dict String String)
extractFoodErrors route =
    case route of
        Route.Get (Route.FoodRecipe (Err errors)) ->
            Just errors

        _ ->
            Nothing


extractTextileErrors : Route.Endpoint -> Maybe (Dict String String)
extractTextileErrors route =
    case route of
        Route.Get (Route.TextileSimulator (Err errors)) ->
            Just errors

        _ ->
            Nothing
