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
    | Simulator (Result Inputs.QueryErrors Inputs.Query)
      -- Detailed version for all impacts
    | SimulatorDetailed (Result Inputs.QueryErrors Inputs.Query)
      -- Simple version for one specific impact
    | SimulatorSingle Impact.Trigram (Result Inputs.QueryErrors Inputs.Query)


init : Flags -> ( Model, Cmd Msg )
init { jsonDb } =
    ( { db = Db.buildFromJson jsonDb }
    , Cmd.none
    )


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Simulator (Parser.s "simulator" <?> Query.parseQueryString)
        , Parser.map SimulatorDetailed (Parser.s "simulator" </> Parser.s "detailed" <?> Query.parseQueryString)
        , Parser.map SimulatorSingle (Parser.s "simulator" </> Impact.parseTrigram <?> Query.parseQueryString)
        ]


parseRoute : String -> Maybe Route
parseRoute urlPath =
    Url.fromString ("http://x" ++ urlPath)
        |> Maybe.andThen (Parser.parse parser)


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
executeQuery db request fn =
    Simulator.compute db
        >> Result.map fn
        >> toResponse request


handleRequest : Db -> Request -> Cmd Msg
handleRequest db ({ url } as request) =
    case parseRoute url of
        Just Home ->
            Encode.object
                [ ( "service", Encode.string "Wikicarbone" )
                , ( "documentation", Encode.string apiDocUrl )
                , ( "endpoints"
                  , Encode.object
                        [ ( "GET /simulator/"
                          , Encode.string "Simple version of all impacts"
                          )
                        , ( "GET /simulator/detailed/"
                          , Encode.string "Detailed version for all impacts"
                          )
                        , ( "GET /simulator/<impact>/"
                          , Encode.string "Simple version for one specific impact"
                          )
                        ]
                  )
                ]
                |> sendResponse 200 request

        Just (Simulator (Ok query)) ->
            query |> executeQuery db request toAllImpactsSimple

        Just (Simulator (Err errors)) ->
            Inputs.encodeQueryErrors errors
                |> sendResponse 400 request

        Just (SimulatorDetailed (Ok query)) ->
            query |> executeQuery db request Simulator.encode

        Just (SimulatorDetailed (Err errors)) ->
            Inputs.encodeQueryErrors errors
                |> sendResponse 400 request

        Just (SimulatorSingle trigram (Ok query)) ->
            query |> executeQuery db request (toSingleImpactSimple trigram)

        Just (SimulatorSingle _ (Err errors)) ->
            Inputs.encodeQueryErrors errors
                |> sendResponse 400 request

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
