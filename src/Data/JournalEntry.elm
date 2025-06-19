module Data.JournalEntry exposing
    ( JournalEntry
    , decodeEntry
    , idToString
    )

import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP


type Id
    = Id Uuid


type alias JournalEntry a =
    { action : String
    , id : Id
    , recordId : Uuid
    , tableName : String
    , value : a
    }


decodeEntry : Decoder a -> Decoder (JournalEntry a)
decodeEntry valueDecoder =
    Decode.succeed JournalEntry
        |> JDP.required "action" Decode.string
        |> JDP.required "id" decodeId
        |> JDP.required "recordId" Uuid.decoder
        |> JDP.required "tableName" Decode.string
        |> JDP.required "value" valueDecoder


decodeId : Decoder Id
decodeId =
    Decode.map Id Uuid.decoder


idToString : Id -> String
idToString (Id id) =
    Uuid.toString id
