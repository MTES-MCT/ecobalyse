module Data.Example exposing
    ( Example
    , decodeListFromJsonString
    , findByName
    , findByQuery
    , findByUuid
    , parseUuid
    , toCategory
    , toName
    )

import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Url.Parser as Parser exposing (Parser)


type alias Example query =
    { id : Uuid
    , name : String
    , category : String
    , query : query
    }


decode : Decoder query -> Decoder (Example query)
decode decodeQuery =
    Decode.map4 Example
        (Decode.field "id" Uuid.decoder)
        (Decode.field "name" Decode.string)
        (Decode.field "category" Decode.string)
        (Decode.field "query" decodeQuery)


decodeListFromJsonString : Decoder query -> String -> Result String (List (Example query))
decodeListFromJsonString decodeQuery =
    Decode.decodeString (Decode.list (decode decodeQuery))
        >> Result.mapError Decode.errorToString


findByName : String -> List (Example query) -> Result String (Example query)
findByName name =
    List.filter (.name >> (==) name)
        >> List.head
        >> Result.fromMaybe ("Exemple introuvable avec le nom " ++ name)


findByUuid : Uuid -> List (Example query) -> Result String (Example query)
findByUuid id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Exemple introuvable pour l'uuid " ++ Uuid.toString id)


findByQuery : query -> List (Example query) -> Result String (Example query)
findByQuery query =
    List.filter (.query >> (==) query)
        >> List.head
        >> Result.fromMaybe "Exemple introuvable"


parseUuid : Parser (Uuid -> a) a
parseUuid =
    Parser.custom "EXAMPLE" Uuid.fromString


toCategory : List (Example query) -> query -> String
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


toName : List (Example query) -> query -> String
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
