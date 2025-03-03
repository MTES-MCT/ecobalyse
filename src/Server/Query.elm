module Server.Query exposing
    ( Errors
    , encodeErrors
    , parseFoodQuery
    )

import Data.Country as Country exposing (Country)
import Data.Food.Db as Food
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Preparation as Preparation
import Data.Food.Query as BuilderQuery
import Data.Food.Retail as Retail exposing (Distribution)
import Data.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Dict exposing (Dict)
import Json.Encode as Encode
import Mass exposing (Mass)
import Result.Extra as RE
import Static.Db exposing (Db)
import Url.Parser.Query as Query exposing (Parser)



-- Query String


type alias FieldName =
    String


type alias ErrorMessage =
    String


type alias Errors =
    Dict FieldName ErrorMessage


type alias ParseResult a =
    Result ( FieldName, ErrorMessage ) a


succeed : a -> Parser a
succeed =
    -- Kind of a hack: we don't have access to the Parser constructor, so
    -- we use Query.custom to wrap our thing in a Parser
    always >> Query.custom ""


parseFoodQuery : Db -> Parser (Result Errors BuilderQuery.Query)
parseFoodQuery db =
    succeed (Ok BuilderQuery.Query)
        |> apply (distributionParser "distribution")
        |> apply (ingredientListParser "ingredients" db.countries db.food)
        |> apply (packagingListParser "packaging" db.processes)
        |> apply (preparationListParser "preparation")
        |> apply (maybeTransformParser "transform" db.processes)


ingredientListParser : String -> List Country -> Food.Db -> Parser (ParseResult (List BuilderQuery.IngredientQuery))
ingredientListParser key countries food =
    Query.custom (key ++ "[]")
        (List.map (ingredientParser countries food)
            >> RE.combine
            >> Result.mapError (\err -> ( key, err ))
        )


ingredientParser : List Country -> Food.Db -> String -> Result String BuilderQuery.IngredientQuery
ingredientParser countries food string =
    let
        byPlaneParser byPlane ingredient =
            ingredient
                |> validateByPlaneValue byPlane
                |> Result.andThen (\maybeByPlane -> Ingredient.byPlaneAllowed maybeByPlane ingredient)

        getIngredient id =
            Ingredient.idFromString id
                |> Result.fromMaybe ("Identifiant d’ingrédient invalide\u{202F}: " ++ id ++ ". Un `uuid` est attendu.")
                |> Result.andThen (\ingredientId -> Ingredient.findById ingredientId food.ingredients)
    in
    case String.split ";" string of
        [ id, mass ] ->
            let
                ingredient =
                    getIngredient id
            in
            Ok BuilderQuery.IngredientQuery
                |> RE.andMap (Ok Nothing)
                |> RE.andMap (Result.map .id ingredient)
                |> RE.andMap (validateMassInGrams mass)
                |> RE.andMap (Result.map Ingredient.byPlaneByDefault ingredient)

        [ id, mass, countryCode ] ->
            let
                ingredient =
                    getIngredient id
            in
            Ok BuilderQuery.IngredientQuery
                |> RE.andMap (countryParser countries Scope.Food countryCode)
                |> RE.andMap (Result.map .id ingredient)
                |> RE.andMap (validateMassInGrams mass)
                |> RE.andMap (Result.map Ingredient.byPlaneByDefault ingredient)

        [ id, mass, countryCode, byPlane ] ->
            let
                ingredient =
                    getIngredient id
            in
            Ok BuilderQuery.IngredientQuery
                |> RE.andMap (countryParser countries Scope.Food countryCode)
                |> RE.andMap (Result.map .id ingredient)
                |> RE.andMap (validateMassInGrams mass)
                |> RE.andMap (ingredient |> Result.andThen (byPlaneParser byPlane))

        [ "" ] ->
            Err <| "Format d'ingrédient vide."

        _ ->
            Err <| "Format d'ingrédient invalide : " ++ string ++ "."


countryParser : List Country -> Scope -> String -> Result String (Maybe Country.Code)
countryParser countries scope countryStr =
    if countryStr == "" then
        Ok Nothing

    else
        countries
            |> validateCountry countryStr scope
            |> Result.map Just


foodProcessIdParser : List Process -> String -> Result String Process.Id
foodProcessIdParser processes string =
    Process.idFromString string
        |> Result.andThen (\id -> Process.findById id processes)
        |> Result.map .id


packagingListParser : String -> List Process -> Parser (ParseResult (List BuilderQuery.ProcessQuery))
packagingListParser key packagings =
    Query.custom (key ++ "[]")
        (List.map (packagingParser packagings)
            >> RE.combine
            >> Result.mapError (\err -> ( key, err ))
        )


