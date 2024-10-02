port module Server exposing
    ( handleRequest
    , input
    , main
    , output
    )

import Data.Country as Country exposing (Country)
import Data.Food.Ingredient as Ingredient
import Data.Food.Origin as Origin
import Data.Food.Process as FoodProcess
import Data.Food.Query as BuilderQuery
import Data.Food.Recipe as BuilderRecipe
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition
import Data.Object.Query as ObjectQuery
import Data.Object.Simulator as ObjectSimulator
import Data.Scope as Scope
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as TextileProduct exposing (Product)
import Data.Textile.Query as TextileQuery
import Data.Textile.Simulator as TextileSimulator
import Json.Encode as Encode
import Route as WebRoute
import Server.Query as Query
import Server.Request exposing (Request)
import Server.Route as Route
import Static.Db exposing (Db, db)


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
sendResponse httpStatus { jsResponseHandler, method, url } body =
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
        Err error ->
            ( 400, encodeStringError error )

        Ok encoded ->
            ( 200, encoded )


toAllTextileImpactsSimple : TextileSimulator.Simulator -> Encode.Value
toAllTextileImpactsSimple { impacts, inputs } =
    Encode.object
        [ ( "webUrl", serverRootUrl ++ toTextileWebUrl Nothing inputs |> Encode.string )
        , ( "impacts", Impact.encode impacts )
        , ( "description", inputs |> Inputs.toString |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> TextileQuery.encode )
        ]


