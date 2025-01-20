module Data.Object.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Component as Component exposing (Component)
import Data.Example as Example exposing (Example)
import Data.Impact as Impact
import Data.Object.Query as Query exposing (Query)
import Data.Process as Process exposing (Process)
import Data.Scope as Scope
import Json.Decode as Decode
import Result.Extra as RE


type alias Db =
    { components : List Component
    , examples : List (Example Query)
    , processes : List Process
    }


buildFromJson : String -> String -> String -> Result String Db
buildFromJson objectComponentsJson objectExamplesJson objectProcessesJson =
    objectProcessesJson
        |> Decode.decodeString (Process.decodeList [ Scope.Object, Scope.Veli ] Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Ok Db
                    |> RE.andMap (Component.decodeListFromJsonString objectComponentsJson)
                    |> RE.andMap
                        (objectExamplesJson
                            |> Example.decodeListFromJsonString Query.decode
                        )
                    |> RE.andMap (Ok processes)
            )
