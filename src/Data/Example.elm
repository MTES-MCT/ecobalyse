module Data.Example exposing
    ( Example
    , decodeListFromJsonString
    , findByName
    , findByQuery
    , findByUuid
    , forScope
    , parseUuid
    , toCategory
    , toName
    , toSearchableString
    )

import Data.Scope as Scope exposing (Scope)
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Url.Parser as Parser exposing (Parser)


type alias Example query =
    { category : String
    , id : Uuid
    , name : String
    , query : query
    , scope : Scope
    }


decode : Decoder query -> Decoder (Example query)
decode decodeQuery =
    Decode.map5 Example
        (Decode.field "category" Decode.string)
        (Decode.field "id" Uuid.decoder)
        (Decode.field "name" Decode.string)
        (Decode.field "query" decodeQuery)
        (Decode.field "scope" Scope.decode)


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


forScope : Scope -> List (Example query) -> List (Example query)
forScope scope =
    List.filter (.scope >> (==) scope)


parseUuid : Parser (Uuid -> a) a
parseUuid =
    Parser.custom "EXAMPLE" (Uuid.fromString >> Result.toMaybe)


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


toSearchableString : Example query -> String
toSearchableString example =
    String.join " "
        [ example.id |> Uuid.toString
        , example.name
        , example.scope |> Scope.toString
        ]
