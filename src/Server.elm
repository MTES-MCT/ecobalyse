port module Server exposing (main)

import Data.Co2 as Co2
import Data.Db as Db
import Data.Inputs as Inputs
import Data.Simulator as Simulator
import Json.Decode as Decode
import Json.Encode as Encode


type alias Flags =
    {}


type alias Model =
    {}


type Msg
    = Received String


init : Flags -> ( Model, Cmd Msg )
init _ =
    -- TODO: pass json string as a flag, parse to init Db, store Db result in model
    --       alternative: generate static Db elm module as we do for tests -> mutualize
    ( {}
    , Cmd.none
    )


toResponse : Result String Float -> Cmd Msg
toResponse result =
    case result of
        Ok score ->
            Encode.object [ ( "score", Encode.float score ) ] |> output

        Err error ->
            Encode.object [ ( "error", Encode.string error ) ] |> output


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Received json ->
            ( model
            , json
                |> Decode.decodeString Inputs.decodeQuery
                |> Result.mapError Decode.errorToString
                -- FIXME: Db should be loaded at this point
                |> Result.andThen (Simulator.compute Db.empty)
                |> Result.map (.co2 >> Co2.inKgCo2e)
                |> toResponse
            )


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Received
        }


port input : (String -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
