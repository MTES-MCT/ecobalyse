module Data.Bookmark exposing
    ( Bookmark
    , Query(..)
    , decodeJsonList
    , encodeJsonList
    , findByFoodQuery
    , findByObjectQuery
    , findByTextileQuery
    , isFood
    , isObject
    , isTextile
    , isVeli
    , replace
    , sort
    , toId
    , toQueryDescription
    )

import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Component as Component
import Data.Food.Query as FoodQuery
import Data.Food.Recipe as Recipe
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Inputs as Inputs
import Data.Textile.Query as TextileQuery
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import List.Extra as LE
import Static.Db exposing (Db)
import Time exposing (Posix)


type alias Bookmark =
    { created : Posix
    , name : String
    , query : Query
    , subScope : Maybe Scope
    }


type Query
    = Food FoodQuery.Query
    | Object Component.Query
    | Textile TextileQuery.Query
    | Veli Component.Query


decode : Decoder Bookmark
decode =
    Decode.succeed Bookmark
        |> JDP.required "created" (Decode.map Time.millisToPosix Decode.int)
        |> JDP.required "name" Decode.string
        |> JDP.required "query" decodeQuery
        |> DU.strictOptionalWithDefault "subScope" (Decode.maybe Scope.decode) Nothing
        |> Decode.map
            (\bookmark ->
                case ( bookmark.query, bookmark.subScope ) of
                    ( Object q, Just Scope.Veli ) ->
                        { bookmark | query = Veli q }

                    _ ->
                        bookmark
            )


decodeJsonList : Decoder (List Bookmark)
decodeJsonList =
    Decode.list
        (Decode.oneOf
            [ -- raw json string
              decodeJsonBookmark

            -- well formed and valid bookmark object
            , Decode.map Just decode

            -- invalid json data structure
            , Decode.succeed Nothing
            ]
        )
        |> Decode.map (List.filterMap identity)


decodeJsonBookmark : Decoder (Maybe Bookmark)
decodeJsonBookmark =
    Decode.string
        |> Decode.map (Decode.decodeString decode >> Result.toMaybe)


decodeQuery : Decoder Query
decodeQuery =
    Decode.oneOf
        [ Decode.map Food FoodQuery.decode
        , Decode.map Object Component.decodeQuery
        , Decode.map Textile TextileQuery.decode
        ]


encode : Bookmark -> Encode.Value
encode v =
    EU.optionalPropertiesObject
        [ ( "created", v.created |> Time.posixToMillis |> Encode.int |> Just )
        , ( "name", Encode.string v.name |> Just )
        , ( "query", encodeQuery v.query |> Just )
        , ( "subScope", v.subScope |> Maybe.map Scope.encode )
        ]


encodeJsonList : List Bookmark -> Encode.Value
encodeJsonList =
    Encode.list (encode >> Encode.encode 0 >> Encode.string)


encodeQuery : Query -> Encode.Value
encodeQuery v =
    case v of
        Food query ->
            FoodQuery.encode query

        Object query ->
            Component.encodeQuery query

        Textile query ->
            TextileQuery.encode query

        Veli query ->
            Component.encodeQuery query


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


isVeli : Bookmark -> Bool
isVeli { query } =
    case query of
        Veli _ ->
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


findByObjectQuery : Component.Query -> List Bookmark -> Maybe Bookmark
findByObjectQuery objectQuery =
    findByQuery (Object objectQuery)


findByTextileQuery : TextileQuery.Query -> List Bookmark -> Maybe Bookmark
findByTextileQuery textileQuery =
    findByQuery (Textile textileQuery)


replace : Bookmark -> List Bookmark -> List Bookmark
replace bookmark =
    LE.updateIf
        (.query >> (==) bookmark.query)
        (always bookmark)


scope : Bookmark -> Scope
scope bookmark =
    case bookmark.query of
        Food _ ->
            Scope.Food

        Object _ ->
            Scope.Object

        Textile _ ->
            Scope.Textile

        Veli _ ->
            Scope.Veli


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
            objectQuery.items
                |> Component.itemsToString db
                |> Result.withDefault "N/A"

        Textile textileQuery ->
            textileQuery
                |> Inputs.fromQuery db
                |> Result.map (Inputs.toString db.textile.wellKnown)
                |> Result.withDefault bookmark.name

        Veli objectQuery ->
            objectQuery.items
                |> Component.itemsToString db
                |> Result.withDefault "N/A"
