port module Server exposing (main)

import Data.Db as Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Simulator as Simulator exposing (Simulator)
import Json.Encode as Encode
import Server.Query as Query
import Url
import Url.Parser as Parser exposing ((</>), (<?>), Parser)


type alias Flags =
    { jsonDb : String }


type alias Model =
    { db : Result String Db
    }


type Msg
    = Received Request


type alias Request =
    -- Notes:
    -- - `method` is ExpressJS `method` string (HTTP verb: GET, POST, etc.)
    -- - `url` is ExpressJS `url` string
    --   string params, which uses the qs package under the hood:
    --   https://www.npmjs.com/package/qs
    -- - `jsResponseHandler` is an ExpressJS response callback function
    { method : String
    , url : String
    , jsResponseHandler : Encode.Value
    }


type Route
    = Home
      -- Simple version of all impacts
    | Simulator (Result Query.Errors Inputs.Query)
      -- Detailed version for all impacts
    | SimulatorDetailed (Result Query.Errors Inputs.Query)
      -- Simple version for one specific impact
    | SimulatorSingle Impact.Trigram (Result Query.Errors Inputs.Query)


type Endpoint
    = Get Route
    | Head Route
    | Post Route
    | Put Route
    | Delete Route
    | Connect Route
    | Options Route
    | Trace Route
    | Path Route


init : Flags -> ( Model, Cmd Msg )
init { jsonDb } =
    ( { db = Db.buildFromJson jsonDb }
    , Cmd.none
    )


parser : Db -> Parser (Route -> a) a
parser db =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Simulator (Parser.s "simulator" <?> Query.parse db)
        , Parser.map SimulatorDetailed (Parser.s "simulator" </> Parser.s "detailed" <?> Query.parse db)
        , Parser.map SimulatorSingle (Parser.s "simulator" </> Impact.parseTrigram <?> Query.parse db)
        ]


endpoint : Db -> Request -> Maybe Endpoint
endpoint db { method, url } =
    Url.fromString ("http://x" ++ url)
        |> Maybe.andThen (Parser.parse (parser db))
        |> Maybe.map (mapMethod method)


mapMethod : String -> Route -> Endpoint
mapMethod method route =
    case String.toUpper method of
        "HEAD" ->
            Head route

        "POST" ->
            Post route

        "PUT" ->
            Put route

        "DELETE" ->
            Delete route

        "CONNECT" ->
            Connect route

        "OPTIONS" ->
            Options route

        "TRACE" ->
            Trace route

        "PATH" ->
            Path route

        _ ->
            Get route


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


handleRequest : Db -> Request -> Cmd Msg
handleRequest db request =
    case endpoint db request of
        Just (Get Home) ->
            Encode.object
                [ ( "service", Encode.string "Wikicarbone" )
                , ( "documentation", Encode.string apiDocUrl )

                -- FIXME: the openapi document should be served by some /openapi API endpoint
                , ( "openapi", Encode.string "https://wikicarbone.beta.gouv.fr/data/openapi.yaml" )
                ]
                |> sendResponse 200 request

        Just (Get (Simulator (Ok query))) ->
            query |> executeQuery db request toAllImpactsSimple

        Just (Get (Simulator (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just (Get (SimulatorDetailed (Ok query))) ->
            query |> executeQuery db request Simulator.encode

        Just (Get (SimulatorDetailed (Err errors))) ->
            Query.encodeErrors errors
                |> sendResponse 400 request

        Just (Get (SimulatorSingle trigram (Ok query))) ->
            query |> executeQuery db request (toSingleImpactSimple trigram)

        Just (Get (SimulatorSingle _ (Err errors))) ->
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
