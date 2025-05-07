port module CheckDb exposing (main)

import Static.Db as StaticDb exposing (Db)


type alias Flags =
    { processes : String
    }


init : Flags -> ( (), Cmd () )
init flags =
    ( ()
    , case checkStaticDatabases flags of
        Err error ->
            logAndExit { message = error, status = 1 }

        Ok _ ->
            logAndExit { message = "Dbs look fine", status = 0 }
    )


checkStaticDatabases : Flags -> Result String ( Db, Db )
checkStaticDatabases { processes } =
    Result.map2 Tuple.pair
        (StaticDb.db processes
            |> Result.mapError (\err -> "Non-detailed Db is invalid: " ++ err)
        )
        (StaticDb.db processes
            |> Result.mapError (\err -> "Detailed Db is invalid: " ++ err)
        )


main : Program Flags () ()
main =
    Platform.worker
        { init = init
        , subscriptions = always Sub.none
        , update = \_ _ -> ( (), Cmd.none )
        }


port logAndExit : { message : String, status : Int } -> Cmd msg
