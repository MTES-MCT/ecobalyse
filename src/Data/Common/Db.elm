module Data.Common.Db exposing
    ( countriesFromJson
    , impactsFromJson
    , transportsFromJson
    , updateProcessesFromNewDefinitions
    )

import Data.Country as Country exposing (Country)
import Data.Impact as Impact exposing (Impacts)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Textile.Db as TextileDb
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode


impactsFromJson : String -> Result String Definitions
impactsFromJson =
    Decode.decodeString Definition.decode
        >> Result.mapError Decode.errorToString


countriesFromJson : TextileDb.Db -> String -> Result String (List Country)
countriesFromJson textile =
    Decode.decodeString (Country.decodeList textile.processes)
        >> Result.mapError Decode.errorToString


transportsFromJson : Definitions -> String -> Result String Distances
transportsFromJson definitions =
    Decode.decodeString (Transport.decodeDistances definitions)
        >> Result.mapError Decode.errorToString


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
