module Request.Db exposing
    ( RawJsonData
    , emptyLoadingState
    , getRawJsonString
    , isFullyLoaded
    , updateRawJson
    )

import Data.Common.Db as Common
import Data.Food.Db as FoodDb
import Data.Impact as Impact
import Data.Object.Db as ObjectDb
import Data.Process as Process
import Data.Textile.Db as TextileDb
import Http exposing (Error(..))
import Json.Decode as Decode
import RemoteData exposing (WebData)
import Result.Extra as RE
import Static.Db as StaticDb exposing (Db)


type alias RawJsonData =
    { countries : WebData String
    , definitions : WebData String
    , food2Examples : WebData String
    , foodIngredients : WebData String
    , foodProductExamples : WebData String
    , objectComponents : WebData String
    , objectExamples : WebData String
    , processes : WebData String
    , textileComponents : WebData String
    , textileMaterials : WebData String
    , textileProductExamples : WebData String
    , textileProducts : WebData String
    , transports : WebData String
    , veliComponents : WebData String
    , veliExamples : WebData String
    }


emptyLoadingState : RawJsonData
emptyLoadingState =
    { countries = RemoteData.NotAsked
    , definitions = RemoteData.NotAsked
    , food2Examples = RemoteData.NotAsked
    , foodIngredients = RemoteData.NotAsked
    , foodProductExamples = RemoteData.NotAsked
    , objectComponents = RemoteData.NotAsked
    , objectExamples = RemoteData.NotAsked
    , processes = RemoteData.NotAsked
    , textileComponents = RemoteData.NotAsked
    , textileMaterials = RemoteData.NotAsked
    , textileProductExamples = RemoteData.NotAsked
    , textileProducts = RemoteData.NotAsked
    , transports = RemoteData.NotAsked
    , veliComponents = RemoteData.NotAsked
    , veliExamples = RemoteData.NotAsked
    }


buildDb : RawJsonData -> Result Http.Error (Result String StaticDb.Db)
buildDb data =
    data.processes
        |> RemoteData.map dbFromHttp
        |> RemoteData.andMap data.countries
        |> RemoteData.andMap data.definitions
        |> RemoteData.andMap data.food2Examples
        |> RemoteData.andMap data.foodIngredients
        |> RemoteData.andMap data.foodProductExamples
        |> RemoteData.andMap data.objectComponents
        |> RemoteData.andMap data.objectExamples
        |> RemoteData.andMap data.textileComponents
        |> RemoteData.andMap data.textileMaterials
        |> RemoteData.andMap data.textileProductExamples
        |> RemoteData.andMap data.textileProducts
        |> RemoteData.andMap data.transports
        |> RemoteData.andMap data.veliComponents
        |> RemoteData.andMap data.veliExamples
        |> RemoteData.toResult NetworkError


dbFromHttp : String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> Result String StaticDb.Db
dbFromHttp processesJson countriesJson definitionsJson food2ExamplesJson foodIngredientsJson foodProductExamplesJson objectComponentsJson objectExamplesJson textileComponentsJson textileMaterialsJson textileProductExamplesJson textileProductsJson transportsJson veliComponentsJson veliExamplesJson =
    processesJson
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Ok StaticDb.Db
                    |> RE.andMap
                        (StaticDb.decodeRawComponents
                            { food2Components = """[]"""
                            , objectComponents = objectComponentsJson
                            , textileComponents = textileComponentsJson
                            , veliComponents = veliComponentsJson
                            }
                        )
                    |> RE.andMap (Common.countriesFromJson processes countriesJson)
                    |> RE.andMap (Common.impactsFromJson definitionsJson)
                    |> RE.andMap (Common.transportsFromJson transportsJson)
                    |> RE.andMap
                        (processes
                            |> FoodDb.buildFromJson
                                foodProductExamplesJson
                                foodIngredientsJson
                        )
                    |> RE.andMap
                        (ObjectDb.buildFromJson
                            food2ExamplesJson
                            objectExamplesJson
                            veliExamplesJson
                        )
                    |> RE.andMap (Ok processes)
                    |> RE.andMap
                        (processes
                            |> TextileDb.buildFromJson
                                textileProductExamplesJson
                                textileMaterialsJson
                                textileProductsJson
                        )
            )


getRawJsonString : String -> (WebData String -> msg) -> Cmd msg
getRawJsonString path event =
    Http.get
        { expect = Http.expectString (RemoteData.fromResult >> event)
        , url = path
        }


isFullyLoaded : RawJsonData -> Bool
isFullyLoaded data =
    let
        isLoaded remoteData =
            case remoteData of
                RemoteData.Success _ ->
                    True

                _ ->
                    False
    in
    isLoaded data.countries
        && isLoaded data.definitions
        && isLoaded data.food2Examples
        && isLoaded data.foodIngredients
        && isLoaded data.foodProductExamples
        && isLoaded data.objectComponents
        && isLoaded data.objectExamples
        && isLoaded data.processes
        && isLoaded data.textileComponents
        && isLoaded data.textileMaterials
        && isLoaded data.textileProductExamples
        && isLoaded data.textileProducts
        && isLoaded data.transports
        && isLoaded data.veliComponents
        && isLoaded data.veliExamples



-- Ideally, we would want to return a more granular type of error in case decoding or http request fails
-- type CustomError
--     = HttpError Http.Error
--     | DecodeError Decode.Error


updateRawJson : (RawJsonData -> RawJsonData) -> RawJsonData -> ( RawJsonData, Maybe (Result Error (Result String Db)) )
updateRawJson update rawJsonData =
    let
        updated =
            update rawJsonData
    in
    if isFullyLoaded updated then
        ( updated, Just <| buildDb updated )

    else
        -- return raw data
        ( updated, Nothing )
