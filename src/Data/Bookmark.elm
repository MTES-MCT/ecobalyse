module Data.Bookmark exposing
    ( Bookmark
    , Query(..)
    , decode
    , encode
    , isFood
    , isTextile
    )

import Data.Food.Builder.Query as FoodQuery
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
