module Data.Bookmark exposing
    ( Bookmark
    , Query(..)
    , decode
    , encode
    , findByFoodQuery
    , findByObjectQuery
    , findByTextileQuery
    , isFood
    , isObject
    , isTextile
    , sort
    , toId
    , toQueryDescription
    )

import Data.Food.Query as FoodQuery
import Data.Food.Recipe as Recipe
import Data.Object.Query as ObjectQuery
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Inputs as Inputs
import Data.Textile.Query as TextileQuery
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Static.Db exposing (Db)
import Time exposing (Posix)


type alias Bookmark =
    { created : Posix
    , name : String
    , query : Query
    }


type Query
    = Food FoodQuery.Query
    | Object ObjectQuery.Query
    | Textile TextileQuery.Query


decode : Decoder Bookmark
decode =
    Decode.map3 Bookmark
        (Decode.field "created" (Decode.map Time.millisToPosix Decode.int))
        (Decode.field "name" Decode.string)
        (Decode.field "query" decodeQuery)


decodeQuery : Decoder Query
decodeQuery =
    Decode.oneOf
        [ Decode.map Food FoodQuery.decode
        , Decode.map Object ObjectQuery.decode
        , Decode.map Textile TextileQuery.decode
        ]


encode : Bookmark -> Encode.Value
encode v =
    Encode.object
        [ ( "created", Encode.int <| Time.posixToMillis v.created )
        , ( "name", Encode.string v.name )
        , ( "query", encodeQuery v.query )
        ]


encodeQuery : Query -> Encode.Value
encodeQuery v =
    case v of
        Food query ->
            FoodQuery.encode query

        Object query ->
            ObjectQuery.encode query

        Textile query ->
            TextileQuery.encode query


isFood : Bookmark -> Bool
isFood { query } =
    case query of
        Food _ ->
            True

        _ ->
            False


isObject : Bookmark -> Bool
isObject { query } =
    case query of
        Object _ ->
            True

        _ ->
            False


isTextile : Bookmark -> Bool
isTextile { query } =
    case query of
        Textile _ ->
            True

        _ ->
            False


findByQuery : Query -> List Bookmark -> Maybe Bookmark
findByQuery query =
    List.filter (.query >> (==) query)
        >> List.head


findByFoodQuery : FoodQuery.Query -> List Bookmark -> Maybe Bookmark
findByFoodQuery foodQuery =
    findByQuery (Food foodQuery)


findByObjectQuery : ObjectQuery.Query -> List Bookmark -> Maybe Bookmark
findByObjectQuery objectQuery =
    findByQuery (Object objectQuery)


findByTextileQuery : TextileQuery.Query -> List Bookmark -> Maybe Bookmark
findByTextileQuery textileQuery =
    findByQuery (Textile textileQuery)


scope : Bookmark -> Scope
scope bookmark =
    case bookmark.query of
        Food _ ->
            Scope.Food

        Object _ ->
            Scope.Object

        Textile _ ->
            Scope.Textile


sort : List Bookmark -> List Bookmark
sort =
    List.sortBy (.created >> Time.posixToMillis) >> List.reverse


toId : Bookmark -> String
toId bookmark =
    Scope.toString (scope bookmark) ++ ":" ++ bookmark.name


toQueryDescription : Db -> Bookmark -> String
toQueryDescription db bookmark =
    case bookmark.query of
        Food foodQuery ->
            foodQuery
                |> Recipe.fromQuery db
                |> Result.map Recipe.toString
                |> Result.withDefault bookmark.name

        Object objectQuery ->
            objectQuery
                |> ObjectQuery.toString db.object.processes
                |> Result.withDefault "N/A"

        Textile textileQuery ->
            textileQuery
                |> Inputs.fromQuery db
                |> Result.map Inputs.toString
                |> Result.withDefault bookmark.name
