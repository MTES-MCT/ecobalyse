port module Server exposing
    ( handleRequest
    , input
    , main
    , output
    )

import Data.Country as Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Food.Ingredient as Ingredient
import Data.Food.Origin as Origin
import Data.Food.Process as FoodProcess
import Data.Food.Query as BuilderQuery
import Data.Food.Recipe as BuilderRecipe
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Scope as Scope
import Data.Textile.Db as TextileDb
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as TextileProduct exposing (Product)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Data.Unit as Unit
import Json.Decode as Decode
import Json.Encode as Encode
import Page.Textile.Simulator.ViewMode as ViewMode
import Route as WebRoute
import Server.Query as Query
import Server.Request exposing (Request)
import Server.Route as Route
import Static.Db as StaticDb


type Msg
    = Received Request


type alias JsonResponse =
    ( Int, Encode.Value )


serverRootUrl : String
serverRootUrl =
    "https://ecobalyse.beta.gouv.fr/"


apiDocUrl : String
apiDocUrl =
    serverRootUrl ++ "#/api"


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


toResponse : Result String Encode.Value -> JsonResponse
toResponse encodedResult =
    case encodedResult of
        Ok encoded ->
            ( 200, encoded )

        Err error ->
            ( 400, encodeStringError error )


toAllImpactsSimple : Simulator -> Encode.Value
toAllImpactsSimple { inputs, impacts } =
    Encode.object
        [ ( "webUrl", serverRootUrl ++ toTextileWebUrl Nothing inputs |> Encode.string )
        , ( "impacts", Impact.encode impacts )
        , ( "description", inputs |> Inputs.toString |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> Inputs.encodeQuery )
        ]


toFoodWebUrl : Definition.Trigram -> BuilderQuery.Query -> String
toFoodWebUrl trigram foodQuery =
    Just foodQuery
        |> WebRoute.FoodBuilder trigram
        |> WebRoute.toString


toTextileWebUrl : Maybe Definition.Trigram -> Inputs.Inputs -> String
toTextileWebUrl maybeTrigram textileQuery =
    Just (Inputs.toQuery textileQuery)
        |> WebRoute.TextileSimulator (Maybe.withDefault Impact.default maybeTrigram)
            Unit.PerItem
            ViewMode.Simple
        |> WebRoute.toString


toSingleImpactSimple : Definition.Trigram -> Simulator -> Encode.Value
toSingleImpactSimple trigram { inputs, impacts } =
    Encode.object
        [ ( "webUrl", serverRootUrl ++ toTextileWebUrl (Just trigram) inputs |> Encode.string )
        , ( "impacts"
          , Impact.encodeSingleImpact impacts trigram
          )
        , ( "description", inputs |> Inputs.toString |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> Inputs.encodeQuery )
        ]


toFoodResults : BuilderQuery.Query -> BuilderRecipe.Results -> Encode.Value
toFoodResults query results =
    Encode.object
        [ ( "webUrl", serverRootUrl ++ toFoodWebUrl Impact.default query |> Encode.string )
        , ( "results", BuilderRecipe.encodeResults results )
        , ( "description", Encode.string "TODO" )
        , ( "query", BuilderQuery.encode query )
        ]


executeFoodQuery : FoodDb.Db -> (BuilderRecipe.Results -> Encode.Value) -> BuilderQuery.Query -> JsonResponse
executeFoodQuery foodDb encoder =
    BuilderRecipe.compute foodDb
        >> Result.map (Tuple.second >> encoder)
        >> toResponse


executeTextileQuery : TextileDb.Db -> (Simulator -> Encode.Value) -> Inputs.Query -> JsonResponse
executeTextileQuery textileDb encoder =
    Simulator.compute textileDb
        >> Result.map encoder
        >> toResponse


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


encodeIngredient : Ingredient.Ingredient -> Encode.Value
encodeIngredient ingredient =
    Encode.object
        [ ( "id", Ingredient.idToString ingredient.id |> Encode.string )
        , ( "name", ingredient.name |> Encode.string )
        , ( "defaultOrigin", ingredient.defaultOrigin |> Origin.toLabel |> Encode.string )
        ]


encodeIngredients : List Ingredient.Ingredient -> Encode.Value
encodeIngredients ingredients =
    Encode.list encodeIngredient ingredients


