port module Server exposing
    ( handleRequest
    , input
    , main
    , output
    )

import Data.Common.EncodeUtils as EU
import Data.Component as Component exposing (Component)
import Data.Component.ProductCategory as ProductCategory
import Data.Country exposing (Country)
import Data.Country.Code as CountryCode
import Data.Db exposing (Db)
import Data.Food.Ingredient as Ingredient
import Data.Food.Origin as Origin
import Data.Food.Query as FoodQuery
import Data.Food.Recipe as Recipe
import Data.Generic.Simulator as GenericSimulator
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
import Static.Db as StaticDb
import Static.Json as StaticJson


type Msg
    = Received Request


type alias JsonResponse =
    ( Int, Encode.Value )


apiDocUrl : Request -> String
apiDocUrl request =
    serverRootUrl request ++ "#/api"


serverRootUrl : Request -> String
serverRootUrl request =
    request.protocol
        ++ "://"
        ++ request.host
        ++ (case request.version of
                Just version ->
                    "/versions/" ++ version ++ "/"

                Nothing ->
                    "/"
           )


sendResponse : Int -> Request -> Encode.Value -> Cmd Msg
sendResponse httpStatus { host, jsResponseHandler, method, protocol, url } body =
    Encode.object
        [ ( "status", Encode.int httpStatus )
        , ( "method", Encode.string method )
        , ( "protocol", Encode.string protocol )
        , ( "url", Encode.string url )
        , ( "host", Encode.string host )
        , ( "body", body )
        , ( "jsResponseHandler", jsResponseHandler )
        ]
        |> output


encodeValidationErrors : Request -> Validation.Errors -> Encode.Value
encodeValidationErrors request errors =
    Encode.object
        [ ( "error", Validation.encodeErrors errors )
        , ( "documentation", Encode.string <| apiDocUrl request )
        ]


toResponse : Request -> Result Validation.Errors Encode.Value -> JsonResponse
toResponse request encodedResult =
    case encodedResult of
        Err errors ->
            ( 400, encodeValidationErrors request <| errors )

        Ok encoded ->
            ( 200, encoded )


toAllImpactsSimple : Request -> WellKnown -> Simulator -> Encode.Value
toAllImpactsSimple request wellKnown { impacts, inputs } =
    Encode.object
        [ ( "webUrl", inputs |> toTextileWebUrl request Nothing |> Encode.string )
        , ( "impacts", Impact.encode impacts )
        , ( "description", inputs |> Inputs.toString wellKnown |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> TextileQuery.encode )
        ]


toFoodWebUrl : Request -> Definition.Trigram -> FoodQuery.Query -> String
toFoodWebUrl request trigram foodQuery =
    Just foodQuery
        |> WebRoute.FoodBuilder trigram
        |> WebRoute.toString
        |> (++) (serverRootUrl request)


toTextileWebUrl : Request -> Maybe Definition.Trigram -> Inputs.Inputs -> String
toTextileWebUrl request maybeTrigram textileQuery =
    Just (Inputs.toQuery textileQuery)
        |> WebRoute.TextileSimulator (Maybe.withDefault Impact.default maybeTrigram)
        |> WebRoute.toString
        |> (++) (serverRootUrl request)


toDetailedTextileWebUrl : Request -> Simulator -> String
toDetailedTextileWebUrl request =
    .inputs >> toTextileWebUrl request Nothing


toSingleImpactSimple : Request -> WellKnown -> Definition.Trigram -> Simulator -> Encode.Value
toSingleImpactSimple request wellKnown trigram { impacts, inputs } =
    Encode.object
        [ ( "webUrl", toTextileWebUrl request (Just trigram) inputs |> Encode.string )
        , ( "impacts", Impact.encodeSingleImpact impacts trigram )
        , ( "description", inputs |> Inputs.toString wellKnown |> Encode.string )
        , ( "query", inputs |> Inputs.toQuery |> TextileQuery.encode )
        ]


