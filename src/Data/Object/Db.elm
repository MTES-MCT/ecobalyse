module Data.Object.Db exposing
    ( Db
    , buildFromJson
    )

{-| Note: The Object database also holds examples for VeLi
-}

import Data.Example as Example exposing (Example)
import Data.Object.Query as Query exposing (Query)
import Result.Extra as RE


type alias Db =
    { examples : List (Example Query)
    }


buildFromJson : String -> String -> Result String Db
buildFromJson objectExamplesJson veliExamplesJson =
    Ok Db
        |> RE.andMap
            (Result.map2 (++)
                (objectExamplesJson
                    |> Example.decodeListFromJsonString Query.decode
                )
                (veliExamplesJson
                    |> Example.decodeListFromJsonString Query.decode
                )
            )
