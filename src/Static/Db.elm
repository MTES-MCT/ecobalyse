module Static.Db exposing (Db, rdb, updateEcotoxWeighting)

import Data.Common.Db as Common
import Data.Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Impact as Impact
import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Db as TextileDb
import Data.Textile.Process as Textile
import Data.Transport exposing (Distances)
import Data.Unit as Unit
import Static.Json exposing (countriesJson, foodIngredientsJson, foodProcessesJson, impactsJson, textileJson, transportsJson)


type alias Db =
    { definitions : Definitions
    , textile : TextileDb.Db
    , food : FoodDb.Db
    , countries : List Country
    , distances : Distances
    }


rdb : Result String Db
rdb =
    Result.map5 Db rdefinitions rtextile rfood rcountries rdistances


rdefinitions : Result String Definitions
rdefinitions =
    Common.impactsFromJson impactsJson


rtextile : Result String TextileDb.Db
rtextile =
    rdefinitions
        |> Result.andThen
            (\definitions ->
                TextileDb.buildFromJson definitions textileJson
            )


rfood : Result String FoodDb.Db
rfood =
    rdefinitions
        |> Result.andThen
            (\definitions ->
                FoodDb.buildFromJson definitions foodProcessesJson foodIngredientsJson
            )


rcountries : Result String (List Country)
rcountries =
    rtextile |> Result.andThen (\textile -> Common.countriesFromJson textile countriesJson)


rdistances : Result String Distances
rdistances =
    Common.transportsFromJson transportsJson


updateEcotoxWeighting : Db -> Unit.Ratio -> Db
updateEcotoxWeighting db weighting =
    updateImpactDefinitions db (Impact.setEcotoxWeighting weighting db.definitions)


{-| Update database with new definitions and recompute processes aggregated impacts accordingly.
-}
updateImpactDefinitions : Db -> Definitions -> Db
updateImpactDefinitions ({ textile, food } as db) definitions =
    let
        updatedFoodProcesses =
            Common.updateProcessesFromNewDefinitions definitions db.food.processes

        updatedTextileProcesses =
            Common.updateProcessesFromNewDefinitions definitions db.textile.processes
    in
    { db
        | definitions = definitions
        , countries = db.countries |> updateCountriesFromNewProcesses updatedTextileProcesses
        , textile =
            { textile
                | processes = updatedTextileProcesses
                , materials = TextileDb.updateMaterialsFromNewProcesses updatedTextileProcesses textile.materials
                , products = TextileDb.updateProductsFromNewProcesses updatedTextileProcesses textile.products
                , wellKnown = TextileDb.updateWellKnownFromNewProcesses updatedTextileProcesses textile.wellKnown
            }
        , food =
            { food
                | processes = updatedFoodProcesses
                , ingredients = FoodDb.updateIngredientsFromNewProcesses updatedFoodProcesses db.food.ingredients
                , wellKnown = FoodDb.updateWellKnownFromNewProcesses updatedFoodProcesses food.wellKnown
            }
    }


updateCountriesFromNewProcesses : List Textile.Process -> List Country -> List Country
updateCountriesFromNewProcesses processes =
    List.map
        (\country ->
            Result.map2
                (\electricityProcess heatProcess ->
                    { country
                        | electricityProcess = electricityProcess
                        , heatProcess = heatProcess
                    }
                )
                (Textile.findByUuid country.electricityProcess.uuid processes)
                (Textile.findByUuid country.heatProcess.uuid processes)
                |> Result.withDefault country
        )