toFoodResults : Request -> FoodQuery.Query -> Recipe.Results -> Encode.Value
toFoodResults request query results =
    Encode.object
        [ ( "webUrl", query |> toFoodWebUrl request Impact.default |> Encode.string )
        , ( "results", Recipe.encodeResults results )
        , ( "description", Encode.string "TODO" )
        , ( "query", FoodQuery.encode query )
        ]


executeFoodQuery : Request -> Db -> (Recipe.Results -> Encode.Value) -> FoodQuery.Query -> JsonResponse
executeFoodQuery request db encoder =
    Recipe.compute db
        >> Result.mapError Validation.fromErrorString
        >> Result.map (Tuple.second >> encoder)
        >> toResponse request


executeGenericQuery : Request -> Db -> Scope.GenericScope -> Component.Query -> JsonResponse
executeGenericQuery request db genericScope query =
    Component.parseConfig db StaticJson.componentConfigJson
        |> Result.map
            (\config ->
                query
                    |> GenericSimulator.compute
                        { config = config
                        , db = db
                        , scope = Scope.Generic genericScope
                        }
                    |> Result.mapError Validation.fromErrorString
                    |> Result.map (toGenericResults request db genericScope query)
                    |> toResponse request
            )
        |> Result.withDefault ( 500, Encode.string "Error while loading generic configuration" )


executeTextileQuery : Request -> Db -> (Simulator -> Encode.Value) -> TextileQuery.Query -> JsonResponse
executeTextileQuery request db encoder query =
    Component.parseConfig db StaticJson.componentConfigJson
        |> Result.map
            (\config ->
                query
                    |> Simulator.compute db config
                    |> Result.mapError Validation.fromErrorString
                    |> Result.map encoder
                    |> toResponse request
            )
        |> Result.withDefault ( 500, Encode.string "Error while loading generic configuration" )


