module Static.Db exposing
    ( Db
    , db
    )

import Data.Common.Db as Common
import Data.Component as Component exposing (Component)
import Data.GeoZone exposing (GeoZone)
import Data.Food.Db as FoodDb
import Data.Impact as Impact
import Data.Impact.Definition exposing (Definitions)
import Data.Object.Db as ObjectDb
import Data.Process as Process exposing (Process)
import Data.Textile.Db as TextileDb
import Data.Transport exposing (Distances)
import Json.Decode as Decode
import Result.Extra as RE
import Static.Json as StaticJson


type alias Db =
    { components : List Component
    , definitions : Definitions
    , distances : Distances
    , food : FoodDb.Db
    , geoZones : List GeoZone
    , object : ObjectDb.Db
    , processes : List Process
    , textile : TextileDb.Db
    }


db : String -> Result String Db
db =
    Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        >> Result.mapError Decode.errorToString
        >> Result.andThen
            (\processes ->
                Ok Db
                    |> RE.andMap (decodeRawComponents StaticJson.rawJsonComponents)
                    |> RE.andMap impactDefinitions
                    |> RE.andMap distances
                    |> RE.andMap
                        (processes
                            |> FoodDb.buildFromJson
                                StaticJson.foodProductExamplesJson
                                StaticJson.foodIngredientsJson
                        )
                    |> RE.andMap (geoZones processes)
                    |> RE.andMap
                        (ObjectDb.buildFromJson
                            StaticJson.objectExamplesJson
                            StaticJson.veliExamplesJson
                        )
                    |> RE.andMap (Ok processes)
                    |> RE.andMap
                        (processes
                            |> TextileDb.buildFromJson
                                StaticJson.textileProductExamplesJson
                                StaticJson.textileMaterialsJson
                                StaticJson.textileProductsJson
                        )
            )


decodeRawComponents : StaticJson.RawJsonComponents -> Result String (List Component)
decodeRawComponents { objectComponents, textileComponents, veliComponents } =
    [ objectComponents, textileComponents, veliComponents ]
        |> List.map decodeScopedComponents
        |> RE.combine
        |> Result.map List.concat


decodeScopedComponents : String -> Result String (List Component)
decodeScopedComponents =
    Component.decodeListFromJsonString


impactDefinitions : Result String Definitions
impactDefinitions =
    Common.impactsFromJson StaticJson.impactsJson


geoZones : List Process -> Result String (List GeoZone)
geoZones processes =
    Common.geoZonesFromJson processes StaticJson.geoZonesJson


distances : Result String Distances
distances =
    Common.transportsFromJson StaticJson.transportsJson
