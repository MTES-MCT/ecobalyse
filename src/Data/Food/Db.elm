module Data.Food.Db exposing
    ( Db
    , buildFromJson
    , updateImpactDefinitions
    )

import Data.Country exposing (Country)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process, WellKnown)
import Data.Impact as Impact
import Data.Impact.Definition exposing (Definitions)
import Data.Textile.Db as TextileDb
import Data.Transport as Transport
import Json.Decode as Decode
import Json.Decode.Extra as DE


type alias Db =
    { -- Common datasources
      impactDefinitions : Definitions
    , countries : List Country
    , transports : Transport.Distances

    -- Food specific datasources
    , processes : List Process
    , ingredients : List Ingredient
    , wellKnown : Process.WellKnown
    }


buildFromJson : TextileDb.Db -> String -> String -> Result String Db
buildFromJson { impactDefinitions, countries, transports } foodProcessesJson ingredientsJson =
    foodProcessesJson
        |> Decode.decodeString (Process.decodeList impactDefinitions)
        |> Result.andThen
            (\processes ->
                ingredientsJson
                    |> Decode.decodeString
                        (Ingredient.decodeIngredients processes
                            |> Decode.andThen
                                (\ingredients ->
                                    Process.loadWellKnown processes
                                        |> Result.map (Db impactDefinitions countries transports processes ingredients)
                                        |> DE.fromResult
                                )
                        )
            )
        |> Result.mapError Decode.errorToString


{-| Update database with new definitions and recompute processes aggregated impacts accordingly.
-}
updateImpactDefinitions : List Country -> Definitions -> Db -> Db
updateImpactDefinitions textileCountries definitions db =
    let
        updatedProcesses =
            db.processes |> updateProcesses definitions
    in
    { db
        | impactDefinitions = definitions
        , processes = updatedProcesses
        , countries = textileCountries
        , ingredients = db.ingredients |> updateIngredients updatedProcesses
        , wellKnown = db.wellKnown |> updateWellKnown updatedProcesses
    }


updateProcesses : Definitions -> List Process -> List Process
updateProcesses definitions =
    List.map
        (\({ impacts } as process) ->
            { process
                | impacts =
                    impacts
                        |> Impact.updateAggregatedScores definitions
            }
        )


updateIngredients : List Process -> List Ingredient -> List Ingredient
updateIngredients processes =
    List.map
        (\ingredient ->
            Result.map (\default -> { ingredient | default = default })
                (Process.findByIdentifier (Process.codeFromString ingredient.default.id_) processes)
                |> Result.withDefault ingredient
        )


updateWellKnown : List Process -> WellKnown -> WellKnown
updateWellKnown processes =
    Process.mapWellKnown
        (\({ id_ } as process) ->
            Process.findByIdentifier (Process.codeFromString id_) processes
                |> Result.withDefault process
        )
