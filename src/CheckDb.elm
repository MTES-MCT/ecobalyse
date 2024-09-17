port module CheckDb exposing (main)

import Static.Db as StaticDb
import Static.Json as StaticJson


type alias Flags =
    { foodProcesses : String
    , textileProcesses : String
    }


checkDbs : Flags -> Result String StaticDb.Db
checkDbs detailedRawProcessesJson =
    StaticDb.db StaticJson.rawJsonProcesses
        |> Result.mapError (\err -> "Non-detailed Db is invalid: " ++ err)
        |> Result.andThen
            (StaticDb.db detailedRawProcessesJson
                |> Result.mapError (\err -> "Detailed Db is invalid: " ++ err)
                |> always
            )


main : Program Flags () ()
main =
    Platform.worker
        { init =
            \flags ->
                ( ()
                , case checkDbs flags of
                    Err error ->
                        logAndExit { message = "Db is dubious: " ++ error, status = 1 }

                    Ok _ ->
                        logAndExit { message = "Db is fine", status = 0 }
                )
        , subscriptions = always Sub.none
        , update = \_ _ -> ( (), Cmd.none )
        }


port logAndExit : { message : String, status : Int } -> Cmd msg
