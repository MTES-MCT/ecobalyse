module Data.Object.Process exposing
    ( Id(..)
    , Process
    , decodeId
    , decodeList
    , encode
    , findById
    , idFromString
    , idToString
    )

import Data.Common.DecodeUtils as DU
import Data.Impact as Impact exposing (Impacts)
import Data.Split as Split exposing (Split)
import Data.Uuid as Uuid exposing (Uuid)
import Energy exposing (Energy)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Json.Encode.Extra as EncodeExtra


type Id
    = Id Uuid


type alias Process =
    { alias : Maybe String
    , comment : String
    , density : Float
    , displayName : String
    , elec : Energy
    , heat : Energy
    , id : Id
    , impacts : Impacts
    , name : String
    , source : String
    , unit : String
    , waste : Split
    }


decodeProcess : Decoder Impact.Impacts -> Decoder Process
decodeProcess impactsDecoder =
    Decode.succeed Process
        |> DU.strictOptional "alias" Decode.string
        |> Pipe.required "comment" Decode.string
        |> Pipe.required "density" Decode.float
        |> Pipe.required "displayName" Decode.string
        |> Pipe.required "elec_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "heat_MJ" (Decode.map Energy.megajoules Decode.float)
        |> Pipe.required "id" decodeId
        |> Pipe.required "impacts" impactsDecoder
        |> Pipe.required "name" Decode.string
        |> Pipe.required "source" Decode.string
        |> Pipe.required "unit" Decode.string
        |> Pipe.required "waste" Split.decodeFloat


decodeId : Decoder Id
decodeId =
    Decode.map Id Uuid.decoder


decodeList : Decoder Impact.Impacts -> Decoder (List Process)
decodeList impactsDecoder =
    Decode.list (decodeProcess impactsDecoder)


encode : Process -> Encode.Value
encode process =
    Encode.object
        [ ( "alias", EncodeExtra.maybe Encode.string process.alias )
        , ( "comment", Encode.string process.comment )
        , ( "density", Encode.float process.density )
        , ( "displayName", Encode.string process.displayName )
        , ( "elec_MJ", Encode.float (Energy.inMegajoules process.elec) )
        , ( "heat_MJ", Encode.float (Energy.inMegajoules process.heat) )
        , ( "id", encodeId process.id )
        , ( "impacts", Impact.encode process.impacts )
        , ( "name", Encode.string process.name )
        , ( "source", Encode.string process.source )
        , ( "unit", Encode.string process.unit )
        , ( "waste", Split.encodeFloat process.waste )
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
