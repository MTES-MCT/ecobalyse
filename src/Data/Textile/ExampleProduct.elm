module Data.Textile.ExampleProduct exposing
    ( ExampleProduct
    , decodeListFromJsonString
    , toCategory
    , toString
    )

import Data.Textile.Inputs as Inputs exposing (Query)
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
        (Decode.field "query" Inputs.decodeQuery)
        (Decode.field "category" Decode.string)


decodeListFromJsonString : String -> Result String (List ExampleProduct)
decodeListFromJsonString =
    Decode.decodeString (Decode.list decode)
        >> Result.mapError Decode.errorToString



-- These will likely be useful in a near future
-- encode : ExampleProduct -> Encode.Value
-- encode { name, query, category } =
--     Encode.object
--         [ ( "name", Encode.string name )
--         , ( "query", Query.encode query )
--         , ( "category", Encode.string category )
--         ]
-- encodeList : List ExampleProduct -> Encode.Value
-- encodeList =
--     Encode.list encode


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


toString : List ExampleProduct -> Query -> String
toString examples q =
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
