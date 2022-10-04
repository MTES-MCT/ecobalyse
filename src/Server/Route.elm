module Server.Route exposing
    ( Endpoint(..)
    , Route(..)
    , endpoint
    )

import Data.Impact as Impact
import Data.Textile.Db exposing (Db)
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


parser : Db -> Parser (Route -> a) a
parser db =
    Parser.oneOf
        [ Parser.map CountryList (Parser.s "countries")
        , Parser.map TextileMaterialList (Parser.s "materials")
        , Parser.map TextileProductList (Parser.s "products")
        , Parser.map TextileSimulator (Parser.s "simulator" <?> Query.parse db)
        , Parser.map TextileSimulatorDetailed (Parser.s "simulator" </> Parser.s "detailed" <?> Query.parse db)
        , Parser.map TextileSimulatorSingle (Parser.s "simulator" </> Impact.parseTrigram <?> Query.parse db)
        ]


endpoint : Db -> Request -> Maybe Endpoint
endpoint db { method, url } =
    Url.fromString ("http://x" ++ url)
        |> Maybe.andThen (Parser.parse (parser db))
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
