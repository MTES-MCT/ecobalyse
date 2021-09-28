port module Server exposing (main)

import Data.Inputs as Inputs
import Data.Simulator as Simulator
import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    ()


type Msg
    = Received Decode.Value


init : () -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )


toResponse : Result Decode.Error Float -> Cmd Msg
toResponse result =
    case result of
        Ok score ->
            Encode.object [ ( "score", Encode.float score ) ] |> output

        Err error ->
            Encode.object [ ( "error", error |> Decode.errorToString |> Encode.string ) ] |> output


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Received json ->
            ( model
            , json
                |> Decode.decodeValue Inputs.decodeQuery
                |> Result.map (Inputs.fromQuery >> Simulator.compute >> .co2)
                |> toResponse
            )


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = \_ -> input Received
        }


port input : (Decode.Value -> msg) -> Sub msg


port output : Encode.Value -> Cmd msg