toAllObjectImpactsSimple : Impacts -> Encode.Value
toAllObjectImpactsSimple impacts =
    Encode.object
        [ -- FIXME: add webUrl/description/query
          ( "impacts", Impact.encode impacts )
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
        |> WebRoute.toString


toSingleImpactSimple : Definition.Trigram -> TextileSimulator.Simulator -> Encode.Value
toSingleImpactSimple trigram { impacts, inputs } =
    Encode.object
        [ ( "webUrl", serverRootUrl ++ toTextileWebUrl (Just trigram) inputs |> Encode.string )
        , ( "impacts"
          , Impact.encodeSingleImpact impacts trigram
          )
        , ( "description", inputs |> Inputs.toString |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> TextileQuery.encode )
        ]


toFoodResults : BuilderQuery.Query -> BuilderRecipe.Results -> Encode.Value
toFoodResults query results =
    Encode.object
        [ ( "webUrl", serverRootUrl ++ toFoodWebUrl Impact.default query |> Encode.string )
        , ( "results", BuilderRecipe.encodeResults results )
        , ( "description", Encode.string "TODO" )
        , ( "query", BuilderQuery.encode query )
        ]


executeFoodQuery : Db -> (BuilderRecipe.Results -> Encode.Value) -> BuilderQuery.Query -> JsonResponse
executeFoodQuery db encoder =
    BuilderRecipe.compute db
        >> Result.map (Tuple.second >> encoder)
        >> toResponse


executeTextileQuery : Db -> (TextileSimulator.Simulator -> Encode.Value) -> TextileQuery.Query -> JsonResponse
executeTextileQuery db encoder =
    TextileSimulator.compute db
        >> Result.map encoder
        >> toResponse


executeObjectQuery : Db -> (Impacts -> Encode.Value) -> ObjectQuery.Query -> JsonResponse
executeObjectQuery db encoder =
    ObjectSimulator.compute db
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
        [ ( "code", process.identifier |> FoodProcess.identifierToString |> Encode.string )
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


cmdRequest : Db -> Request -> Cmd Msg
cmdRequest db request =
    let
        ( code, responseBody ) =
            handleRequest db request
    in
    sendResponse code request responseBody


respondWith : Int -> Encode.Value -> JsonResponse
respondWith =
    Tuple.pair


handleRequest : Db -> Request -> JsonResponse
handleRequest db request =
    case Route.endpoint db request of
        -- GET routes
        Just Route.FoodGetCountryList ->
            db.countries
                |> Scope.only Scope.Food
                |> Encode.list encodeCountry
                |> respondWith 200

        Just Route.FoodGetIngredientList ->
            db.food.ingredients
                |> encodeIngredients
                |> respondWith 200

        Just Route.FoodGetPackagingList ->
            db.food.processes
                |> List.filter (.category >> (==) FoodProcess.Packaging)
                |> encodeFoodProcessList
                |> respondWith 200

        Just Route.FoodGetTransformList ->
            db.food.processes
                |> List.filter (.category >> (==) FoodProcess.Transform)
                |> encodeFoodProcessList
                |> respondWith 200

        Just (Route.FoodGetRecipe (Ok query)) ->
            query
                |> executeFoodQuery db (toFoodResults query)

        Just (Route.FoodGetRecipe (Err errors)) ->
            Query.encodeErrors errors
                |> respondWith 400

        Just Route.TextileGetCountryList ->
            db.countries
                |> Scope.only Scope.Textile
                |> Encode.list encodeCountry
                |> respondWith 200

        Just Route.TextileGetMaterialList ->
            db.textile.materials
                |> Encode.list encodeMaterial
                |> respondWith 200

        Just Route.TextileGetProductList ->
            db.textile.products
                |> Encode.list encodeProduct
                |> respondWith 200

        Just (Route.TextileGetSimulator (Ok query)) ->
            query
                |> executeTextileQuery db toAllTextileImpactsSimple

        Just (Route.TextileGetSimulator (Err errors)) ->
            Query.encodeErrors errors
                |> respondWith 400

        Just (Route.TextileGetSimulatorDetailed (Ok query)) ->
            query
                |> executeTextileQuery db TextileSimulator.encode

        Just (Route.TextileGetSimulatorDetailed (Err errors)) ->
            Query.encodeErrors errors
                |> respondWith 400

        Just (Route.TextileGetSimulatorSingle trigram (Ok query)) ->
            query
                |> executeTextileQuery db (toSingleImpactSimple trigram)

        Just (Route.TextileGetSimulatorSingle _ (Err errors)) ->
            Query.encodeErrors errors
                |> respondWith 400

        Just (Route.ObjectGetSimulator (Ok query)) ->
            query
                |> executeObjectQuery db toAllObjectImpactsSimple

        Just (Route.ObjectGetSimulator (Err errors)) ->
            Query.encodeErrors errors
                |> respondWith 400

        -- POST routes
        Just (Route.FoodPostRecipe (Ok foodQuery)) ->
            executeFoodQuery db (toFoodResults foodQuery) foodQuery

        Just (Route.FoodPostRecipe (Err error)) ->
            Encode.string error
                |> respondWith 400

        Just (Route.TextilePostSimulator (Ok textileQuery)) ->
            textileQuery
                |> executeTextileQuery db toAllTextileImpactsSimple

        Just (Route.TextilePostSimulator (Err error)) ->
            Encode.string error
                |> respondWith 400

        Just (Route.TextilePostSimulatorDetailed (Ok textileQuery)) ->
            textileQuery
                |> executeTextileQuery db TextileSimulator.encode

        Just (Route.TextilePostSimulatorDetailed (Err error)) ->
            Encode.string error
                |> respondWith 400

        Just (Route.TextilePostSimulatorSingle (Ok textileQuery) trigram) ->
            textileQuery
                |> executeTextileQuery db (toSingleImpactSimple trigram)

        Just (Route.TextilePostSimulatorSingle (Err error) _) ->
            Encode.string error
                |> respondWith 400

        Nothing ->
            encodeStringError "Endpoint doesn't exist"
                |> respondWith 404


update : Msg -> Cmd Msg
update msg =
    case msg of
        Received request ->
            case db request.processes of
                Err error ->
                    encodeStringError error |> sendResponse 503 request

                Ok db ->
                    cmdRequest db request


main : Program () () Msg
main =
    -- Note: The Api server being stateless, there's no need for a model
    Platform.worker
        { init = always ( (), Cmd.none )
        , subscriptions = always (input Received)
        , update = \msg _ -> ( (), update msg )
        }


port input : (Request -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
