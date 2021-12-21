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


type alias Flags =
    { jsonDb : String }


type alias Model =
    { db : Result String Db
    }


type Route
    = Home
    | Simulator
    | SimulatorAll
    | NotFound


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


type Msg
    = Received Request


init : Flags -> ( Model, Cmd Msg )
init { jsonDb } =
    ( { db = Db.buildFromJson jsonDb }
    , Cmd.none
    )


parseRoute : String -> Route
parseRoute path =
    case path of
        "/" ->
            Home

        "/simulator/" ->
            Simulator

        "/simulator/all/" ->
            SimulatorAll

        _ ->
            NotFound


routeToString : Route -> Maybe String
routeToString route =
    case route of
        Home ->
            Just "/"

        Simulator ->
            Just "/simulator/"

        SimulatorAll ->
            Just "/simulator/all/"

        NotFound ->
            Nothing


routes : List Route
routes =
    [ Home
    , Simulator
    , SimulatorAll
    , NotFound
    ]


apiDocUrl : String
apiDocUrl =
    "https://fabrique-numerique.gitbook.io/wikicarbone/api"


expressQueryDecoder : Decoder Inputs.Query
expressQueryDecoder =
    let
        decodeStringFloat =
            Decode.string
                |> Decode.andThen
                    (String.toFloat
                        >> Result.fromMaybe "Invalid float"
                        >> DecodeExtra.fromResult
                    )

        decodeMaybeUnit =
            decodeStringFloat
                |> Decode.map Unit.impactFromFloat
                |> Decode.maybe
    in
    Decode.succeed Inputs.Query
        |> Pipe.optional "impact" Impact.decodeTrigram (Impact.trg "cch")
        |> Pipe.required "mass" (decodeStringFloat |> Decode.map Mass.kilograms)
        |> Pipe.required "material" (Decode.map Process.Uuid Decode.string)
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> Pipe.required "countries" (Decode.list (Decode.map Country.Code Decode.string))
        |> Pipe.optional "dyeingWeighting" (Decode.maybe decodeStringFloat) Nothing
        |> Pipe.optional "airTransportRatio" (Decode.maybe decodeStringFloat) Nothing
        |> Pipe.optional "recycledRatio" (Decode.maybe decodeStringFloat) Nothing
        |> Pipe.optional "customCountryMixes"
            (Decode.succeed Inputs.CustomCountryMixes
                |> Pipe.optional "fabric" decodeMaybeUnit Nothing
                |> Pipe.optional "dyeing" decodeMaybeUnit Nothing
                |> Pipe.optional "making" decodeMaybeUnit Nothing
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


handleRequest : Db -> Request -> Cmd Msg
handleRequest db ({ expressPath, expressQuery } as request) =
    case parseRoute expressPath of
        Home ->
            Encode.object
                [ ( "service", Encode.string "Wikicarbone" )
                , ( "documentation", Encode.string apiDocUrl )
                , ( "endpoints", routes |> List.filterMap routeToString |> Encode.list Encode.string )
                ]
                |> sendResponse 200 request

        Simulator ->
            decodeQuery expressQuery
                |> Result.andThen (Simulator.compute db >> Result.map Simulator.encode)
                |> toResponse request

        SimulatorAll ->
            decodeQuery expressQuery
                |> Result.andThen (Simulator.computeAll db >> Result.map Impact.encodeImpacts)
                |> toResponse request

        NotFound ->
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
