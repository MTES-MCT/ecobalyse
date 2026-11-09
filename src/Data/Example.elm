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

import Data.Common.DecodeUtils as DU
import Data.Sector as Scope exposing (Scope)
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import List.Extra as LE
import Url.Parser as Parser exposing (Parser)


type alias Example query =
    { category : String
    , id : Uuid
    , name : String
    , query : query
    , recyclable : Bool
    , scope : Scope
    }


decode : Decoder query -> Decoder (Example query)
decode decodeQuery =
    Decode.succeed Example
        |> Pipe.required "category" Decode.string
        |> Pipe.required "id" Uuid.decoder
        |> Pipe.required "name" Decode.string
        |> Pipe.required "query" decodeQuery
        -- By default, if not specified, everything is recyclable
        |> DU.strictOptionalWithDefault "recyclable" Decode.bool True
        |> Pipe.required "scope" Scope.decode


decodeListFromJsonString : Decoder query -> String -> Result String (List (Example query))
decodeListFromJsonString decodeQuery =
    Decode.decodeString (Decode.list (decode decodeQuery))
        >> Result.mapError Decode.errorToString


findByName : String -> List (Example query) -> Result String (Example query)
findByName name =
    LE.find (.name >> (==) name)
        >> Result.fromMaybe ("Exemple introuvable avec le nom " ++ name)


findByUuid : Uuid -> List (Example query) -> Result String (Example query)
findByUuid id =
    LE.find (.id >> (==) id)
        >> Result.fromMaybe ("Exemple introuvable pour l'uuid " ++ Uuid.toString id)


findByQuery : query -> List (Example query) -> Result String (Example query)
findByQuery query =
    LE.find (.query >> (==) query)
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
