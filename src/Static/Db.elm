module Static.Db exposing
    ( Db
    , db
    , decodeRawJsonProcesses
    , updateProcesses
    )

import Data.Common.Db as Common
import Data.Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Food.Process as FoodProcess
import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Db as TextileDb
import Data.Textile.Process as TextileProcess
import Data.Transport exposing (Distances)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Static.Json as StaticJson exposing (RawJsonProcesses)


type alias Db =
    { definitions : Definitions
    , textile : TextileDb.Db
    , food : FoodDb.Db
    , countries : List Country
    , distances : Distances
    }


db : StaticJson.RawJsonProcesses -> Result String Db
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


decodeRawJsonProcesses : Decoder RawJsonProcesses
decodeRawJsonProcesses =
    Decode.succeed RawJsonProcesses
        |> JDP.required "foodProcesses" Decode.string
        |> JDP.required "textileProcesses" Decode.string


impactDefinitions : Result String Definitions
impactDefinitions =
    Common.impactsFromJson StaticJson.impactsJson


countries : TextileDb.Db -> Result String (List Country)
countries textileDb =
    Common.countriesFromJson textileDb StaticJson.countriesJson


distances : Result String Distances
distances =
    Common.transportsFromJson StaticJson.transportsJson


updateProcesses : List FoodProcess.Process -> List TextileProcess.Process -> Db -> Db
updateProcesses foodProcesses textileProcesses ({ textile, food } as db_) =
    { db_
        | countries = db_.countries |> updateCountriesFromNewProcesses textileProcesses
        , textile =
            { textile
                | processes = textileProcesses
                , materials = TextileDb.updateMaterialsFromNewProcesses textileProcesses textile.materials
                , products = TextileDb.updateProductsFromNewProcesses textileProcesses textile.products
                , wellKnown = TextileDb.updateWellKnownFromNewProcesses textileProcesses textile.wellKnown
            }
        , food =
            { food
                | processes = foodProcesses
                , ingredients = FoodDb.updateIngredientsFromNewProcesses foodProcesses db_.food.ingredients
                , wellKnown = FoodDb.updateWellKnownFromNewProcesses foodProcesses food.wellKnown
            }
    }


updateCountriesFromNewProcesses : List TextileProcess.Process -> List Country -> List Country
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
                (TextileProcess.findByUuid country.electricityProcess.uuid processList)
                (TextileProcess.findByUuid country.heatProcess.uuid processList)
                |> Result.withDefault country
        )
