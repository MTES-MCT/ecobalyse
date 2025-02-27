module Data.Textile.Validation exposing (validate)

import Data.Component as Component
import Data.Country as Country
import Data.Env as Env
import Data.Scope as Scope
import Data.Split as Split exposing (Split)
import Data.Textile.Query exposing (Query)
import Mass exposing (Mass)
import Result.Extra as RE
import Static.Db exposing (Db)


{-| Validate a Textile Query.
Note: many fields are inherently validated by their types and/or at decoding time.
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
        |> RE.andMap (Ok query.materials)
        |> RE.andMap (Ok query.numberOfReferences)
        |> RE.andMap (Ok query.physicalDurability)
        |> RE.andMap (Ok query.price)
        |> RE.andMap (Ok query.printing)
        |> RE.andMap (Ok query.product)
        |> RE.andMap (Ok query.surfaceMass)
        |> RE.andMap (Ok query.traceability)
        |> RE.andMap (Component.validateItems db.components query.trims)
        |> RE.andMap (Ok query.upcycled)
        |> RE.andMap (Ok query.yarnSize)


validateSplitWithin : String -> { max : Split, min : Split } -> Split -> Result String Split
validateSplitWithin what { max, min } split =
    if Split.toFloat split < Split.toFloat min || Split.toFloat split > Split.toFloat max then
        Err <|
            what
                ++ " doit être compris entre "
                ++ Split.toFloatString Env.minMakingDeadStockRatio
                ++ " et "
                ++ Split.toFloatString Env.maxMakingDeadStockRatio
                ++ "."

    else
        Ok split


validateMakingDeadStock : Split -> Result String Split
validateMakingDeadStock =
    validateSplitWithin "Le taux de stocks dormants en confection"
        { max = Env.maxMakingDeadStockRatio, min = Env.minMakingDeadStockRatio }


validateMakingWaste : Split -> Result String Split
validateMakingWaste =
    validateSplitWithin "Le taux de perte en confection"
        { max = Env.minMakingWasteRatio, min = Env.minMakingWasteRatio }


validateMass : Mass -> Result String Mass
validateMass mass =
    if Mass.inKilograms mass <= 0 then
        Err "La masse doit être supérieure ou égale à zéro"

    else
        Ok mass
