module Data.Common.Db exposing
    ( geozonesFromJson
    , impactsFromJson
    , transportsFromJson
    )

import Data.Geozone as Geozone exposing (Geozone)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Process exposing (Process)
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode


impactsFromJson : String -> Result String Definitions
impactsFromJson =
    Decode.decodeString Definition.decode
        >> Result.mapError Decode.errorToString


geozonesFromJson : List Process -> String -> Result String (List Geozone)
geozonesFromJson processes =
    Decode.decodeString (Geozone.decodeList processes)
        >> Result.mapError Decode.errorToString


transportsFromJson : String -> Result String Distances
transportsFromJson =
    Decode.decodeString Transport.decodeDistances
        >> Result.mapError Decode.errorToString
