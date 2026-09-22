module Data.Generic.Db exposing
    ( Db
    , buildFromJson
    )

{-| Note: The generic database holds examples all generic scopes
-}

import Data.Component as Component
import Data.Example as Example exposing (Example)
import Data.Process exposing (Process)
import Result.Extra as RE


type alias Db =
    { examples : List (Example Component.Query)
    }


buildFromJson : String -> String -> String -> List Process -> Result String Db
buildFromJson food2ExamplesJson objectExamplesJson veliExamplesJson processes =
    Ok Db
        |> RE.andMap
            (Result.map3 (\a b c -> a ++ b ++ c)
                (food2ExamplesJson
                    |> Example.decodeListFromJsonString (Component.decodeQuery processes)
                )
                (objectExamplesJson
                    |> Example.decodeListFromJsonString (Component.decodeQuery processes)
                )
                (veliExamplesJson
                    |> Example.decodeListFromJsonString (Component.decodeQuery processes)
                )
            )
