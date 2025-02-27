module Data.Textile.Validation exposing (validate)

import Data.Country as Country
import Data.Scope exposing (Scope)
import Data.Textile.Query exposing (Query)
import Result.Extra as RE
import Static.Db exposing (Db)


validate : Db -> Scope -> Query -> Result String Query
validate db scope query =
    let
        validateMaybeCountry =
            Maybe.map (Country.validateForScope scope db.countries >> Result.map Just)
                >> Maybe.withDefault (Ok Nothing)
    in
    Ok Query
        |> RE.andMap (Ok query.airTransportRatio)
        |> RE.andMap (Ok query.business)
        |> RE.andMap (validateMaybeCountry query.countryDyeing)
        |> RE.andMap (validateMaybeCountry query.countryFabric)
        |> RE.andMap (validateMaybeCountry query.countryMaking)
        |> RE.andMap (validateMaybeCountry query.countrySpinning)
        |> RE.andMap (Ok query.disabledSteps)
        |> RE.andMap (Ok query.dyeingProcessType)
        |> RE.andMap (Ok query.fabricProcess)
        |> RE.andMap (Ok query.fading)
        |> RE.andMap (Ok query.makingComplexity)
        |> RE.andMap (Ok query.makingDeadStock)
        |> RE.andMap (Ok query.makingWaste)
        |> RE.andMap (Ok query.mass)
        |> RE.andMap (Ok query.materials)
        |> RE.andMap (Ok query.numberOfReferences)
        |> RE.andMap (Ok query.physicalDurability)
        |> RE.andMap (Ok query.price)
        |> RE.andMap (Ok query.printing)
        |> RE.andMap (Ok query.product)
        |> RE.andMap (Ok query.surfaceMass)
        |> RE.andMap (Ok query.traceability)
        |> RE.andMap (Ok query.trims)
        |> RE.andMap (Ok query.upcycled)
        |> RE.andMap (Ok query.yarnSize)
