module Server.Route exposing
    ( Route(..)
    , endpoint
    )

import Data.Food.Builder.Query as BuilderQuery
import Data.Impact as Impact
import Data.Scope as Scope
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
    = -- Food country list
      GetFoodCountryList
      -- Food ingredient list
    | GetFoodIngredientList
      -- Food packaging list
    | GetFoodPackagingList
      -- Food transforms list
    | GetFoodTransformList
      -- Food recipe builder
    | GetFoodRecipe (Result Query.Errors BuilderQuery.Query)
      -- Textile country list
    | GetTextileCountryList
      -- Textile Material list
    | GetTextileMaterialList
      -- Textile Product list
    | GetTextileProductList
      -- Textile Simple version of all impacts
    | GetTextileSimulator (Result Query.Errors TextileInputs.Query)
      -- Textile Detailed version for all impacts
    | GetTextileSimulatorDetailed (Result Query.Errors TextileInputs.Query)
      -- Textile Simple version for one specific impact
    | GetTextileSimulatorSingle Impact.Trigram (Result Query.Errors TextileInputs.Query)
      -- POST routes
    | PostFoodRecipe


parser : StaticDb.Db -> Parser (Route -> a) a
parser { builderDb, textileDb } =
    Parser.oneOf
        [ -- Food
          Parser.map GetFoodCountryList (s "GET" </> s "food" </> s "countries")
        , Parser.map GetFoodIngredientList (s "GET" </> s "food" </> s "ingredients")
        , Parser.map GetFoodTransformList (s "GET" </> s "food" </> s "transforms")
        , Parser.map GetFoodPackagingList (s "GET" </> s "food" </> s "packagings")
        , Parser.map GetFoodRecipe (s "GET" </> s "food" </> s "recipe" <?> Query.parseFoodQuery builderDb)
        , Parser.map PostFoodRecipe (s "POST" </> s "food" </> s "recipe")

        -- Textile
        , Parser.map GetTextileCountryList (s "GET" </> s "textile" </> s "countries")
        , Parser.map GetTextileMaterialList (s "GET" </> s "textile" </> s "materials")
        , Parser.map GetTextileProductList (s "GET" </> s "textile" </> s "products")
        , Parser.map GetTextileSimulator (s "GET" </> s "textile" </> s "simulator" <?> Query.parseTextileQuery textileDb)
        , Parser.map GetTextileSimulatorDetailed (s "GET" </> s "textile" </> s "simulator" </> s "detailed" <?> Query.parseTextileQuery textileDb)
        , Parser.map GetTextileSimulatorSingle (s "GET" </> s "textile" </> s "simulator" </> Impact.parseTrigram Scope.Textile <?> Query.parseTextileQuery textileDb)
        ]


endpoint : StaticDb.Db -> Request -> Maybe Route
endpoint dbs { method, url } =
    -- Notes:
    -- - Url.fromString can't build a Url without a fully qualified URL, so as we only have the
    --   request path from Express, we build a fake URL with a fake protocol and hostname.
    -- - We update the path appending the HTTP method to it, for simpler, cheaper route parsing.
    Url.fromString ("http://x/" ++ method ++ url)
        |> Maybe.andThen (Parser.parse (parser dbs))
