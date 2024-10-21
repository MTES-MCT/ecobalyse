module Data.Object.Process exposing
    ( Id(..)
    , Process
    , decodeId
    , decodeList
    , encode
    , encodeId
    , findById
    , idFromString
    , idToString
    )

import Data.Impact as Impact exposing (Impacts)
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type Id
    = Id Uuid


type alias Process =
    { comment : String
    , density : Float
    , displayName : String
    , id : Id
    , impacts : Impacts
    , name : String
    , source : String
    , unit : String
    }


decodeProcess : Decoder Impact.Impacts -> Decoder Process
decodeProcess impactsDecoder =
    Decode.succeed Process
        |> Pipe.required "comment" Decode.string
<<<<<<< HEAD
        |> Pipe.required "density" Decode.float
        |> Pipe.required "displayName" Decode.string
=======
        |> Pipe.optional "density" Decode.float 1
        |> Pipe.required "display_name" Decode.string
>>>>>>> master
        |> Pipe.required "id" decodeId
        |> Pipe.required "impacts" impactsDecoder
        |> Pipe.required "name" Decode.string
        |> Pipe.required "source" Decode.string
        |> Pipe.required "unit" Decode.string


decodeId : Decoder Id
decodeId =
    Decode.map Id Uuid.decoder


decodeList : Decoder Impact.Impacts -> Decoder (List Process)
decodeList impactsDecoder =
    Decode.list (decodeProcess impactsDecoder)


encode : Process -> Encode.Value
encode process =
    Encode.object
        [ ( "comment", Encode.string process.comment )
        , ( "density", Encode.float process.density )
        , ( "displayName", Encode.string process.displayName )
        , ( "id", encodeId process.id )
        , ( "impacts", Impact.encode process.impacts )
        , ( "name", Encode.string process.name )
        , ( "source", Encode.string process.source )
        , ( "unit", Encode.string process.unit )
        ]


encodeId : Id -> Encode.Value
encodeId (Id uuid) =
    Uuid.encoder uuid


findById : List Process -> Id -> Result String Process
findById processes id =
    processes
        |> List.filter (.id >> (==) id)
        |> List.head
        |> Result.fromMaybe ("Procédé introuvable par id : " ++ idToString id)


idFromString : String -> Maybe Id
idFromString =
    Uuid.fromString >> Maybe.map Id


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid
