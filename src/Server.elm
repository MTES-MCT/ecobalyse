port module Server exposing
    ( input
    , main
    , output
    )

import Data.Country as Country exposing (Country)
import Data.Food.Builder.Db as BuilderDb
import Data.Food.Builder.Query as BuilderQuery
import Data.Food.Builder.Recipe as BuilderRecipe
import Data.Food.Ingredient as Ingredient
import Data.Food.Origin as Origin
import Data.Food.Process as FoodProcess
import Data.Impact as Impact
import Data.Scope as Scope
import Data.Textile.Db as TextileDb
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as TextileProduct exposing (Product)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Json.Decode as Decode
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


toResponse : Result String Encode.Value -> ( Int, Encode.Value )
toResponse encodedResult =
    case encodedResult of
        Ok encoded ->
            ( 200, encoded )

        Err error ->
            ( 400, encodeStringError error )


toAllImpactsSimple : List Impact.Definition -> Simulator -> Encode.Value
toAllImpactsSimple definitions { inputs, impacts } =
    Encode.object
        [ ( "impacts", Impact.encodeImpacts definitions Scope.Textile impacts )
        , ( "description", inputs |> Inputs.toString |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> Inputs.encodeQuery )
        ]


toSingleImpactSimple : List Impact.Definition -> Impact.Trigram -> Simulator -> Encode.Value
toSingleImpactSimple definitions trigram { inputs, impacts } =
    Encode.object
        [ ( "impacts"
          , impacts
                |> Impact.filterImpacts (\trg _ -> trigram == trg)
                |> Impact.encodeImpacts definitions Scope.Textile
          )
        , ( "description", inputs |> Inputs.toString |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> Inputs.encodeQuery )
        ]


toFoodResults : List Impact.Definition -> BuilderQuery.Query -> BuilderRecipe.Results -> Encode.Value
toFoodResults definitions query results =
    Encode.object
        [ ( "results", BuilderRecipe.encodeResults definitions results )
        , ( "description", Encode.string "TODO" )
        , ( "query", BuilderQuery.encode query )
        ]


executeFoodQuery : BuilderDb.Db -> (BuilderRecipe.Results -> Encode.Value) -> BuilderQuery.Query -> ( Int, Encode.Value )
executeFoodQuery builderDb encoder =
    BuilderRecipe.compute builderDb
        >> Result.map (Tuple.second >> encoder)
        >> toResponse


executeTextileQuery : TextileDb.Db -> (Simulator -> Encode.Value) -> Inputs.Query -> ( Int, Encode.Value )
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
        , ( "variants"
          , (if ingredient.variants.organic /= Nothing then
                [ "organic" ]

             else
                []
            )
                |> Encode.list Encode.string
          )
        , ( "defaultOrigin", ingredient.defaultOrigin |> Origin.toLabel |> Encode.string )
        ]


encodeIngredients : List Ingredient.Ingredient -> Encode.Value
encodeIngredients ingredients =
    Encode.list encodeIngredient ingredients


cmdRequest : StaticDb.Db -> Request -> Cmd Msg
cmdRequest dbs request =
    let
        ( code, body ) =
            handleRequest dbs request
    in
    sendResponse code request body


handleRequest : StaticDb.Db -> Request -> ( Int, Encode.Value )
handleRequest ({ builderDb, textileDb } as dbs) request =
    case Route.endpoint dbs request of
        -- GET routes
        Just Route.GetFoodCountryList ->
            ( 200
            , builderDb.countries
                |> Scope.only Scope.Food
                |> Encode.list encodeCountry
            )

        Just Route.GetFoodIngredientList ->
            ( 200, encodeIngredients builderDb.ingredients )

        Just Route.GetFoodPackagingList ->
            ( 200
            , builderDb.processes
                |> List.filter (.category >> (==) FoodProcess.Packaging)
                |> encodeFoodProcessList
            )

        Just Route.GetFoodTransformList ->
            ( 200
            , builderDb.processes
                |> List.filter (.category >> (==) FoodProcess.Transform)
                |> encodeFoodProcessList
            )

        Just (Route.GetFoodRecipe (Ok query)) ->
            query
                |> executeFoodQuery builderDb (toFoodResults builderDb.impacts query)

        Just (Route.GetFoodRecipe (Err errors)) ->
            ( 400, Query.encodeErrors errors )

        Just Route.GetTextileCountryList ->
            ( 200
            , textileDb.countries
                |> Scope.only Scope.Textile
                |> Encode.list encodeCountry
            )

        Just Route.GetTextileMaterialList ->
            ( 200, Encode.list encodeMaterial textileDb.materials )

        Just Route.GetTextileProductList ->
            ( 200, Encode.list encodeProduct textileDb.products )

        Just (Route.GetTextileSimulator (Ok query)) ->
            query
                |> executeTextileQuery textileDb (toAllImpactsSimple textileDb.impacts)

        Just (Route.GetTextileSimulator (Err errors)) ->
            ( 400, Query.encodeErrors errors )

        Just (Route.GetTextileSimulatorDetailed (Ok query)) ->
            query
                |> executeTextileQuery textileDb (Simulator.encode textileDb.impacts)

        Just (Route.GetTextileSimulatorDetailed (Err errors)) ->
            ( 400, Query.encodeErrors errors )

        Just (Route.GetTextileSimulatorSingle trigram (Ok query)) ->
            query
                |> executeTextileQuery textileDb (toSingleImpactSimple textileDb.impacts trigram)

        Just (Route.GetTextileSimulatorSingle _ (Err errors)) ->
            ( 400, Query.encodeErrors errors )

        -- POST routes
        Just Route.PostFoodRecipe ->
            case Decode.decodeValue BuilderQuery.decode request.body of
                Ok query ->
                    query
                        |> executeFoodQuery builderDb (toFoodResults builderDb.impacts query)

                Err error ->
                    ( 400
                    , error |> Decode.errorToString |> Encode.string
                    )

        Nothing ->
            ( 404, encodeStringError "Endpoint doesn't exist" )


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