preparationListParser : String -> Parser (ParseResult (List Preparation.Id))
preparationListParser key =
    Query.custom (key ++ "[]")
        -- Note: leveraging Preparation.findById for validation
        (List.map (Preparation.Id >> Preparation.findById >> Result.map .id)
            >> RE.combine
            >> Result.andThen
                (\list ->
                    if List.length list > 2 then
                        Err "Deux techniques de préparation maximum."

                    else
                        Ok list
                )
            >> Result.mapError (\err -> ( key, err ))
        )


packagingParser : List Process -> String -> Result String BuilderQuery.ProcessQuery
packagingParser packagings string =
    case String.split ";" string of
        [ code, mass ] ->
            Ok BuilderQuery.ProcessQuery
                |> RE.andMap (foodProcessIdParser packagings code)
                |> RE.andMap (validateMassInGrams mass)

        [ "" ] ->
            Err <| "Format d'emballage vide."

        _ ->
            Err <| "Format d'emballage invalide : " ++ string ++ "."


validateByPlaneValue : String -> Ingredient -> Result String Ingredient.PlaneTransport
validateByPlaneValue str ingredient =
    case str of
        "" ->
            Ok (Ingredient.byPlaneByDefault ingredient)

        "byPlane" ->
            Ok Ingredient.ByPlane

        "noPlane" ->
            Ok Ingredient.NoPlane

        _ ->
            Err "La valeur ne peut être que parmi les choix suivants: '', 'byPlane', 'noPlane'."


validateCountry : String -> Scope -> List Country -> Result String Country.Code
validateCountry countryCode scope =
    Country.findByCode (Country.codeFromString countryCode)
        >> Result.andThen
            (\{ code, scopes } ->
                if List.member scope scopes then
                    Ok code

                else
                    "Le code pays "
                        ++ countryCode
                        ++ " n'est pas utilisable dans un contexte "
                        ++ Scope.toLabel scope
                        ++ "."
                        |> Err
            )


validateMassInGrams : String -> Result String Mass
validateMassInGrams string =
    string
        |> String.toFloat
        |> Result.fromMaybe ("Masse invalide : " ++ string)
        |> Result.andThen
            (\mass ->
                if mass < 0 then
                    Err "La masse doit être supérieure ou égale à zéro."

                else
                    Ok mass
            )
        |> Result.map Mass.grams


maybeTransformParser : String -> List Process -> Parser (ParseResult (Maybe BuilderQuery.ProcessQuery))
maybeTransformParser key transforms =
    Query.string key
        |> Query.map
            (Maybe.map
                (\str ->
                    parseTransform_ transforms str
                        |> Result.map Just
                        |> Result.mapError (\err -> ( key, err ))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


distributionParser : String -> Parser (ParseResult (Maybe Distribution))
distributionParser key =
    Query.string key
        |> Query.map
            (Maybe.map
                (Retail.fromString
                    >> Result.map Just
                    >> Result.mapError (\err -> ( key, err ))
                )
                >> Maybe.withDefault (Ok Nothing)
            )


parseTransform_ : List Process -> String -> Result String BuilderQuery.ProcessQuery
parseTransform_ transforms string =
    case String.split ";" string of
        [ code, mass ] ->
            Ok BuilderQuery.ProcessQuery
                |> RE.andMap (foodProcessIdParser transforms code)
                |> RE.andMap (validateMassInGrams mass)

        [ "" ] ->
            Err <| "Code de procédé de transformation manquant."

        _ ->
            Err <| "Format de procédé de transformation invalide : " ++ string ++ "."


toErrors : ParseResult a -> Result Errors a
toErrors =
    Result.mapError
        (\( key, errorMessage ) ->
            Dict.singleton key errorMessage
        )


builder :
    Result (Dict comparable v) a
    -> Result (Dict comparable v) (a -> b)
    -> Result (Dict comparable v) b
builder result accumulator =
    case ( result, accumulator ) of
        ( Err a, Err b ) ->
            -- Merge the error dicts
            Err <| Dict.union a b

        ( Ok _, Err b ) ->
            -- No error in "result", but the accumulator is errored: return the errored accumulator
            Err b

        ( valueOrError, Ok fn ) ->
            Result.map fn valueOrError


apply : Parser (ParseResult a) -> Parser (Result Errors (a -> b)) -> Parser (Result Errors b)
apply argParser funcParser =
    -- Adapted from https://package.elm-lang.org/packages/elm/url/latest/Url-Parser-Query#map8
    -- with the full list of errors returned, instead of just the first one encountered.
    Query.map2
        builder
        (Query.map toErrors argParser)
        funcParser



-- Encoders


encodeErrors : Errors -> Encode.Value
encodeErrors errors =
    Encode.object
        [ ( "errors"
          , errors |> Encode.dict identity Encode.string
          )
        ]
