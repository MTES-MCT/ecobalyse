port module Server exposing
    ( input
    , main
    , output
    )

import Data.Country as Country exposing (Country)
import Data.Db as Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Material exposing (Material)
import Data.Process as Process
import Data.Product as Product exposing (Product)
import Data.Simulator as Simulator exposing (Simulator)
import Json.Encode as Encode
import Server.Query as Query
import Server.Request exposing (Request)
import Server.Route as Route


type alias Flags =
    { jsonDb : String }


type alias Model =
    { db : Result String Db
    }


type Msg
    = Received Request


init : Flags -> ( Model, Cmd Msg )
init { jsonDb } =
    ( { db = Db.buildFromJson jsonDb }
    , Cmd.none
    )


apiDocUrl : String
apiDocUrl =
    "https://wikicarbone.beta.gouv.fr/#/api"


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
        , ( "query", inputs |> Inputs.toQuery |> Inputs.encodeQuery )
        ]


executeQuery : Db -> Request -> (Simulator -> Encode.Value) -> Inputs.Query -> Cmd Msg
executeQuery db request encoder =
    Simulator.compute db
        >> Result.map encoder
        >> toResponse request


encodeCountryList : List Country -> Encode.Value
encodeCountryList =
    Encode.list
        (\{ code, name } ->
            Encode.object
                [ ( "code", Country.encodeCode code )
                , ( "name", Encode.string name )
                ]
        )


encodeMaterialList : List Material -> Encode.Value
encodeMaterialList =
    Encode.list
        (\{ uuid, name } ->
            Encode.object
                [ ( "uuid", Process.encodeUuid uuid )
                , ( "name", Encode.string name )
                ]
        )


encodeProductList : List Product -> Encode.Value
encodeProductList =
    Encode.list
        (\{ id, name } ->
            Encode.object
                [ ( "id", Product.encodeId id )
                , ( "name", Encode.string name )
                ]
        )


handleRequest : Db -> Request -> Cmd Msg
handleRequest db request =
    case Route.endpoint db request of
        Just (Route.Get Route.CountryList) ->
            encodeCountryList db.countries
                |> sendResponse 200 request

        Just (Route.Get Route.MaterialList) ->
            encodeMaterialList db.materials
                |> sendResponse 200 request

        Just (Route.Get Route.ProductList) ->
            encodeProductList db.products
                |> sendResponse 200 request

        Just (Route.Get (Route.Simulator (Ok query))) ->
            query |> executeQuery db request toAllImpactsSimple

        Just (Route.Get (Route.Simulator (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just (Route.Get (Route.SimulatorDetailed (Ok query))) ->
            query |> executeQuery db request Simulator.encode

        Just (Route.Get (Route.SimulatorDetailed (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just (Route.Get (Route.SimulatorSingle trigram (Ok query))) ->
            query |> executeQuery db request (toSingleImpactSimple trigram)

        Just (Route.Get (Route.SimulatorSingle _ (Err errors))) ->
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
            case model.db of
                Err dbError ->
                    ( model
                    , encodeStringError dbError |> sendResponse 503 request
                    )

                Ok db ->
                    ( model, handleRequest db request )


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Received
        }


port input : (Request -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
