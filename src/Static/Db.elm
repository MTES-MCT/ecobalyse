module Static.Db exposing
    ( Db
    , db
    , decodeRawJsonProcesses
    )

import Data.Common.Db as Common
import Data.Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Impact.Definition exposing (Definitions)
import Data.Object.Db as ObjectDb
import Data.Textile.Db as TextileDb
import Data.Transport exposing (Distances)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Result.Extra as RE
import Static.Json as StaticJson exposing (RawJsonProcesses)


type alias Db =
    { countries : List Country
    , definitions : Definitions
    , distances : Distances
    , food : FoodDb.Db
    , object : ObjectDb.Db
    , textile : TextileDb.Db
    }


db : StaticJson.RawJsonProcesses -> Result String Db
db procs =
    StaticJson.db procs
        |> Result.andThen
            (\{ foodDb, objectDb, textileDb } ->
                Ok Db
                    |> RE.andMap (countries textileDb)
                    |> RE.andMap impactDefinitions
                    |> RE.andMap distances
                    |> RE.andMap (Ok foodDb)
                    |> RE.andMap (Ok objectDb)
                    |> RE.andMap (Ok textileDb)
            )


decodeRawJsonProcesses : Decoder RawJsonProcesses
decodeRawJsonProcesses =
    Decode.succeed RawJsonProcesses
        |> JDP.required "foodProcesses" Decode.string
        |> JDP.required "objectProcesses" Decode.string
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
