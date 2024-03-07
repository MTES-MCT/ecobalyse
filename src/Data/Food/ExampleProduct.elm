module Data.Food.ExampleProduct exposing
    ( ExampleProduct
    , Uuid
    , decodeListFromJsonString
    , findByQuery
    , findByUuid
    , parseUuid
    , toCategory
    , toName
    , uuidFromString
    , uuidToString
    )

import Data.Food.Query as Query exposing (Query)
import Json.Decode as Decode exposing (Decoder)
import Url.Parser as Parser exposing (Parser)


type alias ExampleProduct =
    { id : Uuid
    , name : String
    , query : Query
    , category : String
    }


type Uuid
    = Uuid String


decode : Decoder ExampleProduct
decode =
    Decode.map4 ExampleProduct
        (Decode.field "id" (Decode.map Uuid Decode.string))
        (Decode.field "name" Decode.string)
        (Decode.field "query" Query.decode)
        (Decode.field "category" Decode.string)


decodeListFromJsonString : String -> Result String (List ExampleProduct)
decodeListFromJsonString =
    Decode.decodeString (Decode.list decode)
        >> Result.mapError Decode.errorToString


findByUuid : Uuid -> List ExampleProduct -> Result String ExampleProduct
findByUuid id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Exemple introuvable pour l'uuid " ++ uuidToString id)


findByQuery : Query -> List ExampleProduct -> Result String ExampleProduct
findByQuery query =
    List.filter (.query >> (==) query)
        >> List.head
        >> Result.fromMaybe "Exemple introuvable"


parseUuid : Parser (Uuid -> a) a
parseUuid =
    Parser.custom "FOODEXAMPLE" (uuidFromString >> Just)


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


uuidFromString : String -> Uuid
uuidFromString =
    Uuid


uuidToString : Uuid -> String
uuidToString (Uuid string) =
    string
