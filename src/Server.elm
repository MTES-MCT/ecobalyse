port module Server exposing
    ( input
    , main
    , output
    )

import Data.Country as Country exposing (Country)
import Data.Impact as Impact
import Data.Textile.Db as TextileDb
import Data.Textile.Inputs as Inputs
import Data.Textile.Material as Material exposing (Material)
import Data.Textile.Product as Product exposing (Product)
import Data.Textile.Simulator as Simulator exposing (Simulator)
import Json.Encode as Encode
import Server.Query as Query
import Server.Request exposing (Request)
import Server.Route as Route


type alias Flags =
    { jsonDb : String }


type alias Model =
    { textileDb : Result String TextileDb.Db
    }


type Msg
    = Received Request


init : Flags -> ( Model, Cmd Msg )
init { jsonDb } =
    ( { textileDb = TextileDb.buildFromJson jsonDb }
    , Cmd.none
    )


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


executeQuery : TextileDb.Db -> Request -> (Simulator -> Encode.Value) -> Inputs.Query -> Cmd Msg
executeQuery textileDb request encoder =
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
        [ ( "id", Product.encodeId id )
        , ( "name", Encode.string name )
        ]


handleRequest : TextileDb.Db -> Request -> Cmd Msg
handleRequest textileDb request =
    case Route.endpoint textileDb request of
        Just (Route.Get Route.CountryList) ->
            textileDb.countries
                |> Encode.list encodeCountry
                |> sendResponse 200 request

        -- Just (Route.Get Route.FoodIngredientList) ->
        Just (Route.Get Route.TextileMaterialList) ->
            textileDb.materials
                |> Encode.list encodeMaterial
                |> sendResponse 200 request

        Just (Route.Get Route.TextileProductList) ->
            textileDb.products
                |> Encode.list encodeProduct
                |> sendResponse 200 request

        Just (Route.Get (Route.TextileSimulator (Ok query))) ->
            query |> executeQuery textileDb request toAllImpactsSimple

        Just (Route.Get (Route.TextileSimulator (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just (Route.Get (Route.TextileSimulatorDetailed (Ok query))) ->
            query |> executeQuery textileDb request Simulator.encode

        Just (Route.Get (Route.TextileSimulatorDetailed (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just (Route.Get (Route.TextileSimulatorSingle trigram (Ok query))) ->
            query |> executeQuery textileDb request (toSingleImpactSimple trigram)

        Just (Route.Get (Route.TextileSimulatorSingle _ (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just _ ->
            encodeStringError "Method not allowed"
                |> sendResponse 405 request

        Nothing ->
            encodeStringError "Endpoint doesn't exist"
                |> sendResponse 404 request


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Received request ->
            case model.textileDb of
                Err dbError ->
                    ( model
                    , encodeStringError dbError |> sendResponse 503 request
                    )

                Ok textileDb ->
                    ( model, handleRequest textileDb request )


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Received
        }


port input : (Request -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
