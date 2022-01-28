module Server.RouteTest exposing (..)

import Data.Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs
import Dict
import Expect
import Json.Encode as Encode
import Server.Route as Route
import Test exposing (..)
import TestUtils exposing (asTest, suiteWithDb)


getEndpoint : Db -> String -> String -> Maybe Route.Endpoint
getEndpoint db method url =
    Route.endpoint db
        { method = method
        , url = url
        , jsResponseHandler = Encode.null
        }


suite : Test
suite =
    suiteWithDb "Server"
        (\db ->
            [ describe "Server.endpoint"
                [ getEndpoint db "GET" "/simulator?mass=0.17&product=13&material=f211bbdb-415c-46fd-be4d-ddf199575b44&countryFabric=FR&countryDyeing=FR&countryMaking=FR"
                    |> Expect.equal (Just <| Route.Get <| Route.Simulator <| Ok Inputs.tShirtCotonFrance)
                    |> asTest "should handle the /simulator endpoint"
                , getEndpoint db "GET" "/simulator/fwe?mass=0.17&product=13&material=f211bbdb-415c-46fd-be4d-ddf199575b44&countryFabric=FR&countryDyeing=FR&countryMaking=FR"
                    |> Expect.equal (Just <| Route.Get <| Route.SimulatorSingle (Impact.trg "fwe") <| Ok Inputs.tShirtCotonFrance)
                    |> asTest "should handle the /simulator/{impact} endpoint"
                , getEndpoint db "GET" "/simulator/detailed?mass=0.17&product=13&material=f211bbdb-415c-46fd-be4d-ddf199575b44&countryFabric=FR&countryDyeing=FR&countryMaking=FR"
                    |> Expect.equal (Just <| Route.Get <| Route.SimulatorDetailed <| Ok Inputs.tShirtCotonFrance)
                    |> asTest "should handle the /simulator/detailed endpoint"
                , getEndpoint db "GET" "/simulator"
                    |> Expect.equal
                        ([ ( "countryFabric", "Code pays manquant." )
                         , ( "countryDyeing", "Code pays manquant." )
                         , ( "countryMaking", "Code pays manquant." )
                         , ( "mass", "La masse est manquante." )
                         , ( "material", "Identifiant de la matière manquant." )
                         , ( "product", "Identifiant du type de produit manquant." )
                         ]
                            |> Dict.fromList
                            |> Err
                            |> Route.Simulator
                            |> Route.Get
                            |> Just
                        )
                    |> asTest "should expose query validation errors"
                , getEndpoint db "GET" "/simulator?mass=-0.17&product=notAProductID&material=notAnUUID&countryFabric=notACountryCode&countryDyeing=notACountryCode&countryMaking=notACountryCode"
                    |> Expect.equal
                        ([ ( "countryFabric", "Code pays invalide: notACountryCode." )
                         , ( "countryDyeing", "Code pays invalide: notACountryCode." )
                         , ( "countryMaking", "Code pays invalide: notACountryCode." )
                         , ( "mass", "La masse doit être supérieure ou égale à zéro." )
                         , ( "material", "Impossible de récupérer la matière uuid=notAnUUID." )
                         , ( "product", "Produit non trouvé id=notAProductID." )
                         ]
                            |> Dict.fromList
                            |> Err
                            |> Route.Simulator
                            |> Route.Get
                            |> Just
                        )
                    |> asTest "should expose detailed query validation errors"
                ]
            ]
        )
