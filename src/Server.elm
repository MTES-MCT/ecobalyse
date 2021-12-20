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


parsePath : String -> Route
parsePath path =
    case path of
        "/" ->
            Home

        "/simulator/" ->
            Simulator

        "/simulator/all/" ->
            SimulatorAll

        _ ->
            NotFound


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


sendResponse : Int -> Encode.Value -> Encode.Value -> Cmd Msg
sendResponse httpStatus jsResponseHandler body =
    Encode.object
        [ ( "status", Encode.int httpStatus )
        , ( "body", body )
        , ( "jsResponseHandler", jsResponseHandler )
        ]
        |> output


encodeStringError : String -> Encode.Value
encodeStringError error =
    Encode.object
        [ ( "error", error |> String.lines |> Encode.list Encode.string )
        , ( "documentation", Encode.string "https://fabrique-numerique.gitbook.io/wikicarbone/api" )
        ]


toResponse : Encode.Value -> Result String Encode.Value -> Cmd Msg
toResponse jsResponseHandler encodedResult =
    case encodedResult of
        Ok encoded ->
            encoded |> sendResponse 200 jsResponseHandler

        Err error ->
            encodeStringError error |> sendResponse 400 jsResponseHandler


handleRequest : Result String Db -> Request -> Cmd Msg
handleRequest dbResult { expressPath, expressQuery, jsResponseHandler } =
    case parsePath expressPath of
        Home ->
            Encode.object [ ( "hello", Encode.string "world" ) ]
                |> sendResponse 200 jsResponseHandler

        Simulator ->
            case dbResult of
                Ok db ->
                    decodeQuery expressQuery
                        |> Result.andThen (Simulator.compute db >> Result.map Simulator.encode)
                        |> toResponse jsResponseHandler

                Err dbError ->
                    encodeStringError dbError
                        |> sendResponse 500 jsResponseHandler

        SimulatorAll ->
            case dbResult of
                Ok db ->
                    decodeQuery expressQuery
                        |> Result.andThen (Simulator.computeAll db >> Result.map Impact.encodeImpacts)
                        |> toResponse jsResponseHandler

                Err dbError ->
                    encodeStringError dbError
                        |> sendResponse 500 jsResponseHandler

        NotFound ->
            encodeStringError "Endpoint doesn't exist"
                |> sendResponse 404 jsResponseHandler


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Received request ->
            ( model, request |> handleRequest model.db )


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Received
        }


port input : (Request -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
