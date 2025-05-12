module Static.Db exposing
    ( Db
    , db
    )

import Data.Common.Db as Common
import Data.Component as Component exposing (Component)
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


db : String -> Result String Db
db =
    Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        >> Result.mapError Decode.errorToString
        >> Result.andThen
            (\processes ->
                Ok Db
                    |> RE.andMap (decodeRawComponents StaticJson.rawJsonComponents)
                    |> RE.andMap (countries processes)
                    |> RE.andMap impactDefinitions
                    |> RE.andMap distances
                    |> RE.andMap
                        (processes
                            |> FoodDb.buildFromJson
                                StaticJson.foodProductExamplesJson
                                StaticJson.foodIngredientsJson
                        )
                    |> RE.andMap (ObjectDb.buildFromJson StaticJson.objectExamplesJson)
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
decodeRawComponents { objectComponents, textileComponents } =
    [ ( objectComponents, [ Scope.Object, Scope.Veli ] )
    , ( textileComponents, [ Scope.Textile ] )
    ]
        |> List.map (\( json, scopes ) -> decodeScopedComponents scopes json)
        |> RE.combine
        |> Result.map List.concat


decodeScopedComponents : List Scope -> String -> Result String (List Component)
decodeScopedComponents scopes =
    Component.decodeListFromJsonString scopes


impactDefinitions : Result String Definitions
impactDefinitions =
    Common.impactsFromJson StaticJson.impactsJson


countries : List Process -> Result String (List Country)
countries processes =
    Common.countriesFromJson processes StaticJson.countriesJson


distances : Result String Distances
distances =
    Common.transportsFromJson StaticJson.transportsJson
