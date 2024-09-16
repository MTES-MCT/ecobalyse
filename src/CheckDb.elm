port module CheckDb exposing (main)

import Static.Db as StaticDb


type alias Flags =
    { foodProcesses : String
    , textileProcesses : String
    }


main : Program Flags () ()
main =
    Platform.worker
        { init =
            \flags ->
                ( ()
                , case StaticDb.db flags of
                    Err error ->
                        logAndExit { message = "Db is dubious: " ++ error, status = 1 }

                    Ok _ ->
                        logAndExit { message = "Db is fine", status = 0 }
                )
        , subscriptions = always Sub.none
        , update = \_ _ -> ( (), Cmd.none )
        }


port logAndExit : { message : String, status : Int } -> Cmd msg
