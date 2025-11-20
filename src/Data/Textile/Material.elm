module Data.Textile.Material exposing
    ( CFFData
    , Id(..)
    , Material
    , decodeId
    , decodeList
    , encode
    , encodeId
    , findById
    , getRecyclingData
    , idFromString
    , idToString
    )

import Data.GeoZone as GeoZone
import Data.Process as Process exposing (Process)
import Data.Split as Split exposing (Split)
import Data.Textile.Material.Origin as Origin exposing (Origin)
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Material =
    { alias : String
    , cffData : Maybe CFFData
    , defaultGeoZone : GeoZone.Code -- Default geographical zone for Material and Spinning steps
    , geographicOrigin : String -- A textual information about the geographic origin of the material
    , id : Id
    , name : String
    , origin : Origin
    , process : Process
    , recycledFrom : Maybe Id
    }


type Id
    = Id Uuid



---- Recycling


type alias CFFData =
    -- Circular Footprint Formula data
    { manufacturerAllocation : Split
    , recycledQualityRatio : Split
    }


decodeId : Decoder Id
decodeId =
    Decode.map Id Uuid.decoder


encodeId : Id -> Encode.Value
encodeId (Id uuid) =
    Uuid.encoder uuid


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


idFromString : String -> Result String Id
idFromString =
    Uuid.fromString >> Result.map Id


getRecyclingData : Material -> List Material -> Maybe ( Material, CFFData )
getRecyclingData material materials =
    -- If material is non-recycled, retrieve relevant recycled equivalent material & CFF data
    Maybe.map2 Tuple.pair
        (material.recycledFrom
            |> Maybe.andThen
                (\materialId ->
                    findById materialId materials
                        |> Result.toMaybe
                )
        )
        material.cffData



---- Helpers

findById : Id -> List Material -> Result String Material
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Matière non trouvée id=" ++ idToString id ++ ".")


decode : List Process -> Decoder Material
decode processes =
    Decode.succeed Material
        |> JDP.required "alias" Decode.string
        |> JDP.required "cff" (Decode.maybe decodeCFFData)
        |> JDP.required "defaultGeoZone" (Decode.string |> Decode.map GeoZone.codeFromString)
        |> JDP.required "geographicOrigin" Decode.string
        |> JDP.required "id" decodeId
        |> JDP.required "name" Decode.string
        |> JDP.required "origin" Origin.decode
        |> JDP.required "processId" (Process.decodeFromId processes)
        |> JDP.required "recycledFrom" (Decode.maybe decodeId)


decodeCFFData : Decoder CFFData
decodeCFFData =
    Decode.succeed CFFData
        |> JDP.required "manufacturerAllocation" Split.decodeFloat
        |> JDP.required "recycledQualityRatio" Split.decodeFloat


decodeList : List Process -> Decoder (List Material)
decodeList processes =
    Decode.list (decode processes)


encode : Material -> Encode.Value
encode v =
    Encode.object
        [ ( "alias", Encode.string v.alias )
        , ( "defaultGeoZone", v.defaultGeoZone |> GeoZone.codeToString |> Encode.string )
        , ( "id", encodeId v.id )
        , ( "geographicOrigin", Encode.string v.geographicOrigin )
        , ( "name", v.name |> Encode.string )
        , ( "origin", v.origin |> Origin.toString |> Encode.string )
        , ( "processId", Process.encodeId v.process.id )
        , ( "recycledFrom", v.recycledFrom |> Maybe.map encodeId |> Maybe.withDefault Encode.null )
        ]
