port module Server exposing
    ( handleRequest
    , input
    , main
    , output
    )

import Data.Component as Component exposing (Component)
import Data.Country as Country exposing (Country)
import Data.Food.Ingredient as Ingredient
import Data.Food.Origin as Origin
import Data.Food.Query as FoodQuery
import Data.Food.Recipe as Recipe
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Process as Process exposing (Process)
import Data.Process.Category as ProcessCategory
import Data.Scope as Scope
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as TextileProduct exposing (Product)
import Data.Textile.Query as TextileQuery
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Data.Textile.WellKnown exposing (WellKnown)
import Data.Validation as Validation
import Json.Encode as Encode
import Route as WebRoute
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


encodeValidationErrors : Validation.Errors -> Encode.Value
encodeValidationErrors errors =
    Encode.object
        [ ( "error", Validation.encodeErrors errors )
        , ( "documentation", Encode.string apiDocUrl )
        ]


toResponse : Result Validation.Errors Encode.Value -> JsonResponse
toResponse encodedResult =
    case encodedResult of
        Err errors ->
            ( 400, encodeValidationErrors errors )

        Ok encoded ->
            ( 200, encoded )


toAllImpactsSimple : WellKnown -> Simulator -> Encode.Value
toAllImpactsSimple wellKnown { impacts, inputs } =
    Encode.object
        [ ( "webUrl", serverRootUrl ++ toTextileWebUrl Nothing inputs |> Encode.string )
        , ( "impacts", Impact.encode impacts )
        , ( "description", inputs |> Inputs.toString wellKnown |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> TextileQuery.encode )
        ]


toFoodWebUrl : Definition.Trigram -> FoodQuery.Query -> String
toFoodWebUrl trigram foodQuery =
    Just foodQuery
        |> WebRoute.FoodBuilder trigram
        |> WebRoute.toString


toTextileWebUrl : Maybe Definition.Trigram -> Inputs.Inputs -> String
toTextileWebUrl maybeTrigram textileQuery =
    Just (Inputs.toQuery textileQuery)
        |> WebRoute.TextileSimulator (Maybe.withDefault Impact.default maybeTrigram)
        |> WebRoute.toString


toSingleImpactSimple : WellKnown -> Definition.Trigram -> Simulator -> Encode.Value
toSingleImpactSimple wellKnown trigram { impacts, inputs } =
    Encode.object
        [ ( "webUrl", serverRootUrl ++ toTextileWebUrl (Just trigram) inputs |> Encode.string )
        , ( "impacts"
          , Impact.encodeSingleImpact impacts trigram
          )
        , ( "description", inputs |> Inputs.toString wellKnown |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> TextileQuery.encode )
        ]


toFoodResults : FoodQuery.Query -> Recipe.Results -> Encode.Value
toFoodResults query results =
    Encode.object
        [ ( "webUrl", serverRootUrl ++ toFoodWebUrl Impact.default query |> Encode.string )
        , ( "results", Recipe.encodeResults results )
        , ( "description", Encode.string "TODO" )
        , ( "query", FoodQuery.encode query )
        ]


executeFoodQuery : Db -> (Recipe.Results -> Encode.Value) -> FoodQuery.Query -> JsonResponse
executeFoodQuery db encoder =
    Recipe.compute db
        >> Result.mapError Validation.fromErrorString
        >> Result.map (Tuple.second >> encoder)
        >> toResponse


executeTextileQuery : Db -> (Simulator -> Encode.Value) -> TextileQuery.Query -> JsonResponse
executeTextileQuery db encoder =
    Simulator.compute db
        >> Result.mapError Validation.fromErrorString
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


encodeProcess : Process -> Encode.Value
encodeProcess process =
    Encode.object
        [ ( "id", process.id |> Process.idToString |> Encode.string )
        , ( "name", process |> Process.getDisplayName |> Encode.string )
        ]


encodeComponent : Component -> Encode.Value
encodeComponent { id, name } =
    Encode.object
        [ ( "id", Component.encodeId id )
        , ( "name", Encode.string name )
        ]


encodeProcessList : List Process -> Encode.Value
encodeProcessList =
    Encode.list encodeProcess


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
                |> Scope.anyOf [ Scope.Food ]
                |> Encode.list encodeCountry
                |> respondWith 200

        Just Route.FoodGetIngredientList ->
            db.food.ingredients
                |> encodeIngredients
                |> respondWith 200

        Just Route.FoodGetPackagingList ->
            db.processes
                |> Scope.anyOf [ Scope.Food ]
                |> List.filter (.categories >> List.member ProcessCategory.Packaging)
                |> encodeProcessList
                |> respondWith 200

        Just Route.FoodGetTransformList ->
            db.processes
                |> Scope.anyOf [ Scope.Food ]
                |> List.filter (.categories >> List.member ProcessCategory.Transform)
                |> encodeProcessList
                |> respondWith 200

        Just Route.TextileGetCountryList ->
            db.countries
                |> Scope.anyOf [ Scope.Textile ]
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

        Just Route.TextileGetTrimList ->
            db.components
                |> Scope.anyOf [ Scope.Textile ]
                |> Encode.list encodeComponent
                |> respondWith 200

        -- POST routes
        Just (Route.FoodPostRecipe (Ok foodQuery)) ->
            executeFoodQuery db (toFoodResults foodQuery) foodQuery

        Just (Route.FoodPostRecipe (Err error)) ->
            encodeValidationErrors error
                |> respondWith 400

        Just (Route.TextilePostSimulator (Ok textileQuery)) ->
            textileQuery
                |> executeTextileQuery db (toAllImpactsSimple db.textile.wellKnown)

        Just (Route.TextilePostSimulator (Err error)) ->
            encodeValidationErrors error
                |> respondWith 400

        Just (Route.TextilePostSimulatorDetailed (Ok textileQuery)) ->
            textileQuery
                |> executeTextileQuery db Simulator.encode

        Just (Route.TextilePostSimulatorDetailed (Err error)) ->
            encodeValidationErrors error
                |> respondWith 400

        Just (Route.TextilePostSimulatorSingle (Ok textileQuery) trigram) ->
            textileQuery
                |> executeTextileQuery db (toSingleImpactSimple db.textile.wellKnown trigram)

        Just (Route.TextilePostSimulatorSingle (Err error) _) ->
            encodeValidationErrors error
                |> respondWith 400

        Nothing ->
            "Endpoint doesn't exist"
                |> Validation.fromErrorString
                |> encodeValidationErrors
                |> respondWith 404


update : Msg -> Cmd Msg
update msg =
    case msg of
        Received request ->
            case db request.processes of
                Err error ->
                    error
                        |> Validation.fromErrorString
                        |> encodeValidationErrors
                        |> sendResponse 503 request

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
