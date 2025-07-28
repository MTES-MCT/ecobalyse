module Data.Textile.Material exposing
    ( CFFData
    , Id(..)
    , Material
    , decodeList
    , encode
    , encodeId
    , findById
    , getRecyclingData
    , idToString
    )

import Data.Common.DecodeUtils as DU
import Data.Country as Country
import Data.Process as Process exposing (Process)
import Data.Split as Split exposing (Split)
import Data.Textile.Material.Origin as Origin exposing (Origin)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type alias Material =
    { cffData : Maybe CFFData
    , defaultCountry : Country.Code -- Default country for Material and Spinning steps
    , geographicOrigin : String -- A textual information about the geographic origin of the material
    , id : Id
    , name : String
    , origin : Origin
    , recycledFrom : Maybe Id
    , recycledProcess : Maybe Process
    , processId : Process.Id
    , shortName : String
    }


type Id
    = Id String



---- Recycling


type alias CFFData =
    -- Circular Footprint Formula data
    { manufacturerAllocation : Split
    , recycledQualityRatio : Split
    }


getRecyclingData : Material -> List Material -> Maybe ( Material, CFFData )
getRecyclingData material materials =
    -- If material is non-recycled, retrieve relevant recycled equivalent material & CFF data
    Maybe.map2 Tuple.pair
        (material.recycledFrom
            |> Maybe.andThen
                (\id ->
                    findById id materials
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
        |> JDP.required "cff" (Decode.maybe decodeCFFData)
        |> JDP.required "defaultCountry" (Decode.string |> Decode.map Country.codeFromString)
        |> JDP.required "geographicOrigin" Decode.string
        |> JDP.required "id" (Decode.map Id Decode.string)
        |> JDP.required "name" Decode.string
        |> JDP.required "origin" Origin.decode
        |> JDP.required "recycledFrom" (Decode.maybe (Decode.map Id Decode.string))
        |> DU.strictOptional "recycledProcessUuid" (Process.decodeFromId processes)
        |> JDP.required "shortName" Decode.string


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
        [ ( "id", encodeId v.id )
        , ( "name", v.name |> Encode.string )
        , ( "shortName", Encode.string v.shortName )
        , ( "origin", v.origin |> Origin.toString |> Encode.string )
        , ( "recycledProcessUuid"
          , v.recycledProcess |> Maybe.map (.id >> Process.encodeId) |> Maybe.withDefault Encode.null
          )
        , ( "recycledFrom", v.recycledFrom |> Maybe.map encodeId |> Maybe.withDefault Encode.null )
        , ( "geographicOrigin", Encode.string v.geographicOrigin )
        , ( "defaultCountry", v.defaultCountry |> Country.codeToString |> Encode.string )
        ]


encodeId : Id -> Encode.Value
encodeId =
    idToString >> Encode.string


idToString : Id -> String
idToString (Id string) =
    string
