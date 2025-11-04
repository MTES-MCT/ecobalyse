module Data.Object.Query exposing
    ( Query
    , attemptUpdateComponents
    , buildApiQuery
    , updateComponents
    , updateDurability
    )

import Data.Component as Component exposing (Item)
import Data.Scope as Scope exposing (Scope)
import Data.Unit as Unit
import Json.Encode as Encode


type alias Query =
    Component.Query


{-| Update a list of component items that may fail
-}
attemptUpdateComponents : (List Item -> Result String (List Item)) -> Component.Query -> Result String Component.Query
attemptUpdateComponents fn query =
    fn query.items
        |> Result.map (\items -> { query | items = items })


buildApiQuery : Scope -> String -> Query -> String
buildApiQuery scope clientUrl query =
    """curl -sS -X POST %apiUrl% \\
  -H "accept: application/json" \\
  -H "content-type: application/json" \\
  -d '%json%'
"""
        |> String.replace "%apiUrl%" (clientUrl ++ "/api/" ++ Scope.toString scope ++ "/simulator")
        |> String.replace "%json%" (Component.encodeQuery query |> Encode.encode 0)


updateComponents : (List Item -> List Item) -> Query -> Query
updateComponents fn query =
    { query | items = fn query.items }


updateDurability : Unit.Ratio -> Query -> Query
updateDurability durability query =
    { query | durability = durability }
