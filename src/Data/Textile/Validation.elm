module Data.Textile.Validation exposing (validate)

import Data.Component as Component
import Data.Country as Country
import Data.Env as Env
import Data.Scope as Scope
import Data.Split as Split exposing (Split)
import Data.Textile.Economics as Economics
import Data.Textile.Query exposing (Query)
import Data.Unit as Unit
import Data.Validation as Validation
import Mass exposing (Mass)
import Static.Db exposing (Db)


{-| Validate values not fully qualified by their type or applied JSON decoders.
-}
validate : Db -> Query -> Result Validation.Errors Query
validate db query =
    let
        validateMaybe fn maybe =
            maybe
                |> Maybe.map (fn >> Result.map Just)
                |> Maybe.withDefault (Ok Nothing)
    in
    -- FIXME: import validations from Input.fromQuery
    Ok Query
        |> Validation.with "airTransportRatio" (Ok query.airTransportRatio)
        |> Validation.with "business" (Ok query.business)
        |> Validation.with "countryDyeing" (query.countryDyeing |> validateMaybe (Country.validateForScope Scope.Textile db.countries))
        |> Validation.with "countryFabric" (query.countryFabric |> validateMaybe (Country.validateForScope Scope.Textile db.countries))
        |> Validation.with "countryMaking" (query.countryMaking |> validateMaybe (Country.validateForScope Scope.Textile db.countries))
        |> Validation.with "countrySpinning" (query.countrySpinning |> validateMaybe (Country.validateForScope Scope.Textile db.countries))
        |> Validation.with "disabledSteps" (Ok query.disabledSteps)
        |> Validation.with "dyeingProcessType" (Ok query.dyeingProcessType)
        |> Validation.with "fabricProcess" (Ok query.fabricProcess)
        |> Validation.with "fading" (Ok query.fading)
        |> Validation.with "makingComplexity" (Ok query.makingComplexity)
        |> Validation.with "makingDeadStock" (query.makingDeadStock |> validateMaybe validateMakingDeadStock)
        |> Validation.with "makingWaste" (query.makingWaste |> validateMaybe validateMakingWaste)
        |> Validation.with "mass" (validateMass query.mass)
        |> Validation.with "materials"
            (if List.isEmpty query.materials then
                Err "La liste de matières ne peut être vide"

             else
                Ok query.materials
            )
        |> Validation.with "numberOfReferences" (query.numberOfReferences |> validateMaybe validateNumberOfReferences)
        |> Validation.with "physicalDurability" (query.physicalDurability |> validateMaybe validatePhysicalDurability)
        |> Validation.with "price" (query.price |> validateMaybe validatePrice)
        |> Validation.with "printing" (Ok query.printing)
        |> Validation.with "product" (Ok query.product)
        -- FIXME: validate surface mass
        |> Validation.with "surfaceMass" (query.surfaceMass |> validateMaybe validateSurfaceMass)
        |> Validation.with "traceability" (Ok query.traceability)
        |> Validation.with "trims" (Component.validateItems db.components query.trims)
        |> Validation.with "upcycled" (Ok query.upcycled)
        |> Validation.with "yarnSize" (Ok query.yarnSize)


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


validatePhysicalDurability : Unit.PhysicalDurability -> Result String Unit.PhysicalDurability
validatePhysicalDurability =
    validateWithin "Le coefficient de durabilité physique"
        { max = Unit.maxDurability Unit.PhysicalDurability
        , min = Unit.minDurability Unit.PhysicalDurability
        , toNumber = Unit.physicalDurabilityToFloat
        , toString = Unit.physicalDurabilityToFloat >> String.fromFloat
        }


validatePrice : Economics.Price -> Result String Economics.Price
validatePrice =
    validateWithin "Le prix unitaire"
        { max = Economics.maxPrice
        , min = Economics.minPrice
        , toNumber = Economics.priceToFloat
        , toString = Economics.priceToFloat >> String.fromFloat
        }


validateSurfaceMass : Unit.SurfaceMass -> Result String Unit.SurfaceMass
validateSurfaceMass =
    validateWithin "La masse surfacique"
        { max = Unit.maxSurfaceMass
        , min = Unit.minSurfaceMass
        , toNumber = Unit.surfaceMassInGramsPerSquareMeters
        , toString = Unit.surfaceMassInGramsPerSquareMeters >> String.fromInt
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
