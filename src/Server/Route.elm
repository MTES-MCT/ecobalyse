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
import Json.Decode as Decode
import Json.Encode as Encode
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
    | FoodPostRecipe (Result String BuilderQuery.Query)
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
    | TextilePostSimulator (Result String TextileQuery.Query)
      --     Textile Detailed version for all impacts (POST, JSON body)
    | TextilePostSimulatorDetailed (Result String TextileQuery.Query)
      --     Textile Simple version for one specific impact (POST, JSON body)
    | TextilePostSimulatorSingle (Result String TextileQuery.Query) Definition.Trigram


parser : Food.Db -> Textile.Db -> List Country -> Encode.Value -> Parser (Route -> a) a
parser foodDb textile countries body =
    Parser.oneOf
        [ -- Food
          -- GET
          Parser.map FoodGetCountryList (s "GET" </> s "food" </> s "countries")
        , Parser.map FoodGetIngredientList (s "GET" </> s "food" </> s "ingredients")
        , Parser.map FoodGetTransformList (s "GET" </> s "food" </> s "transforms")
        , Parser.map FoodGetPackagingList (s "GET" </> s "food" </> s "packagings")
        , Parser.map FoodGetRecipe (s "GET" </> s "food" <?> Query.parseFoodQuery countries foodDb)

        -- POST
        , Parser.map (FoodPostRecipe (decodeFoodQueryBody body)) (s "POST" </> s "food")

        -- Textile
        -- GET
        , Parser.map TextileGetCountryList (s "GET" </> s "textile" </> s "countries")
        , Parser.map TextileGetMaterialList (s "GET" </> s "textile" </> s "materials")
        , Parser.map TextileGetProductList (s "GET" </> s "textile" </> s "products")
        , Parser.map TextileGetSimulator (s "GET" </> s "textile" </> s "simulator" <?> Query.parseTextileQuery countries textile)
        , Parser.map TextileGetSimulatorDetailed (s "GET" </> s "textile" </> s "simulator" </> s "detailed" <?> Query.parseTextileQuery countries textile)
        , Parser.map TextileGetSimulatorSingle (s "GET" </> s "textile" </> s "simulator" </> Impact.parseTrigram <?> Query.parseTextileQuery countries textile)

        -- POST
        -- FIXME: we should parse the body to ensure it's an actual query
        , Parser.map (TextilePostSimulator (decodeTextileQueryBody body)) (s "POST" </> s "textile" </> s "simulator")
        , Parser.map (TextilePostSimulatorDetailed (decodeTextileQueryBody body)) (s "POST" </> s "textile" </> s "simulator" </> s "detailed")
        , Parser.map (TextilePostSimulatorSingle (decodeTextileQueryBody body)) (s "POST" </> s "textile" </> s "simulator" </> Impact.parseTrigram)
        ]


decodeFoodQueryBody : Encode.Value -> Result String BuilderQuery.Query
decodeFoodQueryBody body =
    Decode.decodeValue BuilderQuery.decode body
        |> Result.mapError Decode.errorToString


decodeTextileQueryBody : Encode.Value -> Result String TextileQuery.Query
decodeTextileQueryBody body =
    Decode.decodeValue TextileQuery.decode body
        |> Result.mapError Decode.errorToString


endpoint : Db -> Request -> Maybe Route
endpoint { countries, food, textile } { body, method, url } =
    -- Notes:
    -- - Url.fromString can't build a Url without a fully qualified URL, so as we only have the
    --   request path from Express, we build a fake URL with a fake protocol and hostname.
    -- - We update the path appending the HTTP method to it, for simpler, cheaper route parsing.
    Url.fromString ("http://x/" ++ method ++ url)
        |> Maybe.andThen (Parser.parse (parser food textile countries body))
