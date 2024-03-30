module Static.Db exposing
    ( Db
    , db
    , processes
    , updateEcotoxWeighting
    , updateFoodDb
    , updateTextileDb
    )

import Data.Common.Db as Common
import Data.Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Impact as Impact
import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Db as TextileDb
import Data.Textile.Process as Textile
import Data.Transport exposing (Distances)
import Data.Unit as Unit
import Static.Json as StaticJson


type alias Db =
    { definitions : Definitions
    , textile : TextileDb.Db
    , food : FoodDb.Db
    , countries : List Country
    , distances : Distances
    }


db : StaticJson.Processes -> Result String Db
db procs =
    StaticJson.db procs
        |> Result.andThen
            (\{ foodDb, textileDb } ->
                Result.map3
                    (\okImpactDefinitions okCountries okDistances ->
                        Db okImpactDefinitions textileDb foodDb okCountries okDistances
                    )
                    impactDefinitions
                    (countries textileDb)
                    distances
            )


impactDefinitions : Result String Definitions
impactDefinitions =
    Common.impactsFromJson StaticJson.impactsJson


processes : StaticJson.Processes
processes =
    StaticJson.processes


countries : TextileDb.Db -> Result String (List Country)
countries textileDb =
    Common.countriesFromJson textileDb StaticJson.countriesJson


distances : Result String Distances
distances =
    Common.transportsFromJson StaticJson.transportsJson


updateFoodDb : (FoodDb.Db -> FoodDb.Db) -> Db -> Db
updateFoodDb update ({ food } as db_) =
    { db_ | food = update food }


updateTextileDb : (TextileDb.Db -> TextileDb.Db) -> Db -> Db
updateTextileDb update ({ textile } as db_) =
    { db_ | textile = update textile }


updateEcotoxWeighting : Db -> Unit.Ratio -> Db
updateEcotoxWeighting db_ weighting =
    updateImpactDefinitions db_ (Impact.setEcotoxWeighting weighting db_.definitions)


{-| Update database with new definitions and recompute processes aggregated impacts accordingly.
-}
updateImpactDefinitions : Db -> Definitions -> Db
updateImpactDefinitions ({ textile, food } as db_) definitions =
    let
        updatedFoodProcesses =
            Common.updateProcessesFromNewDefinitions definitions db_.food.processes

        updatedTextileProcesses =
            Common.updateProcessesFromNewDefinitions definitions db_.textile.processes
    in
    { db_
        | definitions = definitions
        , countries = db_.countries |> updateCountriesFromNewProcesses updatedTextileProcesses
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
                , ingredients = FoodDb.updateIngredientsFromNewProcesses updatedFoodProcesses db_.food.ingredients
                , wellKnown = FoodDb.updateWellKnownFromNewProcesses updatedFoodProcesses food.wellKnown
            }
    }


updateCountriesFromNewProcesses : List Textile.Process -> List Country -> List Country
updateCountriesFromNewProcesses processList =
    List.map
        (\country ->
            Result.map2
                (\electricityProcess heatProcess ->
                    { country
                        | electricityProcess = electricityProcess
                        , heatProcess = heatProcess
                    }
                )
                (Textile.findByUuid country.electricityProcess.uuid processList)
                (Textile.findByUuid country.heatProcess.uuid processList)
                |> Result.withDefault country
        )
