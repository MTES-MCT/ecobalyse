module Data.Object.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Example as Example exposing (Example)
import Data.Object.Query as Query exposing (Query)
import Result.Extra as RE


type alias Db =
    { examples : List (Example Query)
    }


buildFromJson : String -> Result String Db
buildFromJson objectExamplesJson =
    Ok Db
        |> RE.andMap
            (objectExamplesJson
                |> Example.decodeListFromJsonString Query.decode
            )
