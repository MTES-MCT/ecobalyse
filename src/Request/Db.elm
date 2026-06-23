module Request.Db exposing
    ( DbError
    , LoadingState
    , dbErrorToString
    , fetchJson
    , getProgress
    , initLoadingState
    , updateRawJson
    )

import Data.Db as Db exposing (Db)
import Http
import RemoteData exposing (WebData)
import Request.Common as RequestCommon


type DbError
    = FetchError Http.Error
    | ParseError String


type alias LoadingState =
    Db.Properties (WebData Db.RawJsonString)


dbErrorToString : DbError -> String
dbErrorToString error =
    case error of
        FetchError httpError ->
            "Erreur de téléchargement des données\u{00A0}: " ++ RequestCommon.errorToString httpError

        ParseError message ->
            "Erreur de décodage des données\u{00A0}: " ++ message


fetchJson : String -> (WebData Db.RawJsonString -> msg) -> Cmd msg
fetchJson path event =
    Http.get
        { expect =
            Http.expectString
                (RemoteData.fromResult
                    >> RemoteData.map Db.rawJsonString
                    >> event
                )
        , url = path
        }


getProgress : LoadingState -> ( Int, Int )
getProgress state =
    ( Db.propGetters
        |> List.filter (\getter -> getter state |> RemoteData.isSuccess)
        |> List.length
    , List.length Db.propGetters
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


resolve : LoadingState -> WebData Db.RawJsonStrings
resolve data =
    RemoteData.succeed Db.Properties
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
            , Db.buildDb json
                |> Result.mapError ParseError
                |> Just
            )
