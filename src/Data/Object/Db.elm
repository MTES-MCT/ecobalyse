module Data.Object.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Impact as Impact
import Data.Object.Process as Process exposing (Process)
import Json.Decode as Decode
import Result.Extra as RE


type alias Db =
    { processes : List Process }


buildFromJson : String -> Result String Db
buildFromJson objectProcessesJson =
    objectProcessesJson
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Ok Db
                    -- FIXME: add more stuff to Db, eg. examples
                    |> RE.andMap (Ok processes)
            )