cmdRequest : StaticDb.Db -> Request -> Cmd Msg
cmdRequest dbs request =
    let
        ( code, responseBody ) =
            handleRequest dbs request
    in
    sendResponse code request responseBody


respondWith : Int -> Encode.Value -> JsonResponse
respondWith =
    Tuple.pair


handleRequest : StaticDb.Db -> Request -> JsonResponse
handleRequest ({ foodDb, textileDb } as dbs) request =
    case Route.endpoint dbs request of
        -- GET routes
        Just Route.GetFoodCountryList ->
            foodDb.countries
                |> Scope.only Scope.Food
                |> Encode.list encodeCountry
                |> respondWith 200

        Just Route.GetFoodIngredientList ->
            foodDb.ingredients
                |> encodeIngredients
                |> respondWith 200

        Just Route.GetFoodPackagingList ->
            foodDb.processes
                |> List.filter (.category >> (==) FoodProcess.Packaging)
                |> encodeFoodProcessList
                |> respondWith 200

        Just Route.GetFoodTransformList ->
            foodDb.processes
                |> List.filter (.category >> (==) FoodProcess.Transform)
                |> encodeFoodProcessList
                |> respondWith 200

        Just (Route.GetFoodRecipe (Ok query)) ->
            query
                |> executeFoodQuery foodDb (toFoodResults query)

        Just (Route.GetFoodRecipe (Err errors)) ->
            Query.encodeErrors errors
                |> respondWith 400

        Just Route.GetTextileCountryList ->
            textileDb.countries
                |> Scope.only Scope.Textile
                |> Encode.list encodeCountry
                |> respondWith 200

        Just Route.GetTextileMaterialList ->
            textileDb.materials
                |> Encode.list encodeMaterial
                |> respondWith 200

        Just Route.GetTextileProductList ->
            textileDb.products
                |> Encode.list encodeProduct
                |> respondWith 200

        Just (Route.GetTextileSimulator (Ok query)) ->
            query
                |> executeTextileQuery textileDb toAllImpactsSimple

        Just (Route.GetTextileSimulator (Err errors)) ->
            Query.encodeErrors errors
                |> respondWith 400

        Just (Route.GetTextileSimulatorDetailed (Ok query)) ->
            query
                |> executeTextileQuery textileDb Simulator.encode

        Just (Route.GetTextileSimulatorDetailed (Err errors)) ->
            Query.encodeErrors errors
                |> respondWith 400

        Just (Route.GetTextileSimulatorSingle trigram (Ok query)) ->
            query
                |> executeTextileQuery textileDb (toSingleImpactSimple trigram)

        Just (Route.GetTextileSimulatorSingle _ (Err errors)) ->
            Query.encodeErrors errors
                |> respondWith 400

        -- POST routes
        Just Route.PostFoodRecipe ->
            request.body
                |> handleDecodeBody BuilderQuery.decode
                    (\query ->
                        query
                            |> executeFoodQuery foodDb (toFoodResults query)
                    )

        Just Route.PostTextileSimulator ->
            request.body
                |> handleDecodeBody Inputs.decodeQuery
                    (executeTextileQuery textileDb toAllImpactsSimple)

        Just Route.PostTextileSimulatorDetailed ->
            request.body
                |> handleDecodeBody Inputs.decodeQuery
                    (executeTextileQuery textileDb Simulator.encode)

        Just (Route.PostTextileSimulatorSingle trigram) ->
            request.body
                |> handleDecodeBody Inputs.decodeQuery
                    (executeTextileQuery textileDb (toSingleImpactSimple trigram))

        Nothing ->
            encodeStringError "Endpoint doesn't exist"
                |> respondWith 404


handleDecodeBody : Decode.Decoder a -> (a -> JsonResponse) -> Encode.Value -> JsonResponse
handleDecodeBody decoder mapper jsonBody =
    case Decode.decodeValue decoder jsonBody of
        Ok x ->
            mapper x

        Err error ->
            ( 400, Encode.string (Decode.errorToString error) )


update : Msg -> Cmd Msg
update msg =
    case msg of
        Received request ->
            case StaticDb.db of
                Err dbError ->
                    encodeStringError dbError |> sendResponse 503 request

                Ok db ->
                    cmdRequest db request


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
