module Request.Db exposing
    ( DbError
    , LoadingState
    , dbErrorToString
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
import Request.Common as RequestCommon
import Result.Extra as RE
import Static.Db as StaticDb exposing (Db)


type alias Properties a =
    { countries : a
    , definitions : a
    , food2Examples : a
    , foodIngredients : a
    , foodProductExamples : a
    , objectComponents : a
    , objectExamples : a
    , processes : a
    , textileComponents : a
    , textileMaterials : a
    , textileProductExamples : a
    , textileProducts : a
    , transports : a
    , veliComponents : a
    , veliExamples : a
    }


type alias LoadingState =
    Properties (WebData RawJsonString)


type alias RawJsonString =
    String


type alias RawJsonStrings =
    Properties String


type DbError
    = DecodeError String
    | FetchError Http.Error


emptyLoadingState : LoadingState
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


{-| Build a RawJsonStrings record from a LoadingState.
-}
resolve : LoadingState -> RemoteData.WebData RawJsonStrings
resolve data =
    RemoteData.succeed Properties
        |> RemoteData.andMap data.processes
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


buildDb : LoadingState -> Result DbError StaticDb.Db
buildDb data =
    RemoteData.succeed dbFromJsonStrings
        |> RemoteData.andMap data.processes
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
        |> Result.mapError FetchError
        |> Result.andThen (Result.mapError DecodeError)


dbErrorToString : DbError -> String
dbErrorToString error =
    case error of
        DecodeError message ->
            message

        FetchError httpError ->
            "Erreur de chargement des données distantes\u{202F}: " ++ RequestCommon.errorToString httpError


dbFromJsonStrings : String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> Result String StaticDb.Db
dbFromJsonStrings processesJson countriesJson definitionsJson food2ExamplesJson foodIngredientsJson foodProductExamplesJson objectComponentsJson objectExamplesJson textileComponentsJson textileMaterialsJson textileProductExamplesJson textileProductsJson transportsJson veliComponentsJson veliExamplesJson =
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


dbFromRawJsonStrings : RawJsonStrings -> Result String StaticDb.Db
dbFromRawJsonStrings json =
    json.processes
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Ok StaticDb.Db
                    |> RE.andMap
                        (StaticDb.decodeRawComponents
                            { food2Components = """[]"""
                            , objectComponents = json.objectComponents
                            , textileComponents = json.textileComponents
                            , veliComponents = json.veliComponents
                            }
                        )
                    |> RE.andMap (Common.countriesFromJson processes json.countries)
                    |> RE.andMap (Common.impactsFromJson json.definitions)
                    |> RE.andMap (Common.transportsFromJson json.transports)
                    |> RE.andMap
                        (processes
                            |> FoodDb.buildFromJson
                                json.foodProductExamples
                                json.foodIngredients
                        )
                    |> RE.andMap
                        (ObjectDb.buildFromJson
                            json.food2Examples
                            json.objectExamples
                            json.veliExamples
                        )
                    |> RE.andMap (Ok processes)
                    |> RE.andMap
                        (processes
                            |> TextileDb.buildFromJson
                                json.textileProductExamples
                                json.textileMaterials
                                json.textileProducts
                        )
            )


getRawJsonString : String -> (WebData String -> msg) -> Cmd msg
getRawJsonString path event =
    Http.get
        { expect = Http.expectString (RemoteData.fromResult >> event)
        , url = path
        }


isFullyLoaded : LoadingState -> Bool
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


updateRawJson : (LoadingState -> LoadingState) -> LoadingState -> ( LoadingState, Maybe (Result DbError Db) )
updateRawJson update loadingState =
    let
        updated =
            update loadingState
    in
    if isFullyLoaded updated then
        ( updated, Just <| buildDb updated )

    else
        -- return raw data
        ( updated, Nothing )
