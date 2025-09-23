module Data.Food.Validation exposing (validate)

import Data.Country as Country
import Data.Food.Ingredient as Ingredient
import Data.Food.Preparation as Preparation
import Data.Food.Query exposing (IngredientQuery, ProcessQuery, Query)
import Data.Process as Process
import Data.Scope as Scope
import Data.Validation as Validation
import Mass exposing (Mass)
import Result.Extra as RE
import Static.Db exposing (Db)


{-| Validate values not fully qualified by their type or applied JSON decoders.
-}
validate : Db -> Query -> Result Validation.Errors Query
validate db query =
    Ok Query
        |> Validation.ok "distribution" query.distribution
        |> Validation.list "ingredients" query.ingredients (validateIngredient db)
        |> Validation.list "packaging" query.packaging (validateProcess db)
        |> Validation.boundedList { max = Just 2, min = 0 } "preparation" query.preparation validatePreparation
        |> Validation.maybe "transform" query.transform (validateProcess db)


validateIngredient : Db -> IngredientQuery -> Result String IngredientQuery
validateIngredient db ingredientQuery =
    Ok IngredientQuery
        |> RE.andMap
            (ingredientQuery.country
                |> validateMaybe (Country.validateForScope Scope.Food db.countries)
            )
        |> RE.andMap
            (db.food.ingredients
                |> Ingredient.findById ingredientQuery.id
                |> Result.map .id
            )
        |> RE.andMap (validateMass ingredientQuery.mass)
        |> RE.andMap (Ok ingredientQuery.planeTransport)


validateMass : Mass -> Result String Mass
validateMass mass =
    if Mass.inKilograms mass <= 0 then
        Err "La masse doit être supérieure à zéro"

    else
        Ok mass


validateMaybe : (a -> Result error a) -> Maybe a -> Result error (Maybe a)
validateMaybe fn =
    Maybe.map (fn >> Result.map Just)
        >> Maybe.withDefault (Ok Nothing)


validatePreparation : Preparation.Id -> Result String Preparation.Id
validatePreparation =
    Preparation.findById >> Result.map .id


validateProcess : Db -> ProcessQuery -> Result String ProcessQuery
validateProcess db processQuery =
    Ok ProcessQuery
        |> RE.andMap
            (db.processes
                |> Process.findById processQuery.id
                |> Result.map .id
            )
        |> RE.andMap (validateMass processQuery.mass)
