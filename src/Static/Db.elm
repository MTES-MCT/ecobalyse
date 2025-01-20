module Static.Db exposing
    ( Db
    , db
    , scopedComponents
    , scopedProcesses
    )

import Data.Common.Db as Common
import Data.Component exposing (Component)
import Data.Country exposing (Country)
import Data.Food.Db as FoodDb
import Data.Impact as Impact
import Data.Impact.Definition exposing (Definitions)
import Data.Object.Db as ObjectDb
import Data.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Data.Textile.Db as TextileDb
import Data.Transport exposing (Distances)
import Json.Decode as Decode
import Result.Extra as RE
import Static.Json as StaticJson


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
db =
    decodeRawProcesses
        >> Result.andThen
            (\processes ->
                Ok Db
                    |> RE.andMap (Ok [])
                    |> RE.andMap (countries processes)
                    |> RE.andMap impactDefinitions
                    |> RE.andMap distances
                    |> RE.andMap
                        (processes
                            |> FoodDb.buildFromJson
                                StaticJson.foodProductExamplesJson
                                StaticJson.foodIngredientsJson
                        )
                    |> RE.andMap
                        (ObjectDb.buildFromJson
                            StaticJson.objectComponentsJson
                            StaticJson.objectExamplesJson
                        )
                    |> RE.andMap (Ok processes)
                    |> RE.andMap
                        (processes
                            |> TextileDb.buildFromJson
                                StaticJson.textileComponentsJson
                                StaticJson.textileProductExamplesJson
                                StaticJson.textileMaterialsJson
                                StaticJson.textileProductsJson
                        )
            )


decodeRawProcesses : StaticJson.RawJsonProcesses -> Result String (List Process)
decodeRawProcesses { foodProcesses, objectProcesses, textileProcesses } =
    [ ( foodProcesses, [ Scope.Food ] )
    , ( objectProcesses, [ Scope.Object, Scope.Veli ] )
    , ( textileProcesses, [ Scope.Textile ] )
    ]
        |> List.map (\( json, scopes ) -> decodeScopedProcesses scopes json)
        |> RE.combine
        |> Result.map List.concat


decodeScopedProcesses : List Scope -> String -> Result String (List Process)
decodeScopedProcesses scopes =
    Decode.decodeString (Process.decodeList scopes Impact.decodeImpacts)
        >> Result.mapError Decode.errorToString


impactDefinitions : Result String Definitions
impactDefinitions =
    Common.impactsFromJson StaticJson.impactsJson


countries : List Process -> Result String (List Country)
countries processes =
    Common.countriesFromJson processes StaticJson.countriesJson


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
scopedProcesses scope _ =
    case scope of
        Scope.Food ->
            []

        Scope.Object ->
            -- FIXME
            []

        Scope.Textile ->
            []

        Scope.Veli ->
            -- FIXME
            []