encodeCountry : Country -> Encode.Value
encodeCountry { code, name } =
    Encode.object
        [ ( "code", CountryCode.encode code )
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
    EU.optionalPropertiesObject
        [ ( "id", id |> Maybe.map Component.encodeId )
        , ( "name", Encode.string name |> Just )
        ]


encodeGenericProcess : Process -> Encode.Value
encodeGenericProcess process =
    Encode.object
        [ ( "id", process.id |> Process.idToString |> Encode.string )
        , ( "name", process |> Process.getDisplayName |> Encode.string )
        , ( "unit", process.unit |> Process.unitToString |> Encode.string )
        ]


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


encodeProcessList : List Process -> Encode.Value
encodeProcessList =
    Encode.list encodeProcess


genericProcessesResponse :
    Db
    -> Scope.GenericScope
    -> ProcessCategory.Category
    -- FIXME: we should handle a list of extra filters here
    -> (Process -> Bool)
    -> JsonResponse
genericProcessesResponse db genericScope category extraFilter =
    db.processes
        |> List.filter .visible
        |> Scope.anyOf [ Scope.Generic genericScope ]
        |> Process.listByCategory category
        |> List.filter extraFilter
        |> List.sortBy Process.getDisplayName
        |> Encode.list encodeGenericProcess
        |> respondWith 200


genericQueryDescription : Db -> Component.Query -> String
genericQueryDescription db query =
    query.product
        |> Maybe.andThen (\id -> db.products |> ProductCategory.findById id |> Result.toMaybe)
        |> Maybe.map .label
        |> Maybe.withDefault "Untitled simulation"


toGenericResults : Request -> Db -> Scope.GenericScope -> Component.Query -> Component.LifeCycle -> Encode.Value
toGenericResults request db genericScope query lifeCycle =
    Encode.object
        [ ( "webUrl", toGenericWebUrl request genericScope query |> Encode.string )
        , ( "impacts", lifeCycle |> Component.applyDurability query.durability |> Impact.encode )
        , ( "description", genericQueryDescription db query |> Encode.string )
        , ( "query", Component.encodeQuery query )
        ]


toGenericWebUrl : Request -> Scope.GenericScope -> Component.Query -> String
toGenericWebUrl request genericScope query =
    Just query
        |> WebRoute.GenericSimulator genericScope Impact.default
        |> WebRoute.toString
        |> (++) (serverRootUrl request)


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

        Just (Route.GenericGetAssemblyList genericScope) ->
            genericProcessesResponse db
                genericScope
                ProcessCategory.Assembly
                (always True)

        Just (Route.GenericGetCategoryList genericScope) ->
            db.products
                |> ProductCategory.findByScope genericScope
                |> Encode.list ProductCategory.encode
                |> respondWith 200

        Just (Route.GenericGetComponentList genericScope) ->
            db.components
                |> List.filter (not << Component.isEmpty)
                |> List.filter (.scope >> (==) (Scope.Generic genericScope))
                |> Encode.list encodeComponent
                |> respondWith 200

        Just (Route.GenericGetConsumptionList genericScope) ->
            genericProcessesResponse db
                genericScope
                ProcessCategory.Use
                (always True)

        Just (Route.GenericGetCountryList genericScope) ->
            db.countries
                |> Scope.anyOf [ Scope.Generic genericScope ]
                |> Encode.list encodeCountry
                |> respondWith 200

        Just (Route.GenericGetDistributionList genericScope) ->
            genericProcessesResponse db
                genericScope
                ProcessCategory.Distribution
                (.unit >> (==) Process.CubicMeter)

        Just (Route.GenericGetMaterialList genericScope) ->
            genericProcessesResponse db
                genericScope
                ProcessCategory.Material
                -- FIXME: we should probably use a helper from the Process module here
                (.categories >> List.member ProcessCategory.Packaging >> not)

        Just (Route.GenericGetPackagingList genericScope) ->
            genericProcessesResponse db
                genericScope
                ProcessCategory.Packaging
                (always True)

        Just (Route.GenericGetTransformList genericScope) ->
            genericProcessesResponse db
                genericScope
                ProcessCategory.Transform
                (always True)

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
                |> List.filter (.scope >> (==) Scope.Textile)
                |> Encode.list encodeComponent
                |> respondWith 200

        -- POST routes
        Just (Route.FoodPostRecipe (Ok foodQuery)) ->
            executeFoodQuery request db (toFoodResults request foodQuery) foodQuery

        Just (Route.FoodPostRecipe (Err error)) ->
            encodeValidationErrors request error
                |> respondWith 400

        Just (Route.GenericPostSimulator genericScope (Ok query)) ->
            executeGenericQuery request db genericScope query

        Just (Route.GenericPostSimulator _ (Err error)) ->
            encodeValidationErrors request error
                |> respondWith 400

        Just (Route.TextilePostSimulator (Ok textileQuery)) ->
            textileQuery
                |> executeTextileQuery request db (toAllImpactsSimple request db.textile.wellKnown)

        Just (Route.TextilePostSimulator (Err error)) ->
            encodeValidationErrors request error
                |> respondWith 400

        Just (Route.TextilePostSimulatorDetailed (Ok textileQuery)) ->
            textileQuery
                |> executeTextileQuery request
                    db
                    (\simulator ->
                        Simulator.encode
                            (toDetailedTextileWebUrl request simulator |> Just)
                            simulator
                    )

        Just (Route.TextilePostSimulatorDetailed (Err error)) ->
            encodeValidationErrors request error
                |> respondWith 400

        Just (Route.TextilePostSimulatorSingle (Ok textileQuery) trigram) ->
            textileQuery
                |> executeTextileQuery request db (toSingleImpactSimple request db.textile.wellKnown trigram)

        Just (Route.TextilePostSimulatorSingle (Err error) _) ->
            encodeValidationErrors request error
                |> respondWith 400

        Nothing ->
            "Endpoint doesn't exist"
                |> Validation.fromErrorString
                |> encodeValidationErrors request
                |> respondWith 404


update : Msg -> Cmd Msg
update msg =
    case msg of
        Received request ->
            case StaticDb.dbFromStaticFiles request.processes of
                Err error ->
                    error
                        |> Validation.fromErrorString
                        |> encodeValidationErrors request
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
