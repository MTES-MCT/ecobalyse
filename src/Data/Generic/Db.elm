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


buildFromJson : List Process -> List String -> Result String Db
buildFromJson processes examplesJson =
    examplesJson
        |> RE.combineMap
            (Example.decodeListFromJsonString <|
                Component.decodeQuery processes
            )
        |> Result.map (List.concat >> Db)
