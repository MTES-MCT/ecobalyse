module Request.Db exposing
    ( DbError
    , LoadingState
    , RawJsonString
    , dbErrorToString
    , fetchJson
    , getProgress
    , initLoadingState
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


type RawJsonString
    = RawJsonString String


type alias RawJsonStrings =
    Properties RawJsonString


buildDb : RawJsonStrings -> Result String StaticDb.Db
buildDb json =
    extractJsonString json.processes
        |> Decode.decodeString (Process.decodeList Impact.decodeImpacts)
        |> Result.mapError Decode.errorToString
        |> Result.andThen
            (\processes ->
                Ok StaticDb.Db
                    |> RE.andMap
                        (StaticDb.decodeRawComponents
                            { food2Components = """[]"""
                            , objectComponents = extractJsonString json.objectComponents
                            , textileComponents = extractJsonString json.textileComponents
                            , veliComponents = extractJsonString json.veliComponents
                            }
                        )
                    |> RE.andMap (Common.countriesFromJson processes <| extractJsonString json.countries)
                    |> RE.andMap (Common.impactsFromJson <| extractJsonString json.definitions)
                    |> RE.andMap (Common.transportsFromJson <| extractJsonString json.transports)
                    |> RE.andMap
                        (processes
                            |> FoodDb.buildFromJson
                                (extractJsonString json.foodProductExamples)
                                (extractJsonString json.foodIngredients)
                        )
                    |> RE.andMap
                        (ObjectDb.buildFromJson
                            (extractJsonString json.food2Examples)
                            (extractJsonString json.objectExamples)
                            (extractJsonString json.veliExamples)
                        )
                    |> RE.andMap (Ok processes)
                    |> RE.andMap
                        (processes
                            |> TextileDb.buildFromJson
                                (extractJsonString json.textileProductExamples)
                                (extractJsonString json.textileMaterials)
                                (extractJsonString json.textileProducts)
                        )
            )


dbErrorToString : DbError -> String
dbErrorToString error =
    case error of
        FetchError httpError ->
            "Erreur de téléchargement des données\u{00A0}: " ++ RequestCommon.errorToString httpError

        ParseError message ->
            "Erreur de décodage des données\u{00A0}: " ++ message


extractJsonString : RawJsonString -> String
extractJsonString (RawJsonString string) =
    string


fetchJson : String -> (WebData RawJsonString -> msg) -> Cmd msg
fetchJson path event =
    Http.get
        { expect =
            Http.expectString
                (RemoteData.fromResult
                    >> RemoteData.map RawJsonString
                    >> event
                )
        , url = path
        }


getProgress : LoadingState -> ( Int, Int )
getProgress state =
    ( propGetters
        |> List.filter (\getter -> getter state |> RemoteData.isSuccess)
        |> List.length
    , List.length propGetters
    )


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


propGetters : List (Properties a -> a)
propGetters =
    [ .countries
    , .definitions
    , .food2Examples
    , .foodIngredients
    , .foodProductExamples
    , .objectComponents
    , .objectExamples
    , .processes
    , .textileComponents
    , .textileMaterials
    , .textileProductExamples
    , .textileProducts
    , .transports
    , .veliComponents
    , .veliExamples
    ]


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
