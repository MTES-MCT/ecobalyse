module Static.Db exposing (Db, rdb, updateEcotoxWeighting)

import Data.Common.Db as Common
import Data.Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Food.Ingredient exposing (Ingredient)
import Data.Food.Process as Food
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Db as TextileDb
import Data.Textile.Material exposing (Material)
import Data.Textile.Process as Textile
import Data.Textile.Product exposing (Product)
import Data.Transport exposing (Distances)
import Data.Unit as Unit
import Static.Json exposing (countriesJson, foodIngredientsJson, foodProcessesJson, impactsJson, textileJson, transportsJson)



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


updateEcotoxWeighting : Db -> Unit.Ratio -> Db
updateEcotoxWeighting db weighting =
    let
        definitions =
            -- Note: food and textile db impact definitions are the same data
            db.definitions
                |> Impact.setEcotoxWeighting weighting
    in
    updateImpactDefinitions db definitions


{-| Update database with new definitions and recompute processes aggregated impacts accordingly.
-}
updateImpactDefinitions : Db -> Definitions -> Db
updateImpactDefinitions ({ textile, food } as db) definitions =
    let
        updatedFoodProcesses =
            updateProcessesFromNewDefinitions definitions db.food.processes

        updatedTextileProcesses =
            updateProcessesFromNewDefinitions definitions db.textile.processes
    in
    { db
        | definitions = definitions
        , countries = db.countries |> updateCountriesFromNewProcesses updatedTextileProcesses
        , textile =
            { textile
                | processes = updatedTextileProcesses
                , materials = updateMaterialsFromNewProcesses updatedTextileProcesses textile.materials
                , products = updateProductsFromNewProcesses updatedTextileProcesses textile.products
                , wellKnown = updateTextileWellKnownFromNewProcesses updatedTextileProcesses textile.wellKnown
            }
        , food =
            { food
                | processes = updatedFoodProcesses
                , ingredients = updateIngredientsFromNewProcesses updatedFoodProcesses db.food.ingredients
                , wellKnown = updateFoodWellKnownFromNewProcesses updatedFoodProcesses food.wellKnown
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


{-| Update processes with new impact definitions, ensuring recomputing aggregated impacts.
-}
updateProcessesFromNewDefinitions : Definitions -> List { p | impacts : Impacts } -> List { p | impacts : Impacts }
updateProcessesFromNewDefinitions definitions =
    List.map
        (\({ impacts } as process) ->
            { process
                | impacts =
                    impacts
                        |> Impact.updateAggregatedScores definitions
            }
        )


updateIngredientsFromNewProcesses : List Food.Process -> List Ingredient -> List Ingredient
updateIngredientsFromNewProcesses processes =
    List.map
        (\ingredient ->
            processes
                |> Food.findByIdentifier (Food.codeFromString ingredient.default.id_)
                |> Result.map (\default -> { ingredient | default = default })
                |> Result.withDefault ingredient
        )


updateFoodWellKnownFromNewProcesses : List Food.Process -> Food.WellKnown -> Food.WellKnown
updateFoodWellKnownFromNewProcesses processes =
    Food.mapWellKnown
        (\({ id_ } as process) ->
            processes
                |> Food.findByIdentifier (Food.codeFromString id_)
                |> Result.withDefault process
        )


updateTextileWellKnownFromNewProcesses : List Textile.Process -> Textile.WellKnown -> Textile.WellKnown
updateTextileWellKnownFromNewProcesses processes =
    Textile.mapWellKnown
        (\({ uuid } as process) ->
            processes
                |> Textile.findByUuid uuid
                |> Result.withDefault process
        )


updateMaterialsFromNewProcesses : List Textile.Process -> List Material -> List Material
updateMaterialsFromNewProcesses processes =
    List.map
        (\material ->
            Result.map2
                (\materialProcess maybeRecycledProcess ->
                    { material
                        | materialProcess = materialProcess
                        , recycledProcess = maybeRecycledProcess
                    }
                )
                (Textile.findByUuid material.materialProcess.uuid processes)
                (material.recycledProcess
                    |> Maybe.map (\{ uuid } -> processes |> Textile.findByUuid uuid |> Result.map Just)
                    |> Maybe.withDefault (Ok Nothing)
                )
                |> Result.withDefault material
        )


updateProductsFromNewProcesses : List Textile.Process -> List Product -> List Product
updateProductsFromNewProcesses processes =
    List.map
        (\({ use } as product) ->
            Result.map2
                (\ironingProcess nonIroningProcess ->
                    { product
                        | use =
                            { use
                                | ironingProcess = ironingProcess
                                , nonIroningProcess = nonIroningProcess
                            }
                    }
                )
                (Textile.findByUuid product.use.ironingProcess.uuid processes)
                (Textile.findByUuid product.use.nonIroningProcess.uuid processes)
                |> Result.withDefault product
        )
