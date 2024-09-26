module Data.Object.Process exposing
    ( Id
    , Process
    , decodeId
    , decodeList
    , encode
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
        |> Pipe.required "density" Decode.float
        |> Pipe.required "display_name" Decode.string
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
