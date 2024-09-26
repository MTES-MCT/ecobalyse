module Data.Object.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Example as Example exposing (Example)
import Data.Impact as Impact
import Data.Object.Process as Process exposing (Process)
import Data.Object.Query as Query exposing (Query)
import Json.Decode as Decode
import Result.Extra as RE


type alias Db =
    { examples : List (Example Query)
    , processes : List Process
    }


buildFromJson : String -> String -> Result String Db
buildFromJson objectExamplesJson objectProcessesJson =
    objectProcessesJson
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Ok Db
                    |> RE.andMap
                        (objectExamplesJson
                            |> Example.decodeListFromJsonString Query.decode
                        )
                    |> RE.andMap (Ok processes)
            )
