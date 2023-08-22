module Server.Route exposing
    ( Route(..)
    , endpoint
    )

import Data.Food.Query as BuilderQuery
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Textile.Inputs as TextileInputs
import Server.Query as Query
import Server.Request exposing (Request)
import Static.Db as StaticDb
import Url
import Url.Parser as Parser exposing ((</>), (<?>), Parser, s)


{-| A server request route.

Note: The API root, serving the OpenAPI documentation, is handled by the
ExpressJS server directly (see server.js).

-}
type Route
    = -- Food Routes
      --   GET
      --     Food country list
      GetFoodCountryList
      --     Food ingredient list
    | GetFoodIngredientList
      --     Food packaging list
    | GetFoodPackagingList
      --     Food transforms list
    | GetFoodTransformList
      --     Food recipe builder (GET, query string)
    | GetFoodRecipe (Result Query.Errors BuilderQuery.Query)
      --   POST
      --     Food recipe builder (POST, JSON body)
    | PostFoodRecipe
      --
      -- Textile Routes
      --   GET
      --     Textile country list
    | GetTextileCountryList
      --     Textile Material list
    | GetTextileMaterialList
      --     Textile Product list
    | GetTextileProductList
      --     Textile Simple version of all impacts (GET, query string)
    | GetTextileSimulator (Result Query.Errors TextileInputs.Query)
      --     Textile Detailed version for all impacts (GET, query string)
    | GetTextileSimulatorDetailed (Result Query.Errors TextileInputs.Query)
      --     Textile Simple version for one specific impact (GET, query string)
    | GetTextileSimulatorSingle Definition.Trigram (Result Query.Errors TextileInputs.Query)
      --   POST
      --     Textile Simple version of all impacts (POST, JSON body)
    | PostTextileSimulator
      --     Textile Detailed version for all impacts (POST, JSON body)
    | PostTextileSimulatorDetailed
      --     Textile Simple version for one specific impact (POST, JSON bosy)
    | PostTextileSimulatorSingle Definition.Trigram


parser : StaticDb.Db -> Parser (Route -> a) a
parser { foodDb, textileDb } =
    Parser.oneOf
        [ -- Food
          Parser.map GetFoodCountryList (s "GET" </> s "food" </> s "countries")
        , Parser.map GetFoodIngredientList (s "GET" </> s "food" </> s "ingredients")
        , Parser.map GetFoodTransformList (s "GET" </> s "food" </> s "transforms")
        , Parser.map GetFoodPackagingList (s "GET" </> s "food" </> s "packagings")
        , Parser.map GetFoodRecipe (s "GET" </> s "food" </> s "recipe" <?> Query.parseFoodQuery foodDb)
        , Parser.map PostFoodRecipe (s "POST" </> s "food" </> s "recipe")

        -- Textile
        , Parser.map GetTextileCountryList (s "GET" </> s "textile" </> s "countries")
        , Parser.map GetTextileMaterialList (s "GET" </> s "textile" </> s "materials")
        , Parser.map GetTextileProductList (s "GET" </> s "textile" </> s "products")
        , Parser.map GetTextileSimulator (s "GET" </> s "textile" </> s "simulator" <?> Query.parseTextileQuery textileDb)
        , Parser.map GetTextileSimulatorDetailed (s "GET" </> s "textile" </> s "simulator" </> s "detailed" <?> Query.parseTextileQuery textileDb)
        , Parser.map GetTextileSimulatorSingle (s "GET" </> s "textile" </> s "simulator" </> Impact.parseTrigram <?> Query.parseTextileQuery textileDb)
        , Parser.map PostTextileSimulator (s "POST" </> s "textile" </> s "simulator")
        , Parser.map PostTextileSimulatorDetailed (s "POST" </> s "textile" </> s "simulator" </> s "detailed")
        , Parser.map PostTextileSimulatorSingle (s "POST" </> s "textile" </> s "simulator" </> Impact.parseTrigram)
        ]


endpoint : StaticDb.Db -> Request -> Maybe Route
endpoint dbs { method, url } =
    -- Notes:
    -- - Url.fromString can't build a Url without a fully qualified URL, so as we only have the
    --   request path from Express, we build a fake URL with a fake protocol and hostname.
    -- - We update the path appending the HTTP method to it, for simpler, cheaper route parsing.
    Url.fromString ("http://x/" ++ method ++ url)
        |> Maybe.andThen (Parser.parse (parser dbs))
