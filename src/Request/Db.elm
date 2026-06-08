module Request.Db exposing
    ( RawJsonData
    , emptyLoadingState
    , getRawJsonString
    , updateRawJson
    )

import Http
import RemoteData exposing (WebData)
import Static.Db as StaticDb


type alias RawJsonData =
    { components : WebData String
    , definitions : WebData String
    , processes : WebData String
    }


emptyLoadingState : RawJsonData
emptyLoadingState =
    { components = RemoteData.NotAsked
    , definitions = RemoteData.NotAsked
    , processes = RemoteData.NotAsked
    }


buildDb : RawJsonData -> Result String StaticDb.Db
buildDb data =
    data.processes
        |> RemoteData.map (\processes definitions -> StaticDb.db processes)
        |> RemoteData.andMap data.definitions
        |> RemoteData.withDefault (Err "Error getting the remote data")


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
    isLoaded data.definitions && isLoaded data.processes


updateRawJson : (RawJsonData -> RawJsonData) -> RawJsonData -> RawJsonData
updateRawJson update rawJsonData =
    let
        updated =
            update rawJsonData
    in
    -- TODO: check fully loaded state
    if isFullyLoaded updated then
        -- TODO: construct and return Just the constructed Db
        let
            _ =
                Debug.log "DB built" <| buildDb updated
        in
        updated

    else
        -- return raw data
        updated
