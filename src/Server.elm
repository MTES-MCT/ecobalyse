port module Server exposing (main)

import Data.Co2 as Co2
import Data.Db as Db exposing (Db)
import Data.Inputs as Inputs
import Data.Simulator as Simulator
import Json.Decode as Decode
import Json.Encode as Encode


type alias Flags =
    { jsonDb : String }


type alias Model =
    { db : Result String Db }


type Msg
    = Received { inputs : Encode.Value, fn : Encode.Value }


init : Flags -> ( Model, Cmd Msg )
init { jsonDb } =
    -- TODO: pass json string as a flag, parse to init Db, store Db result in model
    --       alternative: generate static Db elm module as we do for tests -> mutualize
    ( { db = Db.buildFromJson jsonDb }
    , Cmd.none
    )


toResponse : Encode.Value -> Result String Float -> Cmd Msg
toResponse fn result =
    case result of
        Ok score ->
            Encode.object
                [ ( "score", Encode.float score )
                , ( "fn", fn )
                ]
                |> output

        Err error ->
            Encode.object
                [ ( "error", Encode.string error )
                , ( "fn", fn )
                ]
                |> output


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.db ) of
        ( Received { inputs, fn }, Ok db ) ->
            ( model
            , inputs
                |> Decode.decodeValue Inputs.decodeQuery
                |> Result.mapError Decode.errorToString
                |> Result.andThen (Simulator.compute db)
                |> Result.map (.co2 >> Co2.inKgCo2e)
                |> toResponse fn
            )

        ( _, Err error ) ->
            ( model
            , Cmd.none
            )


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Received
        }


port input : ({ inputs : Encode.Value, fn : Encode.Value } -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
