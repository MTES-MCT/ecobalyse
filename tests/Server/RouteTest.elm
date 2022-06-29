module Server.RouteTest exposing (..)

import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs exposing (tShirtCotonFrance)
import Data.Material as Material
import Data.Unit as Unit
import Dict exposing (Dict)
import Expect
import Json.Encode as Encode
import Server.Route as Route
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


suite : Test
suite =
    suiteWithDb "Server"
        (\db ->
            [ describe "Server.endpoint"
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
                                    Route.Simulator <|
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
                                    Route.Simulator <|
                                        Ok { tShirtCotonFrance | quality = Just (Unit.quality 1.2) }
                            )
                        |> asTest "should handle the /simulator endpoint with the quality parameter set"
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
                                    Route.SimulatorSingle (Impact.trg "fwe") <|
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
                                    Route.SimulatorDetailed <|
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
                        |> Maybe.andThen extractErrors
                        |> Maybe.andThen (Dict.get "materials")
                        |> Expect.equal (Just "La liste des matières est vide.")
                        |> asTest "should validate an empty materials list"
                    , getEndpoint db "GET" "/simulator?materials[]="
                        |> Maybe.andThen extractErrors
                        |> Maybe.andThen (Dict.get "materials")
                        |> Expect.equal (Just "Format de matière vide.")
                        |> asTest "should validate empty material format"
                    , getEndpoint db "GET" "/simulator?materials[]=notAnID"
                        |> Maybe.andThen extractErrors
                        |> Maybe.andThen (Dict.get "materials")
                        |> Expect.equal (Just "Format de matière invalide : notAnID.")
                        |> asTest "should validate invalid material format"
                    , getEndpoint db "GET" "/simulator?materials[]=coton"
                        |> Maybe.andThen extractErrors
                        |> Maybe.andThen (Dict.get "materials")
                        |> Expect.equal (Just "Format de matière invalide : coton.")
                        |> asTest "should validate invalid material format even when valid material id"
                    , getEndpoint db "GET" "/simulator?materials[]=coton;12"
                        |> Maybe.andThen extractErrors
                        |> Maybe.andThen (Dict.get "materials")
                        |> Expect.equal (Just "Un ratio doit être compris entre 0 et 1 inclus (ici : 12).")
                        |> asTest "should validate invalid material ratios"
                    ]
                , describe "multiple parameters checks"
                    [ getEndpoint db "GET" "/simulator"
                        |> Maybe.andThen extractErrors
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
                      , "countryFabric=notACountryCode"
                      , "countryDyeing=notACountryCode"
                      , "countryMaking=notACountryCode"
                      ]
                        |> String.join "&"
                        |> getEndpoint db "GET"
                        |> Maybe.andThen extractErrors
                        |> Expect.equal
                            (Dict.fromList
                                [ ( "countryFabric", "Code pays invalide: notACountryCode." )
                                , ( "countryDyeing", "Code pays invalide: notACountryCode." )
                                , ( "countryMaking", "Code pays invalide: notACountryCode." )
                                , ( "mass", "La masse doit être supérieure ou égale à zéro." )
                                , ( "materials", "Format de matière invalide : notAnID." )
                                , ( "product", "Produit non trouvé id=notAProductID." )
                                ]
                                |> Just
                            )
                        |> asTest "should expose detailed query validation errors"
                    ]
                ]
            ]
        )


getEndpoint : Db -> String -> String -> Maybe Route.Endpoint
getEndpoint db method url =
    Route.endpoint db
        { method = method
        , url = url
        , jsResponseHandler = Encode.null
        }


extractQuery : Route.Endpoint -> Maybe Inputs.Query
extractQuery route =
    case route of
        Route.Get (Route.Simulator (Ok query)) ->
            Just query

        _ ->
            Nothing


extractErrors : Route.Endpoint -> Maybe (Dict String String)
extractErrors route =
    case route of
        Route.Get (Route.Simulator (Err errors)) ->
            Just errors

        _ ->
            Nothing
