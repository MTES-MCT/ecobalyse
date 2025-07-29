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
import Data.Uuid as Uuid exposing (Uuid)


type alias Material =
    { alias : String
    , cffData : Maybe CFFData
    , defaultCountry : Country.Code -- Default country for Material and Spinning steps
    , geographicOrigin : String -- A textual information about the geographic origin of the material
    , id : Id
    , process : Process
    , name : String
    , origin : Origin
    , recycledFrom : Maybe String
    , recycledProcess : Maybe Process
    , shortName : String
    }


type Id
    = Id Uuid



---- Recycling


type alias CFFData =
    -- Circular Footprint Formula data
    { manufacturerAllocation : Split
    , recycledQualityRatio : Split
    }

decodeId: Decoder Id
decodeId =
    Decode.map Id Uuid.decoder

encodeId : Id -> Encode.Value
encodeId( Id uuid) =
    Uuid.encoder uuid

idToString: Id -> String
idToString(Id uuid) = Uuid.toString uuid

idFromString : String -> Result String Id
idFromString =
    Uuid.fromString >> Result.map Id

getRecyclingData : Material -> List Material -> Maybe ( Material, CFFData )
getRecyclingData material materials =
    -- If material is non-recycled, retrieve relevant recycled equivalent material & CFF data
    Maybe.map2 Tuple.pair
        (material.recycledFrom
            |> Maybe.andThen
                (\alias ->
                    findByAlias alias materials
                        |> Result.toMaybe
                )
        )
        material.cffData


---- Helpers

findByAlias : String -> List Material -> Result String Material
findByAlias alias =
    List.filter (.alias >> (==) alias)
        >> List.head
        >> Result.fromMaybe ("Matière non trouvée alias=" ++ alias ++ ".")

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
        |> JDP.required "defaultCountry" (Decode.string |> Decode.map Country.codeFromString)
        |> JDP.required "geographicOrigin" Decode.string
        |> JDP.required "id" decodeId
        |> JDP.required "processId" (Process.decodeFromId processes)
        |> JDP.required "name" Decode.string
        |> JDP.required "origin" Origin.decode
        |> JDP.required "recycledFrom" (Decode.maybe Decode.string)
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
        , ("alias", Encode.string v.alias)
        , ( "name", v.name |> Encode.string )
        , ( "shortName", Encode.string v.shortName )
        , ( "origin", v.origin |> Origin.toString |> Encode.string )
        , ( "processId", Process.encodeId v.process.id )
        , ( "recycledProcessUuid"
          , v.recycledProcess |> Maybe.map (.id >> Process.encodeId) |> Maybe.withDefault Encode.null
          )
        , ( "recycledFrom", v.recycledFrom |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        , ( "geographicOrigin", Encode.string v.geographicOrigin )
        , ( "defaultCountry", v.defaultCountry |> Country.codeToString |> Encode.string )

        ]
