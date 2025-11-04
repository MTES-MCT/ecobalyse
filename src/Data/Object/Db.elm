module Data.Object.Db exposing
    ( Db
    , buildFromJson
    )

{-| Note: The Object database also holds examples for VeLi
-}

import Data.Component as Component
import Data.Example as Example exposing (Example)
import Result.Extra as RE


type alias Db =
    { examples : List (Example Component.Query)
    }


buildFromJson : String -> String -> Result String Db
buildFromJson objectExamplesJson veliExamplesJson =
    Ok Db
        |> RE.andMap
            (Result.map2 (++)
                (objectExamplesJson
                    |> Example.decodeListFromJsonString Component.decodeQuery
                )
                (veliExamplesJson
                    |> Example.decodeListFromJsonString Component.decodeQuery
                )
            )
