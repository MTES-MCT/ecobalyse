module Data.Component.ProductCategory exposing
    ( Id
    , ProductCategory
    , decodeId
    , decodeListFromJsonString
    , encodeId
    , findById
    , findByScope
    , idFromString
    , idToString
    , toSearchableString
    )

import Data.Common.DecodeUtils as DU
import Data.Process as Process
import Data.Scope as Scope
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type Id
    = Id Uuid


{-| A generic product category, providing sensible defaults for common characteristics
like transport cooling and distribution process.
-}
type alias ProductCategory =
    { cooling : Bool
    , distribution : Maybe Process.Id
    , id : Id
    , label : String
    , scope : Scope.GenericScope
    }


decode : Decoder ProductCategory
decode =
    Decode.succeed ProductCategory
        |> Pipe.required "cooling" Decode.bool
        |> DU.strictOptional "distribution" Process.decodeId
        |> Pipe.required "id" decodeId
        |> Pipe.required "label" Decode.string
        |> Pipe.required "scope" Scope.decodeGeneric


decodeId : Decoder Id
decodeId =
    Decode.map Id Uuid.decoder


decodeList : Decoder (List ProductCategory)
decodeList =
    Decode.list decode


decodeListFromJsonString : String -> Result String (List ProductCategory)
decodeListFromJsonString =
    Decode.decodeString decodeList
        >> Result.mapError Decode.errorToString


encodeId : Id -> Encode.Value
encodeId (Id uuid) =
    Uuid.encoder uuid


findById : Id -> List ProductCategory -> Result String ProductCategory
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Catégorie de produit introuvable id=" ++ idToString id ++ ".")


findByScope : Scope.GenericScope -> List ProductCategory -> List ProductCategory
findByScope genericScope =
    List.filter (.scope >> (==) genericScope)


idFromString : String -> Result String Id
idFromString =
    Uuid.fromString >> Result.map Id


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


toSearchableString : ProductCategory -> String
toSearchableString product =
    String.join " "
        [ idToString product.id
        , product.label
        , Scope.toStringGeneric product.scope
        ]
