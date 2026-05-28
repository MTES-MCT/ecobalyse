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
    { definitions : WebData String
    , processes : WebData String
    }


emptyLoadingState : RawJsonData
emptyLoadingState =
    { definitions = RemoteData.NotAsked
    , processes = RemoteData.NotAsked
    }


load : WebData RawJsonData
load =
    RemoteData.succeed RawJsonData
        |> RemoteData.andMap (RemoteData.succeed "")
        |> RemoteData.andMap (RemoteData.succeed "")


getRawJsonString : String -> (WebData String -> msg) -> Cmd msg
getRawJsonString path event =
    Http.get
        { expect = Http.expectString (RemoteData.fromResult >> event)
        , url = path
        }


updateRawJson : (RawJsonData -> RawJsonData) -> RawJsonData -> ( RawJsonData, Maybe StaticDb.Db )
updateRawJson update rawJsonData =
    let
        updated =
            update rawJsonData
    in
    -- TODO: check fully loaded state
    if isFullyLoaded updated then
        -- TODO: construct and return Just the constructed Db
        ( updated, Nothing )

    else
        -- return raw data
        ( updated, Nothing )
