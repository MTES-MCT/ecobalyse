module Server.RouteTest exposing (..)

import Data.Food.Builder.Query as BuilderQuery
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
        , getEndpoint db "GET" "/food/packagings"
            |> Expect.equal (Just (Route.Get Route.FoodPackagingList))
            |> asTest "should handle the /food/packagings endpoint"
        , [ "/food/recipe?"

          -- Here goes our "famous" carrot cake…
          , "ingredients[]=egg;120"
          , "ingredients[]=wheat;140"
          , "ingredients[]=milk;60"
          , "ingredients[]=carrot;225"
          , "transform=aded2490573207ec7ad5a3813978f6a4;545"
          , "packaging[]=23b2754e5943bc77916f8f871edc53b6;105"
          , "distribution=ambient"
          , "preparation[]=refrigeration"
          , "category=cakes"
          ]
            |> String.join "&"
            |> getEndpoint db "GET"
            |> Expect.equal (Just <| Route.Get (Route.FoodRecipe (Ok BuilderQuery.carrotCake)))
            |> asTest "should handle the /food/recipe endpoint"
        ]
    , describe "validation"
        [ getEndpoint db "GET" "/food/recipe?"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "La liste des ingrédients est vide.")
            |> asTest "should validate an empty ingredients list"
        , getEndpoint db "GET" "/food/recipe?ingredients[]=egg|0"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Format d'ingrédient invalide : egg|0.")
            |> asTest "should validate ingredient format"
        , getEndpoint db "GET" "/food/recipe?ingredients[]=invalid;100"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Ingrédient introuvable par id : invalid")
            |> asTest "should validate that an ingredient id is valid"
        , getEndpoint db "GET" "/food/recipe?ingredients[]=egg;-1"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "La masse doit être supérieure ou égale à zéro.")
            |> asTest "should validate that an ingredient mass is greater than zero"
        , getEndpoint db "GET" "/food/recipe?ingredients[]=egg;1;invalidVariant"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Format de variant invalide : invalidVariant")
            |> asTest "should validate that an ingredient variant is valid"
        , getEndpoint db "GET" "/food/recipe?ingredients[]=egg;1;;invalidCountry"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Code pays invalide: invalidCountry.")
            |> asTest "should validate that an ingredient country is valid"
        , getEndpoint db "GET" "/food/recipe?ingredients[]=egg;1;;FR;byPlane"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Impossible de spécifier un acheminement par avion pour cet ingrédient, son origine par défaut ne le permet pas.")
            |> asTest "should validate that an ingredient can be transported by plane"
        , getEndpoint db "GET" "/food/recipe?ingredients[]=egg;1;;BD"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Le code pays BD n'est pas utilisable dans un contexte Alimentaire.")
            |> asTest "should validate that an ingredient country scope is valid"
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
        , getEndpoint db "GET" "/food/recipe?category=invalid"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "category")
            |> Expect.equal (Just "Catégorie inconnue: invalid")
            |> asTest "should validate that a category id is valid"
        , getEndpoint db "GET" "/food/recipe?distribution=invalid"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "distribution")
            |> Expect.equal (Just "Choix invalide pour la distribution : invalid")
            |> asTest "should validate that a distribution is valid"
        , getEndpoint db "GET" "/food/recipe?preparation[]=invalid"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "preparation")
            |> Expect.equal (Just "Préparation inconnue: invalid")
            |> asTest "should validate that a preparation list entry is valid"
        , getEndpoint db "GET" "/food/recipe?preparation[]=freezing&preparation[]=frying&preparation[]=oven"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "preparation")
            |> Expect.equal (Just "Deux techniques de préparation maximum.")
            |> asTest "should validate preparation list length"
        ]
    ]


