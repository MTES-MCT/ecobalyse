module Data.Bookmark exposing
    ( Bookmark
    , Query(..)
    , decode
    , encode
    , findForFood
    , isFood
    , isTextile
    , toQueryDescription
    )

import Data.Food.Builder.Db as BuilderDb
import Data.Food.Builder.Query as FoodQuery
import Data.Food.Builder.Recipe as Recipe
import Data.Textile.Db as TextileDb
import Data.Textile.Inputs as TextileQuery
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Time exposing (Posix)


type alias Bookmark =
    { name : String
    , created : Posix
    , query : Query
    }


type Query
    = Food FoodQuery.Query
    | Textile TextileQuery.Query


decode : Decoder Bookmark
decode =
    Decode.map3 Bookmark
        (Decode.field "name" Decode.string)
        (Decode.field "created" (Decode.map Time.millisToPosix Decode.int))
        (Decode.field "query" decodeQuery)


decodeQuery : Decoder Query
decodeQuery =
    Decode.oneOf
        [ Decode.map Food FoodQuery.decode
        , Decode.map Textile TextileQuery.decodeQuery
        ]


encode : Bookmark -> Encode.Value
encode v =
    Encode.object
        [ ( "name", Encode.string v.name )
        , ( "created", Encode.int <| Time.posixToMillis v.created )
        , ( "query", encodeQuery v.query )
        ]


encodeQuery : Query -> Encode.Value
encodeQuery v =
    case v of
        Food query ->
            FoodQuery.encode query

        Textile query ->
            TextileQuery.encodeQuery query


isFood : Bookmark -> Bool
isFood { query } =
    case query of
        Food _ ->
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


findByQuery : (Bookmark -> Bool) -> Query -> List Bookmark -> Maybe Bookmark
findByQuery filter query =
    List.filter filter
        >> List.filter (.query >> (==) query)
        >> List.head


findForFood : FoodQuery.Query -> List Bookmark -> Maybe Bookmark
findForFood foodQuery =
    findByQuery isFood (Food foodQuery)


toQueryDescription : { foodDb : BuilderDb.Db, textileDb : TextileDb.Db } -> Bookmark -> String
toQueryDescription { foodDb, textileDb } bookmark =
    case bookmark.query of
        Food foodQuery ->
            foodQuery
                |> Recipe.fromQuery foodDb
                |> Result.map Recipe.toString
                |> Result.withDefault bookmark.name

        Textile textileQuery ->
            textileQuery
                |> TextileQuery.fromQuery textileDb
                |> Result.map TextileQuery.toString
                |> Result.withDefault bookmark.name
