port module DumpPresets exposing (..)

import Data.Db as Db
import Data.Impact as Impact
import Data.Inputs as Inputs
import Data.Simulator as Simulator
import Json.Encode as Encode
import Result.Extra as RE


type alias Flags =
    { jsonDb : String }


init : Flags -> ( (), Cmd msg )
init { jsonDb } =
    let
        results =
            jsonDb
                |> Db.buildFromJson
                |> Result.andThen
                    (\db ->
                        Inputs.presets Impact.defaultTrigram
                            |> List.map (Simulator.compute db)
                            |> RE.combine
                    )
    in
    ( ()
    , case results of
        Ok results_ ->
            results_
                |> Encode.list Simulator.encode
                |> output

        Err error ->
            Encode.object [ ( "error", Encode.string error ) ]
                |> output
    )


main : Program Flags () msg
main =
    Platform.worker
        { init = init
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


port output : Encode.Value -> Cmd msg
