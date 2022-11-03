port module Server exposing
    ( input
    , main
    , output
    )

import Data.Country as Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Food.Process as FoodProcess
import Data.Food.Recipe as Recipe
import Data.Impact as Impact
import Data.Textile.Db as TextileDb
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as TextileProduct exposing (Product)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Json.Encode as Encode
import Server.Query as Query
import Server.Request exposing (Request)
import Server.Route as Route
import Static.Db as StaticDb


type Msg
    = Received Request


apiDocUrl : String
apiDocUrl =
    "https://ecobalyse.beta.gouv.fr/#/api"


sendResponse : Int -> Request -> Encode.Value -> Cmd Msg
sendResponse httpStatus { method, url, jsResponseHandler } body =
    Encode.object
        [ ( "status", Encode.int httpStatus )
        , ( "method", Encode.string method )
        , ( "url", Encode.string url )
        , ( "body", body )
        , ( "jsResponseHandler", jsResponseHandler )
        ]
        |> output


encodeStringError : String -> Encode.Value
encodeStringError error =
    Encode.object
        [ ( "error", error |> String.lines |> Encode.list Encode.string )
        , ( "documentation", Encode.string apiDocUrl )
        ]


toResponse : Request -> Result String Encode.Value -> Cmd Msg
toResponse request encodedResult =
    case encodedResult of
        Ok encoded ->
            encoded
                |> sendResponse 200 request

        Err error ->
            encodeStringError error
                |> sendResponse 400 request


toAllImpactsSimple : Simulator -> Encode.Value
toAllImpactsSimple { inputs, impacts } =
    Encode.object
        [ ( "impacts", Impact.encodeImpacts impacts )
        , ( "description", inputs |> Inputs.toString |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> Inputs.encodeQuery )
        ]


toSingleImpactSimple : Impact.Trigram -> Simulator -> Encode.Value
toSingleImpactSimple trigram { inputs, impacts } =
    Encode.object
        [ ( "impacts"
          , impacts
                |> Impact.filterImpacts (\trg _ -> trigram == trg)
                |> Impact.encodeImpacts
          )
        , ( "description", inputs |> Inputs.toString |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> Inputs.encodeQuery )
        ]


toFoodResults : Recipe.Query -> Recipe.Results -> Encode.Value
toFoodResults query results =
    Encode.object
        [ ( "results", Recipe.encodeResults results )
        , ( "description", Encode.string "TODO" )
        , ( "query", Recipe.encode query )
        ]


executeFoodQuery : FoodDb.Db -> Request -> (Recipe.Results -> Encode.Value) -> Recipe.Query -> Cmd Msg
executeFoodQuery foodDb request encoder =
    Recipe.compute foodDb
        >> Result.map encoder
        >> toResponse request


executeTextileQuery : TextileDb.Db -> Request -> (Simulator -> Encode.Value) -> Inputs.Query -> Cmd Msg
executeTextileQuery textileDb request encoder =
    Simulator.compute textileDb
        >> Result.map encoder
        >> toResponse request


encodeCountry : Country -> Encode.Value
encodeCountry { code, name } =
    Encode.object
        [ ( "code", Country.encodeCode code )
        , ( "name", Encode.string name )
        ]


encodeMaterial : Material -> Encode.Value
encodeMaterial { id, name } =
    Encode.object
        [ ( "id", Material.encodeId id )
        , ( "name", Encode.string name )
        ]


encodeProduct : Product -> Encode.Value
encodeProduct { id, name } =
    Encode.object
        [ ( "id", TextileProduct.encodeId id )
        , ( "name", Encode.string name )
        ]


encodeFoodProcess : FoodProcess.Process -> Encode.Value
encodeFoodProcess process =
    Encode.object
        [ ( "code", process.code |> FoodProcess.codeToString |> Encode.string )
        , ( "name", process |> FoodProcess.getDisplayName |> Encode.string )
        ]


encodeFoodProcessList : List FoodProcess.Process -> Encode.Value
encodeFoodProcessList =
    Encode.list encodeFoodProcess


handleRequest : StaticDb.Db -> Request -> Cmd Msg
handleRequest ({ foodDb, textileDb } as dbs) request =
    case Route.endpoint dbs request of
        Just (Route.Get Route.CountryList) ->
            textileDb.countries
                |> Encode.list encodeCountry
                |> sendResponse 200 request

        Just (Route.Get Route.FoodIngredientList) ->
            foodDb.processes
                |> List.filter (.category >> (==) FoodProcess.Ingredient)
                |> encodeFoodProcessList
                |> sendResponse 200 request

        Just (Route.Get Route.FoodPackagingList) ->
            foodDb.processes
                |> List.filter (.category >> (==) FoodProcess.Packaging)
                |> encodeFoodProcessList
                |> sendResponse 200 request

        Just (Route.Get Route.FoodTransformList) ->
            foodDb.processes
                |> List.filter (.category >> (==) FoodProcess.Transform)
                |> encodeFoodProcessList
                |> sendResponse 200 request

        Just (Route.Get (Route.FoodRecipe (Ok query))) ->
            query |> executeFoodQuery foodDb request (toFoodResults query)

        Just (Route.Get (Route.FoodRecipe (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just (Route.Get Route.TextileMaterialList) ->
            textileDb.materials
                |> Encode.list encodeMaterial
                |> sendResponse 200 request

        Just (Route.Get Route.TextileProductList) ->
            textileDb.products
                |> Encode.list encodeProduct
                |> sendResponse 200 request

        Just (Route.Get (Route.TextileSimulator (Ok query))) ->
            query |> executeTextileQuery textileDb request toAllImpactsSimple

        Just (Route.Get (Route.TextileSimulator (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just (Route.Get (Route.TextileSimulatorDetailed (Ok query))) ->
            query |> executeTextileQuery textileDb request Simulator.encode

        Just (Route.Get (Route.TextileSimulatorDetailed (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just (Route.Get (Route.TextileSimulatorSingle trigram (Ok query))) ->
            query |> executeTextileQuery textileDb request (toSingleImpactSimple trigram)

        Just (Route.Get (Route.TextileSimulatorSingle _ (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just _ ->
            encodeStringError "Method not allowed"
                |> sendResponse 405 request

        Nothing ->
            encodeStringError "Endpoint doesn't exist"
                |> sendResponse 404 request


update : Msg -> Cmd Msg
update msg =
    case msg of
        Received request ->
            case StaticDb.db of
                Err dbError ->
                    encodeStringError dbError |> sendResponse 503 request

                Ok db ->
                    handleRequest db request


main : Program () () Msg
main =
    Platform.worker
        { init = always ( (), Cmd.none )

        -- The Api server being stateless, there's no need of a model
        , update = \msg _ -> ( (), update msg )
        , subscriptions = always (input Received)
        }


port input : (Request -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
