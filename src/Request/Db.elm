module Request.Db exposing
    ( DbError
    , LoadingState
    , dbErrorToString
    , getRawJsonString
    , initLoadingState
    , isFullyLoaded
    , updateRawJson
    )

import Data.Common.Db as Common
import Data.Food.Db as FoodDb
import Data.Impact as Impact
import Data.Object.Db as ObjectDb
import Data.Process as Process
import Data.Textile.Db as TextileDb
import Http
import Json.Decode as Decode
import RemoteData exposing (WebData)
import Request.Common as RequestCommon
import Result.Extra as RE
import Static.Db as StaticDb exposing (Db)


type DbError
    = FetchError Http.Error
    | ParseError String


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


buildDb : RawJsonStrings -> Result String StaticDb.Db
buildDb json =
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


dbErrorToString : DbError -> String
dbErrorToString error =
    case error of
        FetchError httpError ->
            "Erreur de téléchargement des données\u{00A0}: " ++ RequestCommon.errorToString httpError

        ParseError message ->
            "Erreur de décodage des données\u{00A0}: " ++ message


getRawJsonString : String -> (WebData String -> msg) -> Cmd msg
getRawJsonString path event =
    Http.get
        { expect = Http.expectString (RemoteData.fromResult >> event)
        , url = path
        }


isFullyLoaded : LoadingState -> Bool
isFullyLoaded =
    resolve >> RemoteData.isSuccess


initLoadingState : LoadingState
initLoadingState =
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


resolve : LoadingState -> RemoteData.WebData RawJsonStrings
resolve data =
    RemoteData.succeed Properties
        |> RemoteData.andMap data.countries
        |> RemoteData.andMap data.definitions
        |> RemoteData.andMap data.food2Examples
        |> RemoteData.andMap data.foodIngredients
        |> RemoteData.andMap data.foodProductExamples
        |> RemoteData.andMap data.objectComponents
        |> RemoteData.andMap data.objectExamples
        |> RemoteData.andMap data.processes
        |> RemoteData.andMap data.textileComponents
        |> RemoteData.andMap data.textileMaterials
        |> RemoteData.andMap data.textileProductExamples
        |> RemoteData.andMap data.textileProducts
        |> RemoteData.andMap data.transports
        |> RemoteData.andMap data.veliComponents
        |> RemoteData.andMap data.veliExamples


updateRawJson : (LoadingState -> LoadingState) -> LoadingState -> ( LoadingState, Maybe (Result DbError Db) )
updateRawJson update loadingState =
    let
        updated =
            update loadingState
    in
    case resolve updated of
        RemoteData.Failure error ->
            ( updated, Just <| Err (FetchError error) )

        RemoteData.Loading ->
            ( updated, Nothing )

        RemoteData.NotAsked ->
            ( updated, Nothing )

        RemoteData.Success json ->
            ( updated
            , buildDb json
                |> Result.mapError ParseError
                |> Just
            )
