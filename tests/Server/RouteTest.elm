module Server.RouteTest exposing (..)

import Data.Food.Builder.Query as BuilderQuery
import Data.Impact.Definition as Definition
import Data.Split as Split
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
    [ describe "GET endpoints"
        [ testEndpoint db "GET" Encode.null "/food/ingredients"
            |> Expect.equal (Just Route.GetFoodIngredientList)
            |> asTest "should map the /food/ingredients endpoint"
        , testEndpoint db "GET" Encode.null "/food/transforms"
            |> Expect.equal (Just Route.GetFoodTransformList)
            |> asTest "should map the /food/transforms endpoint"
        , testEndpoint db "GET" Encode.null "/food/packagings"
            |> Expect.equal (Just Route.GetFoodPackagingList)
            |> asTest "should map the /food/packagings endpoint"
        , [ "/food/recipe?"

          -- Here goes our "famous" carrot cake…
          , "ingredients[]=egg;120"
          , "ingredients[]=wheat;140"
          , "ingredients[]=milk;60"
          , "ingredients[]=carrot;225"
          , "transform=AGRIBALU000000003103966;545"
          , "packaging[]=AGRIBALU000000003104019;105"
          , "distribution=ambient"
          , "preparation[]=refrigeration"
          , "category=cakes"
          ]
            |> String.join "&"
            |> testEndpoint db "GET" Encode.null
            |> Expect.equal (Just <| Route.GetFoodRecipe (Ok BuilderQuery.carrotCake))
            |> asTest "should map the /food/recipe endpoint"
        ]
    , describe "POST endpoints"
        [ "/food/recipe"
            |> testEndpoint db "POST" (BuilderQuery.encode BuilderQuery.carrotCake)
            |> Expect.equal (Just Route.PostFoodRecipe)
            |> asTest "should map the POST /food/recipe endpoint"
        , "/food/recipe"
            |> testEndpoint db "POST" Encode.null
            |> Expect.equal (Just Route.PostFoodRecipe)
            |> asTest "should map the POST /food/recipe endpoint whatever the request body is"
        ]
    , describe "validation"
        [ testEndpoint db "GET" Encode.null "/food/recipe?"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "La liste des ingrédients est vide.")
            |> asTest "should validate an empty ingredients list"
        , testEndpoint db "GET" Encode.null "/food/recipe?ingredients[]=egg|0"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Format d'ingrédient invalide : egg|0.")
            |> asTest "should validate ingredient format"
        , testEndpoint db "GET" Encode.null "/food/recipe?ingredients[]=invalid;100"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Ingrédient introuvable par id : invalid")
            |> asTest "should validate that an ingredient id is valid"
        , testEndpoint db "GET" Encode.null "/food/recipe?ingredients[]=egg;-1"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "La masse doit être supérieure ou égale à zéro.")
            |> asTest "should validate that an ingredient mass is greater than zero"
        , testEndpoint db "GET" Encode.null "/food/recipe?ingredients[]=egg;1;invalidCountry"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Code pays invalide: invalidCountry.")
            |> asTest "should validate that an ingredient country is valid"
        , testEndpoint db "GET" Encode.null "/food/recipe?ingredients[]=egg;1;FR;byPlane"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Impossible de spécifier un acheminement par avion pour cet ingrédient, son origine par défaut ne le permet pas.")
            |> asTest "should validate that an ingredient can be transported by plane"
        , testEndpoint db "GET" Encode.null "/food/recipe?ingredients[]=egg;1;BD"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Le code pays BD n'est pas utilisable dans un contexte Alimentaire.")
            |> asTest "should validate that an ingredient country scope is valid"
        , testEndpoint db "GET" Encode.null "/food/recipe?ingredients[]=carrot;1;ES;;10:10:10"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "L'ingrédient Carotte ne permet pas l'application d'un bonus sur les conditions d'élevage.")
            |> asTest "should validate that an ingredient bonuses are valid"
        , testEndpoint db "GET" Encode.null "/food/recipe?ingredients[]=carrot;1;ES;;100:110"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "ingredients")
            |> Expect.equal (Just "Une part (en pourcentage) doit être comprise entre 0 et 100 inclus (ici: 110)")
            |> asTest "should validate that an ingredient bonuses splits are valid"
        , testEndpoint db "GET" Encode.null "/food/recipe?transform=AGRIBALU000000003103966;-1"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "transform")
            |> Expect.equal (Just "La masse doit être supérieure ou égale à zéro.")
            |> asTest "should validate that a transform mass is greater than zero"
        , testEndpoint db "GET" Encode.null "/food/recipe?transform=invalid;100"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "transform")
            |> Expect.equal (Just "Procédé introuvable par code : invalid")
            |> asTest "should validate that a transform code is valid"
        , testEndpoint db "GET" Encode.null "/food/recipe?packaging[]=AGRIBALU000000003104019;-1"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "packaging")
            |> Expect.equal (Just "La masse doit être supérieure ou égale à zéro.")
            |> asTest "should validate that a packaging mass is greater than zero"
        , testEndpoint db "GET" Encode.null "/food/recipe?packaging[]=invalid;100"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "packaging")
            |> Expect.equal (Just "Procédé introuvable par code : invalid")
            |> asTest "should validate that a packaging code is valid"
        , testEndpoint db "GET" Encode.null "/food/recipe?distribution=invalid"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "distribution")
            |> Expect.equal (Just "Choix invalide pour la distribution : invalid")
            |> asTest "should validate that a distribution is valid"
        , testEndpoint db "GET" Encode.null "/food/recipe?preparation[]=invalid"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "preparation")
            |> Expect.equal (Just "Préparation inconnue: invalid")
            |> asTest "should validate that a preparation list entry is valid"
        , testEndpoint db "GET" Encode.null "/food/recipe?preparation[]=freezing&preparation[]=frying&preparation[]=oven"
            |> Maybe.andThen extractFoodErrors
            |> Maybe.andThen (Dict.get "preparation")
            |> Expect.equal (Just "Deux techniques de préparation maximum.")
            |> asTest "should validate preparation list length"
        ]
    ]


