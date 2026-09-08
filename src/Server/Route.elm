module Server.Route exposing
    ( Route(..)
    , endpoint
    )

import Data.Component as Component
import Data.Db exposing (Db)
import Data.Food.Query as FoodQuery
import Data.Food.Validation as FoodValidation
import Data.Impact as Impact
import Data.Impact.Definition as Definition
import Data.Scope as Scope exposing (GenericScope)
import Data.Textile.Query as TextileQuery
import Data.Textile.Validation as TextileValidation
import Data.Validation as Validation
import Json.Decode as Decode
import Json.Encode as Encode
import Server.Request exposing (Request)
import Static.Json as StaticJson
import Url
import Url.Parser as Parser exposing ((</>), Parser, s)


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
    | FoodPostRecipe (Result Validation.Errors FoodQuery.Query)
      --
      -- Generic Routes
      --   GET
    | GenericGetAssemblyList GenericScope
    | GenericGetCategoryList GenericScope
    | GenericGetComponentList GenericScope
    | GenericGetConsumptionList GenericScope
    | GenericGetCountryList GenericScope
    | GenericGetDistributionList GenericScope
    | GenericGetMaterialList GenericScope
    | GenericGetPackagingList GenericScope
    | GenericGetTransformList GenericScope
      --   POST
    | GenericPostSimulator GenericScope (Result Validation.Errors Component.Query)
      --
      -- Textile Routes
      --   GET
      --     Textile country list
    | TextileGetCountryList
      --     Textile Material list
    | TextileGetMaterialList
      --     Textile Product list
    | TextileGetProductList
      --     Textile Trims list
    | TextileGetTrimList
      --   POST
      --     Textile Simple version of all impacts (POST, JSON body)
    | TextilePostSimulator (Result Validation.Errors TextileQuery.Query)
      --     Textile Detailed version for all impacts (POST, JSON body)
    | TextilePostSimulatorDetailed (Result Validation.Errors TextileQuery.Query)
      --     Textile Simple version for one specific impact (POST, JSON body)
    | TextilePostSimulatorSingle (Result Validation.Errors TextileQuery.Query) Definition.Trigram


decodeFoodQueryBody : Db -> Encode.Value -> Result Validation.Errors FoodQuery.Query
decodeFoodQueryBody db =
    Decode.decodeValue FoodQuery.decode
        >> Result.mapError Validation.fromDecodingError
        >> Result.andThen (FoodValidation.validate db)


decodeGenericQueryBody : Db -> GenericScope -> Encode.Value -> Result Validation.Errors Component.Query
decodeGenericQueryBody db genericScope body =
    Decode.decodeValue Component.decodeQuery body
        |> Result.mapError Validation.fromDecodingError
        |> Result.andThen
            (\query ->
                -- FIXME: investigate how we could already have the config here; I'd rather expect
                -- it to be readily parsed before even decoding route payloads, and to have already
                -- failed starting the server well before reaching to this point
                Component.parseConfig db StaticJson.componentConfigJson
                    |> Result.mapError Validation.fromErrorString
                    |> Result.andThen
                        (\config ->
                            query
                                |> Component.validateQuery
                                    { config = config
                                    , db = db
                                    , scope = Scope.Generic genericScope
                                    }
                                |> Result.mapError Validation.fromErrorString
                        )
            )


decodeTextileQueryBody : Db -> Encode.Value -> Result Validation.Errors TextileQuery.Query
decodeTextileQueryBody db =
    Decode.decodeValue TextileQuery.decode
        >> Result.mapError Validation.fromDecodingError
        >> Result.andThen (TextileValidation.validate db)


endpoint : Db -> Request -> Maybe Route
endpoint db { body, method, url } =
    -- Notes:
    -- - Url.fromString can't build a Url without a fully qualified URL, so as we only have the
    --   request path from Express, we build a fake URL with a fake protocol and hostname.
    -- - We update the path appending the HTTP method to it, for simpler, cheaper route parsing.
    Url.fromString ("http://x/" ++ method ++ url)
        |> Maybe.andThen (Parser.parse (parser db body))


genericGet : String -> (GenericScope -> Route) -> Parser (Route -> a) a
genericGet segment toRoute =
    Parser.map toRoute
        (s "GET" </> Scope.parseGeneric </> s segment)


parser : Db -> Encode.Value -> Parser (Route -> a) a
parser db body =
    Parser.oneOf
        [ -- Food
          (s "GET" </> s "food" </> s "countries")
            |> Parser.map FoodGetCountryList
        , (s "GET" </> s "food" </> s "ingredients")
            |> Parser.map FoodGetIngredientList
        , (s "GET" </> s "food" </> s "transforms")
            |> Parser.map FoodGetTransformList
        , (s "GET" </> s "food" </> s "packagings")
            |> Parser.map FoodGetPackagingList
        , (s "POST" </> s "food")
            |> Parser.map (FoodPostRecipe (decodeFoodQueryBody db body))

        -- Generic
        , genericGet "assemblies" GenericGetAssemblyList
        , genericGet "categories" GenericGetCategoryList
        , genericGet "components" GenericGetComponentList
        , genericGet "consumptions" GenericGetConsumptionList
        , genericGet "countries" GenericGetCountryList
        , genericGet "distributions" GenericGetDistributionList
        , genericGet "materials" GenericGetMaterialList
        , genericGet "packagings" GenericGetPackagingList
        , genericGet "transforms" GenericGetTransformList
        , (s "POST" </> Scope.parseGeneric </> s "simulator")
            |> Parser.map
                (\genericScope ->
                    body
                        -- FIXME: as commented in decodeGenericQueryBody, investigate passing
                        -- the config here; maybe reuse the `Requirements db config` pattern
                        |> decodeGenericQueryBody db genericScope
                        |> GenericPostSimulator genericScope
                )

        -- Textile
        , (s "GET" </> s "textile" </> s "countries")
            |> Parser.map TextileGetCountryList
        , (s "GET" </> s "textile" </> s "materials")
            |> Parser.map TextileGetMaterialList
        , (s "GET" </> s "textile" </> s "products")
            |> Parser.map TextileGetProductList
        , (s "GET" </> s "textile" </> s "trims")
            |> Parser.map TextileGetTrimList
        , (s "POST" </> s "textile" </> s "simulator")
            |> Parser.map (TextilePostSimulator (decodeTextileQueryBody db body))
        , (s "POST" </> s "textile" </> s "simulator" </> s "detailed")
            |> Parser.map (TextilePostSimulatorDetailed (decodeTextileQueryBody db body))
        , (s "POST" </> s "textile" </> s "simulator" </> Impact.parseTrigram)
            |> Parser.map (TextilePostSimulatorSingle (decodeTextileQueryBody db body))
        ]
