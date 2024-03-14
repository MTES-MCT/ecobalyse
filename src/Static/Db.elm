module Static.Db exposing
    ( Db
    , db
    , updateEcotoxWeighting
    , updateFoodDb
    , updateTextileDb
    )

import Data.Common.Db as Common
import Data.Country exposing (Country)
import Data.Example as Example
import Data.Food.Db as FoodDb
import Data.Food.Query as FoodQuery
import Data.Impact as Impact
import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Db as TextileDb
import Data.Textile.Process as Textile
import Data.Textile.Query as TextileQuery
import Data.Transport exposing (Distances)
import Data.Unit as Unit
import Static.Json
    exposing
        ( countriesJson
        , foodIngredientsJson
        , foodProcessesJson
        , foodProductExamplesJson
        , impactsJson
        , textileMaterialsJson
        , textileProcessesJson
        , textileProductExamplesJson
        , textileProductsJson
        , transportsJson
        )


type alias Db =
    { definitions : Definitions
    , textile : TextileDb.Db
    , food : FoodDb.Db
    , countries : List Country
    , distances : Distances
    }


db : Result String Db
db =
    Result.map5 Db impactDefinitions textileDb foodDb countries distances


impactDefinitions : Result String Definitions
impactDefinitions =
    Common.impactsFromJson impactsJson


textileDb : Result String TextileDb.Db
textileDb =
    impactDefinitions
        |> Result.andThen
            (\definitions ->
                textileProductExamplesJson
                    |> Example.decodeListFromJsonString TextileQuery.decode
                    |> Result.andThen
                        (\exampleProducts ->
                            TextileDb.buildFromJson exampleProducts
                                definitions
                                textileMaterialsJson
                                textileProcessesJson
                                textileProductsJson
                        )
            )


foodDb : Result String FoodDb.Db
foodDb =
    impactDefinitions
        |> Result.andThen
            (\definitions ->
                foodProductExamplesJson
                    |> Example.decodeListFromJsonString FoodQuery.decode
                    |> Result.andThen
                        (\examples ->
                            FoodDb.buildFromJson examples
                                definitions
                                foodProcessesJson
                                foodIngredientsJson
                        )
            )


countries : Result String (List Country)
countries =
    textileDb
        |> Result.andThen (\textile -> Common.countriesFromJson textile countriesJson)


distances : Result String Distances
distances =
    Common.transportsFromJson transportsJson


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
