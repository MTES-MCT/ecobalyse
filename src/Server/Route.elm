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
      -- Material list
    | MaterialList
      -- Product list
    | ProductList
      -- Simple version of all impacts
    | Simulator (Result Query.Errors Inputs.Query)
      -- Detailed version for all impacts
    | SimulatorDetailed (Result Query.Errors Inputs.Query)
      -- Simple version for one specific impact
    | SimulatorSingle Impact.Trigram (Result Query.Errors Inputs.Query)


parser : Db -> Parser (Route -> a) a
parser db =
    Parser.oneOf
        [ Parser.map CountryList (Parser.s "countries")
        , Parser.map MaterialList (Parser.s "materials")
        , Parser.map ProductList (Parser.s "products")
        , Parser.map Simulator (Parser.s "simulator" <?> Query.parse db)
        , Parser.map SimulatorDetailed (Parser.s "simulator" </> Parser.s "detailed" <?> Query.parse db)
        , Parser.map SimulatorSingle (Parser.s "simulator" </> Impact.parseTrigram <?> Query.parse db)
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
