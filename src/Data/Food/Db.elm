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
            db.processes |> updateProcessesFromNewDefinitions definitions
    in
    { db
        | impactDefinitions = definitions
        , processes = updatedProcesses
        , countries = textileCountries
        , ingredients = db.ingredients |> updateIngredientsFromNewProcesses updatedProcesses
        , wellKnown = db.wellKnown |> updateWellKnownFromNewProcesses updatedProcesses
    }


{-| Update processes with new impact definitions, ensuring recomputing aggregated impacts.
-}
updateProcessesFromNewDefinitions : Definitions -> List Process -> List Process
updateProcessesFromNewDefinitions definitions =
    List.map
        (\({ impacts } as process) ->
            { process
                | impacts =
                    impacts
                        |> Impact.updateAggregatedScores definitions
            }
        )


updateIngredientsFromNewProcesses : List Process -> List Ingredient -> List Ingredient
updateIngredientsFromNewProcesses processes =
    List.map
        (\ingredient ->
            processes
                |> Process.findByIdentifier (Process.codeFromString ingredient.default.id_)
                |> Result.map (\default -> { ingredient | default = default })
                |> Result.withDefault ingredient
        )


updateWellKnownFromNewProcesses : List Process -> WellKnown -> WellKnown
updateWellKnownFromNewProcesses processes =
    Process.mapWellKnown
        (\({ id_ } as process) ->
            processes
                |> Process.findByIdentifier (Process.codeFromString id_)
                |> Result.withDefault process
        )
