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


buildFromJson : String -> String -> String -> Result String Db
buildFromJson food2ExamplesJson objectExamplesJson veliExamplesJson =
    Ok Db
        |> RE.andMap
            (Result.map3 (\a b c -> a ++ b ++ c)
                (food2ExamplesJson
                    |> Example.decodeListFromJsonString Component.decodeQuery
                )
                (objectExamplesJson
                    |> Example.decodeListFromJsonString Component.decodeQuery
                )
                (veliExamplesJson
                    |> Example.decodeListFromJsonString Component.decodeQuery
                )
            )
