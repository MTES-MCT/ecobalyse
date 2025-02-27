module Data.Textile.Validation exposing (validate)

import Data.Component as Component
import Data.Country as Country
import Data.Env as Env
import Data.Scope as Scope
import Data.Split as Split exposing (Split)
import Data.Textile.Economics as Economics
import Data.Textile.Query exposing (Query)
import Mass exposing (Mass)
import Result.Extra as RE
import Static.Db exposing (Db)


{-| Validate values not fully qualified by their type or applied JSON decoders.
-}
validate : Db -> Query -> Result String Query
validate db query =
    let
        validateMaybe fn =
            Maybe.map (fn >> Result.map Just)
                >> Maybe.withDefault (Ok Nothing)
    in
    Ok Query
        |> RE.andMap (Ok query.airTransportRatio)
        |> RE.andMap (Ok query.business)
        |> RE.andMap (query.countryDyeing |> validateMaybe (Country.validateForScope Scope.Textile db.countries))
        |> RE.andMap (query.countryFabric |> validateMaybe (Country.validateForScope Scope.Textile db.countries))
        |> RE.andMap (query.countryMaking |> validateMaybe (Country.validateForScope Scope.Textile db.countries))
        |> RE.andMap (query.countrySpinning |> validateMaybe (Country.validateForScope Scope.Textile db.countries))
        |> RE.andMap (Ok query.disabledSteps)
        |> RE.andMap (Ok query.dyeingProcessType)
        |> RE.andMap (Ok query.fabricProcess)
        |> RE.andMap (Ok query.fading)
        |> RE.andMap (Ok query.makingComplexity)
        |> RE.andMap (query.makingDeadStock |> validateMaybe validateMakingDeadStock)
        |> RE.andMap (query.makingWaste |> validateMaybe validateMakingWaste)
        |> RE.andMap (validateMass query.mass)
        |> RE.andMap
            (if List.isEmpty query.materials then
                Err "La liste de matières ne peut être vide"

             else
                Ok query.materials
            )
        |> RE.andMap (query.numberOfReferences |> validateMaybe validateNumberOfReferences)
        |> RE.andMap (Ok query.physicalDurability)
        |> RE.andMap (query.price |> validateMaybe validatePrice)
        |> RE.andMap (Ok query.printing)
        |> RE.andMap (Ok query.product)
        |> RE.andMap (Ok query.surfaceMass)
        |> RE.andMap (Ok query.traceability)
        |> RE.andMap (Component.validateItems db.components query.trims)
        |> RE.andMap (Ok query.upcycled)
        |> RE.andMap (Ok query.yarnSize)


validateMakingDeadStock : Split -> Result String Split
validateMakingDeadStock =
    validateWithin "Le taux de stocks dormants en confection"
        { max = Env.maxMakingDeadStockRatio
        , min = Env.minMakingDeadStockRatio
        , toNumber = Split.toFloat
        , toString = Split.toFloatString
        }


validateMakingWaste : Split -> Result String Split
validateMakingWaste =
    validateWithin "Le taux de perte en confection"
        { max = Env.maxMakingWasteRatio
        , min = Env.minMakingWasteRatio
        , toNumber = Split.toFloat
        , toString = Split.toFloatString
        }


validateMass : Mass -> Result String Mass
validateMass mass =
    if Mass.inKilograms mass <= 0 then
        Err "La masse doit être supérieure ou égale à zéro"

    else
        Ok mass


validateNumberOfReferences : Int -> Result String Int
validateNumberOfReferences =
    validateWithin "Le nombre de références"
        { max = Economics.maxNumberOfReferences
        , min = Economics.minNumberOfReferences
        , toNumber = identity
        , toString = String.fromInt
        }


validatePrice : Economics.Price -> Result String Economics.Price
validatePrice =
    validateWithin "Le prix unitaire"
        { max = Economics.maxPrice
        , min = Economics.minPrice
        , toNumber = Economics.priceToFloat
        , toString = Economics.priceToFloat >> String.fromFloat
        }


validateWithin : String -> { max : a, min : a, toNumber : a -> number, toString : a -> String } -> a -> Result String a
validateWithin what { max, min, toNumber, toString } value =
    if toNumber value < toNumber min || toNumber value > toNumber max then
        Err <|
            what
                ++ " doit être compris entre "
                ++ toString min
                ++ " et "
                ++ toString max
                ++ "."

    else
        Ok value