textileEndpoints : StaticDb.Db -> List Test
textileEndpoints db =
    [ describe "endpoints"
        [ [ "/textile/simulator?mass=0.17"
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
            |> asTest "should handle the /textile/simulator endpoint"
        , [ "/textile/simulator?mass=0.17"
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
            |> asTest "should handle the /textile/simulator endpoint with the quality parameter set"
        , [ "/textile/simulator?mass=0.17"
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
            |> asTest "should handle the /textile/simulator endpoint with the disabledSteps parameter set"
        , [ "/textile/simulator/fwe?mass=0.17"
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
            |> asTest "should handle the /textile/simulator/{impact} endpoint"
        , [ "/textile/simulator/detailed?mass=0.17"
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
            |> asTest "should handle the /textile/simulator/detailed endpoint"
        ]
    , describe "materials param checks"
        [ [ "/textile/simulator?mass=0.17"
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
            |> asTest "should handle the /textile/simulator endpoint with the list of materials"
        , getEndpoint db "GET" "/textile/simulator?"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "La liste des matières est vide.")
            |> asTest "should validate an empty materials list"
        , getEndpoint db "GET" "/textile/simulator?materials[]="
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Format de matière vide.")
            |> asTest "should validate empty material format"
        , getEndpoint db "GET" "/textile/simulator?materials[]=notAnID"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Format de matière invalide : notAnID.")
            |> asTest "should validate invalid material format"
        , getEndpoint db "GET" "/textile/simulator?materials[]=coton"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Format de matière invalide : coton.")
            |> asTest "should validate invalid material format even when valid material id"
        , getEndpoint db "GET" "/textile/simulator?materials[]=coton;12"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Un ratio doit être compris entre 0 et 1 inclus (ici : 12).")
            |> asTest "should validate invalid material ratios"
        , getEndpoint db "GET" "/textile/simulator?ennoblingHeatSource=bonk"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "ennoblingHeatSource")
            |> Expect.equal (Just "Source de production de vapeur inconnue: bonk")
            |> asTest "should validate invalid ennoblingHeatSource identifier"
        , getEndpoint db "GET" "/textile/simulator?printing=plop"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "printing")
            |> Expect.equal (Just "Format de type et surface d'impression invalide: plop")
            |> asTest "should validate invalid printing method identifier"
        , getEndpoint db "GET" "/textile/simulator?printing=substantive;1.2"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "printing")
            |> Expect.equal (Just "Le ratio de surface d'impression doit être supérieur à zéro et inférieur à 1.")
            |> asTest "should validate invalid printing ratio"
        , getEndpoint db "GET" "/textile/simulator?countryDyeing=US"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "countryDyeing")
            |> Expect.equal (Just "Le code pays US n'est pas utilisable dans un contexte Textile.")
            |> asTest "should validate that an ingredient country scope is valid"
        ]
    , describe "multiple parameters checks"
        [ getEndpoint db "GET" "/textile/simulator"
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
        , [ "/textile/simulator?mass=-0.17"
          , "product=notAProductID"
          , "material=notAnID"
          , "materials[]=notAnID"
          , "surfaceMass=-2"
          , "countryFabric=notACountryCode"
          , "countryDyeing=notACountryCode"
          , "countryMaking=US"
          , "disabledSteps=invalid"
          , "disabledFading=untrue"
          , "dyeingMedium=yolo"
          , "printing=yolo"
          , "ennoblingHeatSource=yolo"
          , "yarnSize=0"
          ]
            |> String.join "&"
            |> getEndpoint db "GET"
            |> Maybe.andThen extractTextileErrors
            |> Expect.equal
                (Dict.fromList
                    [ ( "countryFabric", "Code pays invalide: notACountryCode." )
                    , ( "countryDyeing", "Code pays invalide: notACountryCode." )
                    , ( "countryMaking", "Le code pays US n'est pas utilisable dans un contexte Textile." )
                    , ( "mass", "La masse doit être supérieure ou égale à zéro." )
                    , ( "materials", "Format de matière invalide : notAnID." )
                    , ( "surfaceMass", "Le grammage (surfaceMass) doit être compris entre 80 et 500 g/m²." )
                    , ( "product", "Produit non trouvé id=notAProductID." )
                    , ( "disabledSteps", "Impossible d'interpréter la liste des étapes désactivées; Code étape inconnu: invalid" )
                    , ( "disabledFading", "La valeur ne peut être que true ou false." )
                    , ( "dyeingMedium", "Type de support de teinture inconnu: yolo" )
                    , ( "printing", "Format de type et surface d'impression invalide: yolo" )
                    , ( "ennoblingHeatSource", "Source de production de vapeur inconnue: yolo" )
                    , ( "yarnSize", "Le titrage (yarnSize) doit être compris entre 9 et 200 duites/m." )
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
