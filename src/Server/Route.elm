module Server.Route exposing
    ( Route(..)
    , endpoint
    )

import Data.Country exposing (Country)
import Data.Food.Db as Food
import Data.Food.Query as BuilderQuery
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Textile.Db as Textile
import Data.Textile.Query as TextileQuery
import Server.Query as Query
import Server.Request exposing (Request)
import Static.Db exposing (Db)
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
      FoodGetCountryList
      --     Food ingredient list
    | FoodGetIngredientList
      --     Food packaging list
    | FoodGetPackagingList
      --     Food recipe builder (GET, query string)
    | FoodGetRecipe (Result Query.Errors BuilderQuery.Query)
      --     Food transforms list
    | FoodGetTransformList
      --   POST
      --     Food recipe builder (POST, JSON body)
    | FoodPostRecipe
      --
      -- Textile Routes
      --   GET
      --     Textile country list
    | TextileGetCountryList
      --     Textile Material list
    | TextileGetMaterialList
      --     Textile Product list
    | TextileGetProductList
      --     Textile Simple version of all impacts (GET, query string)
    | TextileGetSimulator (Result Query.Errors TextileQuery.Query)
      --     Textile Detailed version for all impacts (GET, query string)
    | TextileGetSimulatorDetailed (Result Query.Errors TextileQuery.Query)
      --     Textile Simple version for one specific impact (GET, query string)
    | TextileGetSimulatorSingle Definition.Trigram (Result Query.Errors TextileQuery.Query)
      --   POST
      --     Textile Simple version of all impacts (POST, JSON body)
    | TextilePostSimulator
      --     Textile Detailed version for all impacts (POST, JSON body)
    | TextilePostSimulatorDetailed
      --     Textile Simple version for one specific impact (POST, JSON bosy)
    | TextilePostSimulatorSingle Definition.Trigram


parser : Food.Db -> Textile.Db -> List Country -> Parser (Route -> a) a
parser foodDb textile countries =
    Parser.oneOf
        [ -- Food
          Parser.map FoodGetCountryList (s "GET" </> s "food" </> s "countries")
        , Parser.map FoodGetIngredientList (s "GET" </> s "food" </> s "ingredients")
        , Parser.map FoodGetTransformList (s "GET" </> s "food" </> s "transforms")
        , Parser.map FoodGetPackagingList (s "GET" </> s "food" </> s "packagings")
        , Parser.map FoodGetRecipe (s "GET" </> s "food" <?> Query.parseFoodQuery countries foodDb)
        , Parser.map FoodPostRecipe (s "POST" </> s "food")

        -- Textile
        , Parser.map TextileGetCountryList (s "GET" </> s "textile" </> s "countries")
        , Parser.map TextileGetMaterialList (s "GET" </> s "textile" </> s "materials")
        , Parser.map TextileGetProductList (s "GET" </> s "textile" </> s "products")
        , Parser.map TextileGetSimulator (s "GET" </> s "textile" </> s "simulator" <?> Query.parseTextileQuery countries textile)
        , Parser.map TextileGetSimulatorDetailed (s "GET" </> s "textile" </> s "simulator" </> s "detailed" <?> Query.parseTextileQuery countries textile)
        , Parser.map TextileGetSimulatorSingle (s "GET" </> s "textile" </> s "simulator" </> Impact.parseTrigram <?> Query.parseTextileQuery countries textile)
        , Parser.map TextilePostSimulator (s "POST" </> s "textile" </> s "simulator")
        , Parser.map TextilePostSimulatorDetailed (s "POST" </> s "textile" </> s "simulator" </> s "detailed")
        , Parser.map TextilePostSimulatorSingle (s "POST" </> s "textile" </> s "simulator" </> Impact.parseTrigram)
        ]


endpoint : Db -> Request -> Maybe Route
endpoint { countries, food, textile } { method, url } =
    -- Notes:
    -- - Url.fromString can't build a Url without a fully qualified URL, so as we only have the
    --   request path from Express, we build a fake URL with a fake protocol and hostname.
    -- - We update the path appending the HTTP method to it, for simpler, cheaper route parsing.
    Url.fromString ("http://x/" ++ method ++ url)
        |> Maybe.andThen (Parser.parse (parser food textile countries))
