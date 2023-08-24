module Data.Food.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Country exposing (Country)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
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

    -- Builder specific datasources
    -- Builder Processes are straightforward imports of public/data/food/processes.json
    , processes : List Process

    -- Ingredients are imported from public/data/food/ingredients.json
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
