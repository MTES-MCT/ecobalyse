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
    | GenericGetCatalogList GenericScope
    | GenericGetCategoryList GenericScope
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


decodeGenericQueryBody : Component.Config -> Db -> GenericScope -> Encode.Value -> Result Validation.Errors Component.Query
decodeGenericQueryBody config db genericScope body =
    Decode.decodeValue Component.decodeQuery body
        |> Result.mapError Validation.fromDecodingError
        |> Result.andThen
            (Component.validateQuery
                { config = config
                , db = db
                , scope = Scope.Generic genericScope
                }
                >> Result.mapError Validation.fromErrorString
            )


decodeTextileQueryBody : Db -> Encode.Value -> Result Validation.Errors TextileQuery.Query
decodeTextileQueryBody db =
    Decode.decodeValue TextileQuery.decode
        >> Result.mapError Validation.fromDecodingError
        >> Result.andThen (TextileValidation.validate db)


endpoint : Db -> Component.Config -> Request -> Maybe Route
endpoint db config { body, method, url } =
    -- Notes:
    -- - Url.fromString can't build a Url without a fully qualified URL, so as we only have the
    --   request path from Express, we build a fake URL with a fake protocol and hostname.
    -- - We update the path appending the HTTP method to it, for simpler, cheaper route parsing.
    Url.fromString ("http://x/" ++ method ++ url)
        |> Maybe.andThen (Parser.parse (parser db config body))


genericGet : List String -> (GenericScope -> Route) -> Parser (Route -> a) a
genericGet path toRoute =
    path
        |> List.foldl
            (\segment parser_ -> parser_ </> s segment)
            (s "GET" </> Scope.parseGeneric)
        |> Parser.map toRoute


parser : Db -> Component.Config -> Encode.Value -> Parser (Route -> a) a
parser db config body =
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
        , genericGet [ "catalog" ] GenericGetCatalogList
        , genericGet [ "categories" ] GenericGetCategoryList
        , genericGet [ "countries" ] GenericGetCountryList
        , genericGet [ "processes", "assembly" ] GenericGetAssemblyList
        , genericGet [ "processes", "consumption" ] GenericGetConsumptionList
        , genericGet [ "processes", "distribution" ] GenericGetDistributionList
        , genericGet [ "processes", "material" ] GenericGetMaterialList
        , genericGet [ "processes", "packaging" ] GenericGetPackagingList
        , genericGet [ "processes", "transform" ] GenericGetTransformList
        , (s "POST" </> Scope.parseGeneric </> s "simulator")
            |> Parser.map
                (\genericScope ->
                    body
                        |> decodeGenericQueryBody config db genericScope
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
