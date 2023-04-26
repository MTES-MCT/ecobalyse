module Server.Route exposing
    ( Endpoint(..)
    , Route(..)
    , endpoint
    )

import Data.Food.Builder.Query as BuilderQuery
import Data.Impact as Impact
import Data.Scope as Scope
import Data.Textile.Inputs as TextileInputs
import Json.Decode as Decode
import Server.Query as Query
import Server.Request exposing (Request)
import Static.Db as StaticDb
import Url
import Url.Parser as Parser exposing ((</>), (<?>), Parser, s)


type Endpoint
    = Get Route
    | Head Route
    | Post Route
    | Put Route
    | Delete Route
    | Connect Route
    | Options Route
    | Trace Route
    | Path Route


{-| A server request route.

Note: The API root, serving the OpenAPI documentation, is handled by the
ExpressJS server directly (see server.js).

-}
type Route
    = -- Food country list
      FoodCountryList
      -- Food ingredient list
    | FoodIngredientList
      -- Food packaging list
    | FoodPackagingList
      -- Food transforms list
    | FoodTransformList
      -- Food recipe builder
    | FoodRecipe (Result Query.Errors BuilderQuery.Query)
      -- Textile country list
    | TextileCountryList
      -- Textile Material list
    | TextileMaterialList
      -- Textile Product list
    | TextileProductList
      -- Textile Simple version of all impacts
    | TextileSimulator (Result Query.Errors TextileInputs.Query)
      -- Textile Detailed version for all impacts
    | TextileSimulatorDetailed (Result Query.Errors TextileInputs.Query)
      -- Textile Simple version for one specific impact
    | TextileSimulatorSingle Impact.Trigram (Result Query.Errors TextileInputs.Query)


parser : StaticDb.Db -> Parser (Route -> a) a
parser { builderDb, textileDb } =
    Parser.oneOf
        [ -- Food
          Parser.map FoodCountryList (s "food" </> s "countries")
        , Parser.map FoodIngredientList (s "food" </> s "ingredients")
        , Parser.map FoodTransformList (s "food" </> s "transforms")
        , Parser.map FoodPackagingList (s "food" </> s "packagings")
        , Parser.map FoodRecipe (s "food" </> s "recipe" <?> Query.parseFoodQuery builderDb)

        -- Textile
        , Parser.map TextileCountryList (s "textile" </> s "countries")
        , Parser.map TextileMaterialList (s "textile" </> s "materials")
        , Parser.map TextileProductList (s "textile" </> s "products")
        , Parser.map TextileSimulator (s "textile" </> s "simulator" <?> Query.parseTextileQuery textileDb)
        , Parser.map TextileSimulatorDetailed (s "textile" </> s "simulator" </> s "detailed" <?> Query.parseTextileQuery textileDb)
        , Parser.map TextileSimulatorSingle (s "textile" </> s "simulator" </> Impact.parseTrigram Scope.Textile <?> Query.parseTextileQuery textileDb)
        ]


endpoint : StaticDb.Db -> Request -> Maybe Endpoint
endpoint dbs { method, url, body } =
    -- TODO:
    let
        _ =
            body
                |> Decode.decodeValue (Decode.field "a" Decode.int)
                |> Debug.toString
                |> Debug.log "plop"
    in
    -- FIXME: rename `url` to `path` and explain that Url.fromString can't build
    -- a Url without a protocol and a hostname
    Url.fromString ("http://x" ++ url)
        |> Maybe.andThen (Parser.parse (parser dbs))
        |> Maybe.map (mapMethod method)


mapMethod : String -> Route -> Endpoint
mapMethod method route =
    case String.toUpper method of
        "HEAD" ->
            Head route

        "POST" ->
            Post route

        "PUT" ->
            Put route

        "DELETE" ->
            Delete route

        "CONNECT" ->
            Connect route

        "OPTIONS" ->
            Options route

        "TRACE" ->
            Trace route

        "PATH" ->
            Path route

        _ ->
            Get route
