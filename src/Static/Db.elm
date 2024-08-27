module Static.Db exposing
    ( Db
    , db
    , decodeRawJsonProcesses
    )

import Data.Common.Db as Common
import Data.Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Db as TextileDb
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
