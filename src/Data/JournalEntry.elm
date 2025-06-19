module Data.JournalEntry exposing
    ( JournalEntry
    , actionToString
    , decodeEntry
    , idToString
    )

import Data.User as User exposing (User)
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline as JDP
import Time exposing (Posix)


type Id
    = Id Uuid


type Action
    = Created
    | Deleted
    | Updated


type alias JournalEntry a =
    { action : Action
    , createdAt : Posix
    , id : Id
    , recordId : Uuid
    , tableName : String
    , updatedAt : Posix
    , user : User
    , value : a
    }


actionToString : Action -> String
actionToString action =
    case action of
        Created ->
            "Création"

        Deleted ->
            "Suppression"

        Updated ->
            "Modification"


decodeEntry : Decoder a -> Decoder (JournalEntry a)
decodeEntry valueDecoder =
    Decode.succeed JournalEntry
        |> JDP.required "action" (Decode.string |> Decode.andThen decodeAction)
        |> JDP.required "createdAt" DE.datetime
        |> JDP.required "id" decodeId
        |> JDP.required "recordId" Uuid.decoder
        |> JDP.required "tableName" Decode.string
        |> JDP.required "updatedAt" DE.datetime
        |> JDP.required "user" User.decodeUser
        |> JDP.required "value" valueDecoder


decodeAction : String -> Decoder Action
decodeAction action =
    case action of
        "created" ->
            Decode.succeed Created

        "updated" ->
            Decode.succeed Updated

        "deleted" ->
            Decode.succeed Deleted

        _ ->
            Decode.fail <| "Action invalide\u{00A0}: " ++ action


decodeId : Decoder Id
decodeId =
    Decode.map Id Uuid.decoder


idToString : Id -> String
idToString (Id id) =
    Uuid.toString id
