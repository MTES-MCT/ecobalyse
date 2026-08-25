module Data.Component.ProductCategory exposing
    ( DefaultConsumption
    , Id
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
import Data.Component.Amount as Amount exposing (Amount)
import Data.Process as Process
import Data.Scope as Scope
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode


type Id
    = Id Uuid


{-| A default use-stage consumption for a product category.

JSON may be a process id string, or an object with `processId` and optional `amount`.
When `amount` is omitted, the process is treated as product-mass-dependent.

-}
type alias DefaultConsumption =
    { amount : Maybe Amount
    , processId : Process.Id
    }


{-| A generic product category, providing sensible defaults for common characteristics
like transport cooling, distribution process and use-stage consumptions.
-}
type alias ProductCategory =
    { consumptions : List DefaultConsumption
    , cooling : Bool
    , distribution : Maybe Process.Id
    , id : Id
    , label : String
    , scope : Scope.GenericScope
    }


decode : Decoder ProductCategory
decode =
    Decode.succeed ProductCategory
        |> DU.strictOptionalWithDefault "consumptions" (Decode.list decodeDefaultConsumption) []
        |> Pipe.required "cooling" Decode.bool
        |> DU.strictOptional "distribution" Process.decodeId
        |> Pipe.required "id" decodeId
        |> Pipe.required "label" Decode.string
        |> Pipe.required "scope" Scope.decodeGeneric


{-| accepts either a long or a short form for JSON def

  - long form: consumptions: [{ "processId": "<uuid1>" }, { "processId": "<uuid2>" }, …]
  -            consumptions: [{ "processId": "<uuid1>", "amount": 1 }, { "processId": "<uuid2>", "amount": 2 }, …]
  - short form: consumptions: ["<uuid1>", "<uuid2>", …]

-}
decodeDefaultConsumption : Decoder DefaultConsumption
decodeDefaultConsumption =
    Decode.oneOf
        [ Decode.succeed DefaultConsumption
            |> DU.strictOptional "amount" Amount.decode
            |> Pipe.required "processId" Process.decodeId
        , Process.decodeId
            |> Decode.map (\processId -> { amount = Nothing, processId = processId })
        ]


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
