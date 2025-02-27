module Data.Textile.Validation exposing (validate)

import Data.Component as Component
import Data.Country as Country
import Data.Env as Env
import Data.Scope exposing (Scope)
import Data.Split as Split exposing (Split)
import Data.Textile.Query exposing (Query)
import Mass exposing (Mass)
import Result.Extra as RE
import Static.Db exposing (Db)


validate : Db -> Scope -> Query -> Result String Query
validate db scope query =
    let
        validateMaybe fn =
            Maybe.map (fn >> Result.map Just)
                >> Maybe.withDefault (Ok Nothing)
    in
    Ok Query
        |> RE.andMap (Ok query.airTransportRatio)
        |> RE.andMap (Ok query.business)
        |> RE.andMap (query.countryDyeing |> validateMaybe (Country.validateForScope scope db.countries))
        |> RE.andMap (query.countryFabric |> validateMaybe (Country.validateForScope scope db.countries))
        |> RE.andMap (query.countryMaking |> validateMaybe (Country.validateForScope scope db.countries))
        |> RE.andMap (query.countrySpinning |> validateMaybe (Country.validateForScope scope db.countries))
        |> RE.andMap (Ok query.disabledSteps)
        |> RE.andMap (Ok query.dyeingProcessType)
        |> RE.andMap (Ok query.fabricProcess)
        |> RE.andMap (Ok query.fading)
        |> RE.andMap (Ok query.makingComplexity)
        |> RE.andMap (Ok query.makingDeadStock)
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


validateMakingWaste : Split -> Result String Split
validateMakingWaste waste =
    if
        (Split.toFloat waste < Split.toFloat Env.minMakingWasteRatio)
            || (Split.toFloat waste > Split.toFloat Env.maxMakingWasteRatio)
    then
        Err <|
            "Le taux de perte en confection doit être compris entre "
                ++ Split.toFloatString Env.minMakingWasteRatio
                ++ " et "
                ++ Split.toFloatString Env.maxMakingWasteRatio
                ++ "."

    else
        Ok waste


validateMass : Mass -> Result String Mass
validateMass mass =
    if Mass.inKilograms mass <= 0 then
        Err "La masse doit être supérieure ou égale à zéro"

    else
        Ok mass
