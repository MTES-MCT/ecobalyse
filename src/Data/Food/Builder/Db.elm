module Data.Food.Builder.Db exposing
    ( Db
    , buildFromJson
    )

import Data.Country exposing (Country)
import Data.Food.Ingredient as Ingredient exposing (Ingredient)
import Data.Food.Process as Process exposing (Process)
import Data.Impact as Impact
import Data.Textile.Db as TextileDb
import Data.Transport as Transport
import Json.Decode as Decode
import Json.Decode.Extra as DE


type alias Db =
    { -- Common datasources
      countries : List Country
    , impacts : List Impact.Definition
    , transports : Transport.Distances

    -- Builder specific datasources
    -- Builder Processes are straightforward imports of public/data/food/processes/builder.json
    , processes : List Process

    -- Ingredients are imported from public/data/food/ingredients.json
    , ingredients : List Ingredient
    , wellKnown : Process.WellKnown
    }


buildFromJson : TextileDb.Db -> String -> String -> Result String Db
buildFromJson { countries, transports, impacts } builderProcessesJson ingredientsJson =
    builderProcessesJson
        |> Decode.decodeString (Process.decodeList impacts)
        |> Result.andThen
            (\processes ->
                ingredientsJson
                    |> Decode.decodeString
                        (Ingredient.decodeIngredients processes
                            |> Decode.andThen
                                (\ingredients ->
                                    Process.loadWellKnown processes
                                        |> Result.map (Db countries impacts transports processes ingredients)
                                        |> DE.fromResult
                                )
                        )
            )
        |> Result.mapError Decode.errorToString
