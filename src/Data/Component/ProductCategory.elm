module Data.Component.ProductCategory exposing
    ( Id
    , ProductCategory
    , decodeId
    , decodeListFromJsonString
    , encode
    , encodeId
    , findById
    , findByScope
    , idFromString
    , idToString
    , toSearchableString
    )

import Data.Common.DecodeUtils as DU
import Data.Common.EncodeUtils as EU
import Data.Component.Consumption as Consumption exposing (Consumption)
import Data.Process as Process
import Data.Scope as Scope
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type Id
    = Id Uuid


{-| A generic product category, providing sensible defaults for common characteristics
like assembly processes, transport cooling, distribution process and use-stage consumptions.
-}
type alias ProductCategory =
    { assembly : List Process.Id
    , consumptions : List Consumption
    , cooling : Bool
    , distribution : Maybe Process.Id
    , id : Id
    , label : String
    , scope : Scope.GenericScope
    }


decode : Decoder ProductCategory
decode =
    Decode.succeed ProductCategory
        |> DU.strictOptionalWithDefault "assembly" (Decode.list Process.decodeId) []
        |> DU.strictOptionalWithDefault "consumptions" (Decode.list Consumption.decode) []
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


encode : ProductCategory -> Encode.Value
encode product =
    EU.optionalPropertiesObject
        [ ( "id", encodeId product.id |> Just )
        , ( "label", Encode.string product.label |> Just )
        , ( "assembly"
          , if List.isEmpty product.assembly then
                Nothing

            else
                Encode.list Process.encodeId product.assembly |> Just
          )
        , ( "consumptions"
          , if List.isEmpty product.consumptions then
                Nothing

            else
                Encode.list Consumption.encode product.consumptions |> Just
          )
        , ( "cooling", Encode.bool product.cooling |> Just )
        , ( "distribution", product.distribution |> Maybe.map Process.encodeId )
        ]


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
