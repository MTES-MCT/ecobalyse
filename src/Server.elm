port module Server exposing (main)

import Data.Country as Country
import Data.Db as Db exposing (Db)
import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Process as Process
import Data.Product as Product
import Data.Simulator as Simulator exposing (Simulator)
import Data.Unit as Unit
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Mass
import Url
import Url.Parser as Parser exposing ((</>), Parser)


type alias Flags =
    { jsonDb : String }


type alias Model =
    { db : Result String Db
    }


type Msg
    = Received Request


type alias Request =
    -- Notes:
    -- - `expressPath` is ExpressJS `path` string
    -- - `expressQuery` is ExpressJS `query` object representing query
    --   string params, which uses the qs package under the hood:
    --   https://www.npmjs.com/package/qs
    -- - `jsResponseHandler` is an ExpressJS response callback function
    { expressPath : String
    , expressQuery : Encode.Value
    , jsResponseHandler : Encode.Value
    }


type Route
    = Home
    | Simulator -- Simple version of all impacts
    | SimulatorDetailed -- Detailed version for all impacts
    | SimulatorSingle Impact.Trigram -- Simple version for one specific impact


init : Flags -> ( Model, Cmd Msg )
init { jsonDb } =
    ( { db = Db.buildFromJson jsonDb }
    , Cmd.none
    )


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Simulator (Parser.s "simulator")
        , Parser.map SimulatorDetailed (Parser.s "simulator" </> Parser.s "detailed")
        , Parser.map SimulatorSingle (Parser.s "simulator" </> Impact.parseTrigram)
        ]


parseRoute : String -> Maybe Route
parseRoute expressPath =
    Url.fromString ("http://x" ++ expressPath)
        |> Maybe.andThen (Parser.parse parser)


apiDocUrl : String
apiDocUrl =
    "https://wikicarbone.beta.gouv.fr/#/api"


expressQueryDecoder : Decoder Inputs.Query
expressQueryDecoder =
    let
        decodeStringFloat =
            Decode.string
                |> Decode.andThen
                    (String.toFloat
                        >> Result.fromMaybe "Valeur décimale invalide."
                        >> DecodeExtra.fromResult
                    )

        decodeMassString =
            decodeStringFloat
                |> Decode.andThen
                    (\float ->
                        if float <= 0 then
                            Decode.fail "La masse doit être strictement supérieure à zéro."

                        else
                            Decode.succeed (Mass.kilograms float)
                    )

        decodeCountries =
            Decode.string
                |> Decode.map Country.Code
                |> Decode.list
                |> Decode.andThen
                    (\countries ->
                        if List.length countries /= 5 then
                            Decode.fail "La liste de pays doit contenir 5 pays."

                        else
                            Decode.succeed countries
                    )

        decodeRatioString =
            decodeStringFloat
                |> Decode.andThen (Unit.validateRatio >> DecodeExtra.fromResult)

        decodeImpactString =
            decodeStringFloat
                |> Decode.andThen
                    (\float ->
                        if float < 0 then
                            Decode.fail "Un impact de mix énergétique ne peut être négatif."

                        else
                            Decode.succeed (Unit.impact float)
                    )
    in
    Decode.succeed Inputs.Query
        |> Pipe.required "mass" decodeMassString
        |> Pipe.required "material" (Decode.map Process.Uuid Decode.string)
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> Pipe.required "countries" decodeCountries
        |> Pipe.optional "dyeingWeighting" (Decode.map Just decodeRatioString) Nothing
        |> Pipe.optional "airTransportRatio" (Decode.map Just decodeRatioString) Nothing
        |> Pipe.optional "recycledRatio" (Decode.map Just decodeRatioString) Nothing
        |> Pipe.optional "customCountryMixes"
            (Decode.succeed Inputs.CustomCountryMixes
                |> Pipe.optional "fabric" (Decode.map Just decodeImpactString) Nothing
                |> Pipe.optional "dyeing" (Decode.map Just decodeImpactString) Nothing
                |> Pipe.optional "making" (Decode.map Just decodeImpactString) Nothing
            )
            Inputs.defaultCustomCountryMixes


decodeQuery : Encode.Value -> Result String Inputs.Query
decodeQuery =
    Decode.decodeValue expressQueryDecoder
        >> Result.mapError Decode.errorToString


sendResponse : Int -> Request -> Encode.Value -> Cmd Msg
sendResponse httpStatus { expressPath, expressQuery, jsResponseHandler } body =
    Encode.object
        [ ( "status", Encode.int httpStatus )
        , ( "path", Encode.string expressPath )
        , ( "query", expressQuery )
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
        [ ( "impact"
          , impacts
                |> Impact.filterImpacts (\trg _ -> trigram == trg)
                |> Impact.encodeImpacts
          )
        , ( "query", inputs |> Inputs.toQuery |> Inputs.encodeQuery )
        ]


executeQuery : Db -> (Simulator -> Encode.Value) -> Request -> Cmd Msg
executeQuery db fn request =
    decodeQuery request.expressQuery
        |> Result.andThen (Simulator.compute db >> Result.map fn)
        |> toResponse request


handleRequest : Db -> Request -> Cmd Msg
handleRequest db ({ expressPath } as request) =
    case parseRoute expressPath of
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

        Just Simulator ->
            request
                |> executeQuery db toAllImpactsSimple

        Just SimulatorDetailed ->
            request
                |> executeQuery db Simulator.encode

        Just (SimulatorSingle trigram) ->
            request
                |> executeQuery db (toSingleImpactSimple trigram)

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
                    , encodeStringError dbError |> sendResponse 500 request
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