textileEndpoints : StaticDb.Db -> List Test
textileEndpoints db =
    [ describe "GET endpoints"
        [ String.join "&"
            [ "/textile/simulator?mass=0.17"
            , "product=tshirt"
            , "materials[]=coton;1"
            , "countryFabric=FR"
            , "countryDyeing=FR"
            , "countryMaking=FR"
            ]
            |> testEndpoint db "GET" Encode.null
            |> Expect.equal (Just <| Route.GetTextileSimulator (Ok tShirtCotonFrance))
            |> asTest "should map the /textile/simulator endpoint"
        , [ "/textile/simulator?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;1"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          , "quality=1.2"
          ]
            |> String.join "&"
            |> testEndpoint db "GET" Encode.null
            |> Expect.equal
                (Just <|
                    Route.GetTextileSimulator <|
                        Ok { tShirtCotonFrance | quality = Just (Unit.quality 1.2) }
                )
            |> asTest "should map the /textile/simulator endpoint with the quality parameter set"
        , [ "/textile/simulator?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;1"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          , "disabledSteps=making,ennobling"
          ]
            |> String.join "&"
            |> testEndpoint db "GET" Encode.null
            |> Expect.equal
                (Just <|
                    Route.GetTextileSimulator <|
                        Ok { tShirtCotonFrance | disabledSteps = [ Label.Making, Label.Ennobling ] }
                )
            |> asTest "should map the /textile/simulator endpoint with the disabledSteps parameter set"
        , [ "/textile/simulator/fwe?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;1"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          ]
            |> String.join "&"
            |> testEndpoint db "GET" Encode.null
            |> Expect.equal
                (Just <|
                    Route.GetTextileSimulatorSingle Definition.Fwe <|
                        Ok tShirtCotonFrance
                )
            |> asTest "should map the /textile/simulator/{impact} endpoint"
        , [ "/textile/simulator/detailed?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;1"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          ]
            |> String.join "&"
            |> testEndpoint db "GET" Encode.null
            |> Expect.equal
                (Just <|
                    Route.GetTextileSimulatorDetailed <|
                        Ok tShirtCotonFrance
                )
            |> asTest "should map the /textile/simulator/detailed endpoint"
        ]
    , describe "POST endpoints"
        [ "/textile/simulator"
            |> testEndpoint db "POST" (Inputs.encodeQuery Inputs.tShirtCotonFrance)
            |> Expect.equal (Just Route.PostTextileSimulator)
            |> asTest "should map the POST /textile/simulator endpoint"
        , "/textile/simulator"
            |> testEndpoint db "POST" Encode.null
            |> Expect.equal (Just Route.PostTextileSimulator)
            |> asTest "should map the POST /textile/simulator endpoint whatever the request body is"
        ]
    , describe "materials param checks"
        [ let
            results =
                Result.map2
                    (\thirty fourty ->
                        [ { id = Material.Id "coton"
                          , share = thirty
                          }
                        , { id = Material.Id "coton-rdp"
                          , share = thirty
                          }
                        , { id = Material.Id "acrylique"
                          , share = fourty
                          }
                        ]
                    )
                    (Split.fromFloat 0.3)
                    (Split.fromFloat 0.4)
                    |> Result.toMaybe
          in
          [ "/textile/simulator?mass=0.17"
          , "product=tshirt"
          , "materials[]=coton;0.3"
          , "materials[]=coton-rdp;0.3"
          , "materials[]=acrylique;0.4"
          , "countryFabric=FR"
          , "countryDyeing=FR"
          , "countryMaking=FR"
          ]
            |> String.join "&"
            |> testEndpoint db "GET" Encode.null
            |> Maybe.andThen extractQuery
            |> Maybe.map .materials
            |> Expect.equal results
            |> asTest "should map the /textile/simulator endpoint with the list of materials"
        , testEndpoint db "GET" Encode.null "/textile/simulator?"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "La liste des matières est vide.")
            |> asTest "should validate an empty materials list"
        , testEndpoint db "GET" Encode.null "/textile/simulator?materials[]="
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Format de matière vide.")
            |> asTest "should validate empty material format"
        , testEndpoint db "GET" Encode.null "/textile/simulator?materials[]=notAnID"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Format de matière invalide : notAnID.")
            |> asTest "should validate invalid material format"
        , testEndpoint db "GET" Encode.null "/textile/simulator?materials[]=coton"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Format de matière invalide : coton.")
            |> asTest "should validate invalid material format even when valid material id"
        , testEndpoint db "GET" Encode.null "/textile/simulator?materials[]=coton;12"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "materials")
            |> Expect.equal (Just "Une part (en nombre flottant) doit être comprise entre 0 et 1 inclus (ici: 12)")
            |> asTest "should validate invalid material ratios"
        , testEndpoint db "GET" Encode.null "/textile/simulator?ennoblingHeatSource=bonk"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "ennoblingHeatSource")
            |> Expect.equal (Just "Source de production de vapeur inconnue: bonk")
            |> asTest "should validate invalid ennoblingHeatSource identifier"
        , testEndpoint db "GET" Encode.null "/textile/simulator?printing=plop"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "printing")
            |> Expect.equal (Just "Format de type et surface d'impression invalide: plop")
            |> asTest "should validate invalid printing method identifier"
        , testEndpoint db "GET" Encode.null "/textile/simulator?printing=substantive;1.2"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "printing")
            |> Expect.equal (Just "Le ratio de surface d'impression doit être supérieur à zéro et inférieur à 1.")
            |> asTest "should validate invalid printing ratio"
        , testEndpoint db "GET" Encode.null "/textile/simulator?countryDyeing=US"
            |> Maybe.andThen extractTextileErrors
            |> Maybe.andThen (Dict.get "countryDyeing")
            |> Expect.equal (Just "Le code pays US n'est pas utilisable dans un contexte Textile.")
            |> asTest "should validate that an ingredient country scope is valid"
        ]
    , describe "multiple parameters checks"
        [ testEndpoint db "GET" Encode.null "/textile/simulator"
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
          , "knittingProcess=notAKnittingProcess"
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
            |> testEndpoint db "GET" Encode.null
            |> Maybe.andThen extractTextileErrors
            |> Expect.equal
                (Dict.fromList
                    [ ( "countryFabric", "Code pays invalide: notACountryCode." )
                    , ( "countryDyeing", "Code pays invalide: notACountryCode." )
                    , ( "countryMaking", "Le code pays US n'est pas utilisable dans un contexte Textile." )
                    , ( "mass", "La masse doit être supérieure ou égale à zéro." )
                    , ( "materials", "Format de matière invalide : notAnID." )
                    , ( "knittingProcess", "Procédé de tricotage inconnu: notAKnittingProcess" )
                    , ( "surfaceMass", "Le grammage (surfaceMass) doit être compris entre 80 et 500 g/m²." )
                    , ( "product", "Produit non trouvé id=notAProductID." )
                    , ( "disabledSteps", "Impossible d'interpréter la liste des étapes désactivées; Code étape inconnu: invalid" )
                    , ( "disabledFading", "La valeur ne peut être que true ou false." )
                    , ( "dyeingMedium", "Type de support de teinture inconnu: yolo" )
                    , ( "printing", "Format de type et surface d'impression invalide: yolo" )
                    , ( "ennoblingHeatSource", "Source de production de vapeur inconnue: yolo" )
                    , ( "yarnSize", "Le titrage (yarnSize) doit être compris entre 9 et 200 Nm (entre 50 et 1111 Dtex)" )
                    ]
                    |> Just
                )
            |> asTest "should expose detailed query validation errors"
        ]
    ]


testEndpoint : StaticDb.Db -> String -> Encode.Value -> String -> Maybe Route.Route
testEndpoint dbs method body url =
    Route.endpoint dbs
        { method = method
        , url = url
        , body = body
        , jsResponseHandler = Encode.null
        }


extractQuery : Route.Route -> Maybe Inputs.Query
extractQuery route =
    case route of
        Route.GetTextileSimulator (Ok query) ->
            Just query

        _ ->
            Nothing


extractFoodErrors : Route.Route -> Maybe (Dict String String)
extractFoodErrors route =
    case route of
        Route.GetFoodRecipe (Err errors) ->
            Just errors

        _ ->
            Nothing


extractTextileErrors : Route.Route -> Maybe (Dict String String)
extractTextileErrors route =
    case route of
        Route.GetTextileSimulator (Err errors) ->
            Just errors

        _ ->
            Nothing
