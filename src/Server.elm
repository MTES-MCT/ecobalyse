port module Server exposing (main)

import Data.Db as Db exposing (Db)
import Data.Inputs as Inputs
import Data.Simulator as Simulator exposing (Simulator)
import Json.Decode as Decode
import Json.Encode as Encode


type alias Flags =
    { jsonDb : String }


type alias Model =
    { db : Result String Db }


type Msg
    = Received { inputs : Encode.Value, jsResponseHandler : Encode.Value }


init : Flags -> ( Model, Cmd Msg )
init { jsonDb } =
    ( { db = Db.buildFromJson jsonDb }
    , Cmd.none
    )


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
        ( Received { inputs, jsResponseHandler }, Ok db ) ->
            ( model
            , inputs
                |> Decode.decodeValue Inputs.decodeQuery
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


port input : ({ inputs : Encode.Value, jsResponseHandler : Encode.Value } -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
