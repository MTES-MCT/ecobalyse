module Data.Component.Product exposing
    ( Id(..)
    , Product
    , decodeId
    , decodeListFromJsonString
    , findById
    , findByScope
    , idFromString
    , idToString
    , toLabel
    )

import Data.Common.DecodeUtils as DU
import Data.Process as Process
import Data.Scope as Scope exposing (Scope)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe


type Id
    = Id String


{-| A generic product category, providing sensible defaults for common characteristics
like transport cooling and distribution process.
-}
type alias Product =
    { cooling : Bool
    , distribution : Maybe Process.Id
    , id : Id
    , label : String
    , scope : Scope
    }


decode : Decoder Product
decode =
    Decode.succeed Product
        |> Pipe.required "cooling" Decode.bool
        |> DU.strictOptional "distribution" Process.decodeId
        |> Pipe.required "id" decodeId
        |> Pipe.required "label" Decode.string
        |> Pipe.required "scope" Scope.decode


decodeId : Decoder Id
decodeId =
    Decode.map Id Decode.string


decodeList : Decoder (List Product)
decodeList =
    Decode.list decode


decodeListFromJsonString : String -> Result String (List Product)
decodeListFromJsonString =
    Decode.decodeString decodeList
        >> Result.mapError Decode.errorToString


findById : Id -> List Product -> Result String Product
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Catégorie de produit introuvable id=" ++ idToString id ++ ".")


findByScope : Scope -> List Product -> List Product
findByScope scope =
    List.filter (.scope >> (==) scope)


idFromString : String -> Id
idFromString =
    Id


idToString : Id -> String
idToString (Id string) =
    string


toLabel : Product -> String
toLabel =
    .label
