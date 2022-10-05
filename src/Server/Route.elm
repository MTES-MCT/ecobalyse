module Server.Route exposing
    ( Endpoint(..)
    , Route(..)
    , endpoint
    )

import Data.Food.Recipe as Recipe
import Data.Impact as Impact
import Data.Textile.Inputs as TextileInputs
import Server.Query as Query
import Server.Request exposing (Request)
import Static.Db as StaticDb
import Url
import Url.Parser as Parser exposing ((</>), (<?>), Parser)


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
    = CountryList
      -- Food ingredient list
    | FoodIngredientList
      -- Food recipe builder
    | FoodRecipe (Result Query.Errors Recipe.Query)
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
parser { foodDb, textileDb } =
    Parser.oneOf
        [ Parser.map CountryList (Parser.s "countries")

        -- Food
        , Parser.map FoodIngredientList (Parser.s "food" </> Parser.s "ingredients")
        , Parser.map FoodRecipe (Parser.s "food" </> Parser.s "recipe" <?> Query.parseFoodQuery foodDb)

        -- Textile
        , Parser.map TextileMaterialList (Parser.s "materials")
        , Parser.map TextileProductList (Parser.s "products")
        , Parser.map TextileSimulator (Parser.s "simulator" <?> Query.parseTextileQuery textileDb)
        , Parser.map TextileSimulatorDetailed (Parser.s "simulator" </> Parser.s "detailed" <?> Query.parseTextileQuery textileDb)
        , Parser.map TextileSimulatorSingle (Parser.s "simulator" </> Impact.parseTrigram <?> Query.parseTextileQuery textileDb)
        ]


endpoint : StaticDb.Db -> Request -> Maybe Endpoint
endpoint dbs { method, url } =
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
