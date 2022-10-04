module Server.Route exposing
    ( Endpoint(..)
    , Route(..)
    , endpoint
    )

import Data.Impact as Impact
import Data.Textile.Db as TextileDb
import Data.Textile.Inputs as Inputs
import Server.Query as Query
import Server.Request exposing (Request)
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
    | FoodRecipe (Result String ())
      -- Textile Material list
    | TextileMaterialList
      -- Textile Product list
    | TextileProductList
      -- Textile Simple version of all impacts
    | TextileSimulator (Result Query.Errors Inputs.Query)
      -- Textile Detailed version for all impacts
    | TextileSimulatorDetailed (Result Query.Errors Inputs.Query)
      -- Textile Simple version for one specific impact
    | TextileSimulatorSingle Impact.Trigram (Result Query.Errors Inputs.Query)


parser : TextileDb.Db -> Parser (Route -> a) a
parser textileDb =
    Parser.oneOf
        [ Parser.map CountryList (Parser.s "countries")
        , Parser.map FoodIngredientList (Parser.s "food" </> Parser.s "ingredients")

        -- FIXME: handle real query parameter parsing
        , Parser.map (FoodRecipe (Ok ())) (Parser.s "food" </> Parser.s "recipe")
        , Parser.map TextileMaterialList (Parser.s "materials")
        , Parser.map TextileProductList (Parser.s "products")
        , Parser.map TextileSimulator (Parser.s "simulator" <?> Query.parse textileDb)
        , Parser.map TextileSimulatorDetailed (Parser.s "simulator" </> Parser.s "detailed" <?> Query.parse textileDb)
        , Parser.map TextileSimulatorSingle (Parser.s "simulator" </> Impact.parseTrigram <?> Query.parse textileDb)
        ]


endpoint : TextileDb.Db -> Request -> Maybe Endpoint
endpoint textileDb { method, url } =
    -- FIXME: rename `url` to `path` and explain that Url.fromString can't build
    -- a Url without a protocol and a hostname
    Url.fromString ("http://x" ++ url)
        |> Maybe.andThen (Parser.parse (parser textileDb))
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
