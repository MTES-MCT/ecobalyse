module Server.Route exposing
    ( Route(..)
    , endpoint
    )

import Data.Food.Query as BuilderQuery
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Textile.Inputs as Inputs
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


parser : Db -> Encode.Value -> Parser (Route -> a) a
parser db body =
    Parser.oneOf
        [ -- Food
          -- GET
          (s "GET" </> s "food" </> s "countries")
            |> Parser.map FoodGetCountryList
        , (s "GET" </> s "food" </> s "ingredients")
            |> Parser.map FoodGetIngredientList
        , (s "GET" </> s "food" </> s "transforms")
            |> Parser.map FoodGetTransformList
        , (s "GET" </> s "food" </> s "packagings")
            |> Parser.map FoodGetPackagingList
        , (s "POST" </> s "food")
            |> Parser.map (FoodPostRecipe (decodeFoodQueryBody body))

        -- Textile
        , (s "GET" </> s "textile" </> s "countries")
            |> Parser.map TextileGetCountryList
        , (s "GET" </> s "textile" </> s "materials")
            |> Parser.map TextileGetMaterialList
        , (s "GET" </> s "textile" </> s "products")
            |> Parser.map TextileGetProductList
        , (s "GET" </> s "textile" </> s "simulator" <?> Query.parseTextileQuery db)
            |> Parser.map TextileGetSimulator
        , (s "GET" </> s "textile" </> s "simulator" </> s "detailed" <?> Query.parseTextileQuery db)
            |> Parser.map TextileGetSimulatorDetailed
        , (s "GET" </> s "textile" </> s "simulator" </> Impact.parseTrigram <?> Query.parseTextileQuery db)
            |> Parser.map TextileGetSimulatorSingle
        , (s "POST" </> s "textile" </> s "simulator")
            |> Parser.map (TextilePostSimulator (decodeTextileQueryBody db body))
        , (s "POST" </> s "textile" </> s "simulator" </> s "detailed")
            |> Parser.map (TextilePostSimulatorDetailed (decodeTextileQueryBody db body))
        , (s "POST" </> s "textile" </> s "simulator" </> Impact.parseTrigram)
            |> Parser.map (TextilePostSimulatorSingle (decodeTextileQueryBody db body))
        ]


decodeFoodQueryBody : Encode.Value -> Result String BuilderQuery.Query
decodeFoodQueryBody =
    Decode.decodeValue BuilderQuery.decode
        >> Result.mapError Decode.errorToString


decodeTextileQueryBody : Db -> Encode.Value -> Result String TextileQuery.Query
decodeTextileQueryBody db =
    Decode.decodeValue TextileQuery.decode
        >> Result.mapError Decode.errorToString
        -- Note: Using inputs mapping to act as query validation
        >> Result.andThen (Inputs.fromQuery db)
        >> Result.map Inputs.toQuery


endpoint : Db -> Request -> Maybe Route
endpoint db { body, method, url } =
    -- Notes:
    -- - Url.fromString can't build a Url without a fully qualified URL, so as we only have the
    --   request path from Express, we build a fake URL with a fake protocol and hostname.
    -- - We update the path appending the HTTP method to it, for simpler, cheaper route parsing.
    Url.fromString ("http://x/" ++ method ++ url)
        |> Maybe.andThen (Parser.parse (parser db body))
