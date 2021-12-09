port module Server exposing (main)

import Data.Country as Country
import Data.Db as Db exposing (Db)
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


type alias Request =
    -- Note: `expressQuery` is ExpressJS `query` object representing query string params
    --       It uses the qs package under the hood: https://www.npmjs.com/package/qs
    { expressQuery : Encode.Value
    , jsResponseHandler : Encode.Value
    }


type Msg
    = Received Request


init : Flags -> ( Model, Cmd Msg )
init { jsonDb } =
    ( { db = Db.buildFromJson jsonDb }
    , Cmd.none
    )


decodeExpressQuery : Decoder Inputs.Query
decodeExpressQuery =
    let
        decodeStringFloat =
            Decode.string
                |> Decode.andThen
                    (String.toFloat
                        >> Result.fromMaybe "Invalid float"
                        >> DecodeExtra.fromResult
                    )
    in
    Decode.succeed Inputs.Query
        |> Pipe.required "mass" (decodeStringFloat |> Decode.map Mass.kilograms)
        |> Pipe.required "material" (Decode.map Process.Uuid Decode.string)
        |> Pipe.required "product" (Decode.map Product.Id Decode.string)
        |> Pipe.required "countries" (Decode.list (Decode.map Country.Code Decode.string))
        |> Pipe.optional "dyeingWeighting" (Decode.maybe decodeStringFloat) Nothing
        |> Pipe.optional "airTransportRatio" (Decode.maybe decodeStringFloat) Nothing
        |> Pipe.optional "recycledRatio" (Decode.maybe decodeStringFloat) Nothing
        |> Pipe.optional "customCountryMixes"
            (Decode.succeed Inputs.CustomCountryMixes
                |> Pipe.optional "fabric" (Decode.maybe (decodeStringFloat |> Decode.map Unit.kgCo2e)) Nothing
                |> Pipe.optional "dyeing" (Decode.maybe (decodeStringFloat |> Decode.map Unit.kgCo2e)) Nothing
                |> Pipe.optional "making" (Decode.maybe (decodeStringFloat |> Decode.map Unit.kgCo2e)) Nothing
            )
            Inputs.defaultCustomCountryMixes


sendResponse : Int -> Encode.Value -> Encode.Value -> Cmd Msg
sendResponse httpStatus jsResponseHandler body =
    Encode.object
        [ ( "status", Encode.int httpStatus )
        , ( "body", body )
        , ( "jsResponseHandler", jsResponseHandler )
        ]
        |> output


toResponse : Encode.Value -> Result String Simulator -> Cmd Msg
toResponse jsResponseHandler result =
    case result of
        Ok simulator ->
            simulator
                |> Simulator.encode
                |> sendResponse 200 jsResponseHandler

        Err error ->
            Encode.object [ ( "error", Encode.string error ) ]
                |> sendResponse 400 jsResponseHandler


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.db ) of
        ( Received { expressQuery, jsResponseHandler }, Ok db ) ->
            ( model
            , expressQuery
                |> Decode.decodeValue decodeExpressQuery
                |> Result.mapError Decode.errorToString
                |> Result.andThen (Simulator.compute db)
                |> toResponse jsResponseHandler
            )

        ( Received { jsResponseHandler }, Err error ) ->
            ( model
            , Err error |> toResponse jsResponseHandler
            )


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Received
        }


port input : (Request -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
