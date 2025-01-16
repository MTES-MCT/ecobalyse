module Static.Db exposing
    ( Db
    , db
    , decodeRawJsonProcesses
    , scopedComponents
    , scopedProcesses
    )

import Data.Common.Db as Common
import Data.Component exposing (Component)
import Data.Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Impact.Definition exposing (Definitions)
import Data.Object.Db as ObjectDb
import Data.Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Db as TextileDb
import Data.Transport exposing (Distances)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Result.Extra as RE
import Static.Json as StaticJson exposing (RawJsonProcesses)


type alias Db =
    { components : List Component
    , countries : List Country
    , definitions : Definitions
    , distances : Distances
    , food : FoodDb.Db
    , object : ObjectDb.Db
    , processes : List Process
    , textile : TextileDb.Db
    }


db : StaticJson.RawJsonProcesses -> Result String Db
db procs =
    StaticJson.db procs
        |> Result.andThen
            (\{ foodDb, objectDb, textileDb } ->
                Ok Db
                    |> RE.andMap (Ok [])
                    |> RE.andMap (countries textileDb)
                    |> RE.andMap impactDefinitions
                    |> RE.andMap distances
                    |> RE.andMap (Ok foodDb)
                    |> RE.andMap (Ok objectDb)
                    |> RE.andMap (Ok [])
                    |> RE.andMap (Ok textileDb)
            )
        |> Result.map
            (\db_ ->
                { db_
                    | components =
                        List.concat
                            [ db_.object.components
                            , db_.textile.components
                            ]
                    , processes =
                        List.concat
                            [ db_.food.processes
                            , db_.object.processes
                            , db_.textile.processes
                            ]
                }
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


scopedComponents : Scope -> Db -> List Component
scopedComponents scope { object, textile } =
    case scope of
        Scope.Food ->
            -- Note: we don't have any food components yet
            []

        Scope.Object ->
            object.components

        Scope.Textile ->
            textile.components

        Scope.Veli ->
            object.components


scopedProcesses : Scope -> Db -> List Process
scopedProcesses scope { food, object, textile } =
    case scope of
        Scope.Food ->
            food.processes

        Scope.Object ->
            object.processes

        Scope.Textile ->
            textile.processes

        Scope.Veli ->
            object.processes
