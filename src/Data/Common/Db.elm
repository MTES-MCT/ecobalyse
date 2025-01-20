module Data.Common.Db exposing
    ( countriesFromJson
    , impactsFromJson
    , transportsFromJson
    )

import Data.Country as Country exposing (Country)
import Data.Impact.Definition as Definition exposing (Definitions)
import Data.Process exposing (Process)
import Data.Transport as Transport exposing (Distances)
import Json.Decode as Decode


impactsFromJson : String -> Result String Definitions
impactsFromJson =
    Decode.decodeString Definition.decode
        >> Result.mapError Decode.errorToString


countriesFromJson : List Process -> String -> Result String (List Country)
countriesFromJson processes =
    Decode.decodeString (Country.decodeList processes)
        >> Result.mapError Decode.errorToString


transportsFromJson : String -> Result String Distances
transportsFromJson =
    Decode.decodeString Transport.decodeDistances
        >> Result.mapError Decode.errorToString
