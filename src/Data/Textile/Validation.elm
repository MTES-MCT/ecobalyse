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
    -- FIXME: import validations from Input.fromQuery
    Ok Query
        |> Validation.required "airTransportRatio" (Ok query.airTransportRatio)
        |> Validation.required "business" (Ok query.business)
        |> Validation.optional "countryDyeing" query.countryDyeing (Country.validateForScope Scope.Textile db.countries)
        |> Validation.optional "countryFabric" query.countryFabric (Country.validateForScope Scope.Textile db.countries)
        |> Validation.optional "countryMaking" query.countryMaking (Country.validateForScope Scope.Textile db.countries)
        |> Validation.optional "countrySpinning" query.countrySpinning (Country.validateForScope Scope.Textile db.countries)
        |> Validation.required "disabledSteps" (Ok query.disabledSteps)
        |> Validation.required "dyeingProcessType" (Ok query.dyeingProcessType)
        |> Validation.required "fabricProcess" (Ok query.fabricProcess)
        |> Validation.required "fading" (Ok query.fading)
        |> Validation.required "makingComplexity" (Ok query.makingComplexity)
        |> Validation.optional "makingDeadStock" query.makingDeadStock validateMakingDeadStock
        |> Validation.optional "makingWaste" query.makingWaste validateMakingWaste
        |> Validation.required "mass" (validateMass query.mass)
        -- FIXME: nested validation in here
        |> Validation.required "materials"
            (if List.isEmpty query.materials then
                Err "La liste de matières ne peut être vide"

             else
                Ok query.materials
            )
        |> Validation.optional "numberOfReferences" query.numberOfReferences validateNumberOfReferences
        |> Validation.optional "physicalDurability" query.physicalDurability validatePhysicalDurability
        |> Validation.optional "price" query.price validatePrice
        |> Validation.required "printing" (Ok query.printing)
        |> Validation.required "product" (Ok query.product)
        |> Validation.optional "surfaceMass" query.surfaceMass validateSurfaceMass
        |> Validation.required "traceability" (Ok query.traceability)
        |> Validation.required "trims" (Component.validateItems db.components query.trims)
        |> Validation.required "upcycled" (Ok query.upcycled)
        -- FIXME: validate yarn size here
        |> Validation.required "yarnSize" (Ok query.yarnSize)


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
