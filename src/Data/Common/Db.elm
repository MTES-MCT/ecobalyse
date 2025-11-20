module Data.Common.Db exposing
    ( geoZonesFromJson
    , impactsFromJson
    , transportsFromJson
    )

import Data.GeoZone as GeoZone exposing (GeoZone)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Process exposing (Process)
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode


impactsFromJson : String -> Result String Definitions
impactsFromJson =
    Decode.decodeString Definition.decode
        >> Result.mapError Decode.errorToString


geoZonesFromJson : List Process -> String -> Result String (List GeoZone)
geoZonesFromJson processes =
    Decode.decodeString (GeoZone.decodeList processes)
        >> Result.mapError Decode.errorToString


transportsFromJson : String -> Result String Distances
transportsFromJson =
    Decode.decodeString Transport.decodeDistances
        >> Result.mapError Decode.errorToString
