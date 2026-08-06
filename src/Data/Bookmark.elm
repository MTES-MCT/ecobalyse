module Data.Bookmark exposing
    ( Bookmark
    , Query(..)
    , decodeJsonList
    , encodeJsonList
    , findByFoodQuery
    , findByObjectQuery
    , findByTextileQuery
    , genericQueryFromScope
    , isFood
    , isFood2
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
import Data.Db exposing (Db)
import Data.Food.Query as FoodQuery
import Data.Food.Recipe as Recipe
import Data.Scope as Scope exposing (GenericScope, Scope)
import Data.Textile.Inputs as Inputs
import Data.Textile.Query as TextileQuery
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import List.Extra as LE
import Time exposing (Posix)


type alias Bookmark =
    { created : Posix
    , genericScope : Maybe GenericScope
    , name : String
    , query : Query
    }


type Query
    = Food FoodQuery.Query
    | Generic GenericScope Component.Query
    | Textile TextileQuery.Query


decode : Decoder Bookmark
decode =
    -- FIXME: check that we couldn't use something less confusing than `identity` here
    Decode.succeed identity
        |> JDP.required "created" (Decode.map Time.millisToPosix Decode.int)
        |> Decode.andThen decodeBookmarkBody


decodeBookmarkBody : Posix -> Decoder Bookmark
decodeBookmarkBody created =
    -- FIXME: check that we couldn't use something less confusing than `identity` here
    Decode.succeed identity
        |> DU.strictOptionalWithDefault "subScope" (Decode.maybe Scope.decodeGeneric) Nothing
        |> Decode.andThen (decodeBookmarkName created)


decodeBookmarkName : Posix -> Maybe GenericScope -> Decoder Bookmark
decodeBookmarkName created genericScope =
    -- FIXME: check that we couldn't use something less confusing than `identity` here
    Decode.succeed identity
        |> JDP.required "name" Decode.string
        |> Decode.andThen (decodeBookmarkQuery created genericScope)


decodeBookmarkQuery : Posix -> Maybe GenericScope -> String -> Decoder Bookmark
decodeBookmarkQuery created genericScope name =
    Decode.field "query" Decode.value
        |> Decode.andThen
            (decodeQueryValue genericScope
                >> Decode.map
                    (\query ->
                        { created = created
                        , genericScope = genericScope
                        , name = name
                        , query = query
                        }
                    )
            )
        |> Decode.map
            (\bookmark ->
                case ( bookmark.query, bookmark.genericScope ) of
                    ( Generic _ query, Just genericScope_ ) ->
                        { bookmark | query = Generic genericScope_ query }

                    _ ->
                        bookmark
            )


decodeGenericQueryValue : Maybe GenericScope -> Decode.Value -> Decoder Query
decodeGenericQueryValue maybeGenericScope queryValue =
    let
        genericScope =
            maybeGenericScope |> Maybe.withDefault Scope.Object

        queryScope =
            Scope.Generic genericScope
    in
    case queryValue |> Decode.decodeValue (Component.decodeQuery queryScope) of
        Err err ->
            Decode.fail (Decode.errorToString err)

        Ok query ->
            Decode.succeed (Generic genericScope query)


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


decodeQueryValue : Maybe GenericScope -> Decode.Value -> Decoder Query
decodeQueryValue maybeGenericScope queryValue =
    Decode.oneOf
        [ -- Legacy non-generic queries
          case Decode.decodeValue FoodQuery.decode queryValue of
            Err _ ->
                Decode.fail "not a food query"

            Ok query ->
                Decode.succeed (Food query)
        , case Decode.decodeValue TextileQuery.decode queryValue of
            Err _ ->
                Decode.fail "not a textile query"

            Ok query ->
                Decode.succeed (Textile query)

        -- Generic queries
        , decodeGenericQueryValue maybeGenericScope queryValue
        ]


encode : Bookmark -> Encode.Value
encode v =
    EU.optionalPropertiesObject
        [ ( "created", v.created |> Time.posixToMillis |> Encode.int |> Just )
        , ( "name", Encode.string v.name |> Just )
        , ( "query", encodeQuery v.query |> Just )
        , ( "subScope", encodeGenericScope v.query )
        ]


encodeGenericScope : Query -> Maybe Encode.Value
encodeGenericScope query =
    case query of
        Generic genericScope _ ->
            Just (Scope.encodeGeneric genericScope)

        _ ->
            Nothing


encodeJsonList : List Bookmark -> Encode.Value
encodeJsonList =
    Encode.list (encode >> Encode.encode 0 >> Encode.string)


encodeQuery : Query -> Encode.Value
encodeQuery v =
    case v of
        Food query ->
            FoodQuery.encode query

        -- Note: generic scope is encoded at the parent bookmark record level
        Generic _ query ->
            Component.encodeQuery query

        Textile query ->
            TextileQuery.encode query


isFood : Bookmark -> Bool
isFood { query } =
    case query of
        Food _ ->
            True

        _ ->
            False


isFood2 : Bookmark -> Bool
isFood2 { query } =
    case query of
        Generic Scope.Food2 _ ->
            True

        _ ->
            False


isObject : Bookmark -> Bool
isObject { query } =
    case query of
        Generic Scope.Object _ ->
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
        Generic Scope.Veli _ ->
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
    findByQuery (Generic Scope.Object objectQuery)


findByTextileQuery : TextileQuery.Query -> List Bookmark -> Maybe Bookmark
findByTextileQuery textileQuery =
    findByQuery (Textile textileQuery)


genericQueryFromScope : Scope -> Component.Query -> Query
genericQueryFromScope scope_ =
    case scope_ of
        Scope.Generic genericScope ->
            Generic genericScope

        _ ->
            Generic Scope.Object


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

        Generic genericScope _ ->
            Scope.Generic genericScope

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

        Generic _ { items } ->
            items
                |> Component.itemsToString db
                |> Result.withDefault "N/A"

        Textile textileQuery ->
            textileQuery
                |> Inputs.fromQuery db
                |> Result.map (Inputs.toString db.textile.wellKnown)
                |> Result.withDefault bookmark.name
