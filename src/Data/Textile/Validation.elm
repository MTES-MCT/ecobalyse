module Data.Textile.Validation exposing (validate)

import Data.Component as Component
import Data.Country as Country
import Data.Env as Env
import Data.Scope as Scope
import Data.Split as Split exposing (Split)
import Data.Textile.Economics as Economics
import Data.Textile.Material as Material
import Data.Textile.Product as Product
import Data.Textile.Query exposing (MaterialQuery, Query)
import Data.Unit as Unit
import Data.Validation as Validation
import Mass exposing (Mass)
import Result.Extra as RE
import Static.Db exposing (Db)


{-| Validate values not fully qualified by their type or applied JSON decoders.
-}
validate : Db -> Query -> Result Validation.Errors Query
validate db query =
    Ok Query
        |> Validation.accept "airTransportRatio" query.airTransportRatio
        |> Validation.accept "business" query.business
        |> Validation.maybe "countryDyeing" query.countryDyeing (Country.validateForScope Scope.Textile db.countries)
        |> Validation.maybe "countryFabric" query.countryFabric (Country.validateForScope Scope.Textile db.countries)
        |> Validation.maybe "countryMaking" query.countryMaking (Country.validateForScope Scope.Textile db.countries)
        |> Validation.maybe "countrySpinning" query.countrySpinning (Country.validateForScope Scope.Textile db.countries)
        |> Validation.accept "disabledSteps" query.disabledSteps
        |> Validation.accept "dyeingProcessType" query.dyeingProcessType
        |> Validation.accept "fabricProcess" query.fabricProcess
        |> Validation.accept "fading" query.fading
        |> Validation.accept "makingComplexity" query.makingComplexity
        |> Validation.maybe "makingDeadStock" query.makingDeadStock validateMakingDeadStock
        |> Validation.maybe "makingWaste" query.makingWaste validateMakingWaste
        |> Validation.check "mass" (validateMass query.mass)
        |> Validation.nonEmptyList "materials" query.materials (validateMaterialQuery db)
        |> Validation.maybe "numberOfReferences" query.numberOfReferences validateNumberOfReferences
        |> Validation.maybe "physicalDurability" query.physicalDurability validatePhysicalDurability
        |> Validation.maybe "price" query.price validatePrice
        |> Validation.accept "printing" query.printing
        |> Validation.check "product" (validateProduct db query.product)
        |> Validation.maybe "surfaceMass" query.surfaceMass validateSurfaceMass
        |> Validation.check "traceability" (Ok query.traceability)
        |> Validation.list "trims" query.trims (Component.validateItem db.components)
        |> Validation.accept "upcycled" query.upcycled
        |> Validation.maybe "yarnSize" query.yarnSize validateYarnSize


validateMakingDeadStock : Split -> Result String Split
validateMakingDeadStock =
    Validation.validateWithin "Le taux de stocks dormants en confection"
        { max = Env.maxMakingDeadStockRatio
        , min = Env.minMakingDeadStockRatio
        , toNumber = Split.toFloat
        , toString = Split.toFloatString
        }


validateMakingWaste : Split -> Result String Split
validateMakingWaste =
    Validation.validateWithin "Le taux de perte en confection"
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


validateMaterialQuery : Db -> MaterialQuery -> Result String MaterialQuery
validateMaterialQuery db materialQuery =
    Ok MaterialQuery
        |> RE.andMap
            (materialQuery.country
                |> validateMaybe (Country.validateForScope Scope.Textile db.countries)
            )
        |> RE.andMap
            (db.textile.materials
                |> Material.findById materialQuery.id
                |> Result.map .id
            )
        |> RE.andMap (Ok materialQuery.share)
        |> RE.andMap (Ok materialQuery.spinning)


validateMaybe : (a -> Result error a) -> Maybe a -> Result error (Maybe a)
validateMaybe fn =
    Maybe.map (fn >> Result.map Just)
        >> Maybe.withDefault (Ok Nothing)


validateNumberOfReferences : Int -> Result String Int
validateNumberOfReferences =
    Validation.validateWithin "Le nombre de références"
        { max = Economics.maxNumberOfReferences
        , min = Economics.minNumberOfReferences
        , toNumber = identity
        , toString = String.fromInt
        }


validatePhysicalDurability : Unit.PhysicalDurability -> Result String Unit.PhysicalDurability
validatePhysicalDurability =
    Validation.validateWithin "Le coefficient de durabilité physique"
        { max = Unit.maxDurability Unit.PhysicalDurability
        , min = Unit.minDurability Unit.PhysicalDurability
        , toNumber = Unit.physicalDurabilityToFloat
        , toString = Unit.physicalDurabilityToFloat >> String.fromFloat
        }


validatePrice : Economics.Price -> Result String Economics.Price
validatePrice =
    Validation.validateWithin "Le prix unitaire"
        { max = Economics.maxPrice
        , min = Economics.minPrice
        , toNumber = Economics.priceToFloat
        , toString = Economics.priceToFloat >> String.fromFloat
        }


validateProduct : Db -> Product.Id -> Result String Product.Id
validateProduct db id =
    db.textile.products
        |> Product.findById id
        |> Result.map .id


validateSurfaceMass : Unit.SurfaceMass -> Result String Unit.SurfaceMass
validateSurfaceMass =
    Validation.validateWithin "La masse surfacique"
        { max = Unit.maxSurfaceMass
        , min = Unit.minSurfaceMass
        , toNumber = Unit.surfaceMassInGramsPerSquareMeters
        , toString = Unit.surfaceMassInGramsPerSquareMeters >> String.fromInt
        }


validateYarnSize : Unit.YarnSize -> Result String Unit.YarnSize
validateYarnSize =
    Validation.validateWithin "Le titrage"
        { max = Unit.maxYarnSize
        , min = Unit.minYarnSize
        , toNumber = Unit.yarnSizeInKilometers
        , toString = Unit.yarnSizeInKilometers >> String.fromFloat
        }
