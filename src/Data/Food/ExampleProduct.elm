module Data.Food.ExampleProduct exposing
    ( ExampleProduct
    , decodeListFromJsonString
    , findByName
    , toCategory
    , toName
    )

import Data.Food.Query as Query exposing (Query)
import Json.Decode as Decode exposing (Decoder)


type alias ExampleProduct =
    { name : String
    , query : Query
    , category : String
    }


decode : Decoder ExampleProduct
decode =
    Decode.map3 ExampleProduct
        (Decode.field "name" Decode.string)
        (Decode.field "query" Query.decode)
        (Decode.field "category" Decode.string)


decodeListFromJsonString : String -> Result String (List ExampleProduct)
decodeListFromJsonString =
    Decode.decodeString (Decode.list decode)
        >> Result.mapError Decode.errorToString


findByName : String -> List ExampleProduct -> Result String ExampleProduct
findByName name =
    List.filter (.name >> (==) name)
        >> List.head
        >> Result.fromMaybe ("Exemple introuvable: " ++ name)


toCategory : List ExampleProduct -> Query -> String
toCategory examples q =
    examples
        |> List.filterMap
            (\{ category, query } ->
                if q == query then
                    Just category

                else
                    Nothing
            )
        |> List.head
        |> Maybe.withDefault ""


toName : List ExampleProduct -> Query -> String
toName examples q =
    examples
        |> List.filterMap
            (\{ name, query } ->
                if q == query then
                    Just name

                else
                    Nothing
            )
        |> List.head
        |> Maybe.withDefault "Produit personnalisé"
