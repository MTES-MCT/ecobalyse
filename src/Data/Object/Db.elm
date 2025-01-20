module Data.Object.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Component as Component exposing (Component)
import Data.Example as Example exposing (Example)
import Data.Object.Query as Query exposing (Query)
import Result.Extra as RE


type alias Db =
    { components : List Component
    , examples : List (Example Query)
    }


buildFromJson : String -> String -> Result String Db
buildFromJson objectComponentsJson objectExamplesJson =
    Ok Db
        |> RE.andMap (Component.decodeListFromJsonString objectComponentsJson)
        |> RE.andMap
            (objectExamplesJson
                |> Example.decodeListFromJsonString Query.decode
            )
