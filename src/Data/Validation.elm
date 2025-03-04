module Data.Validation exposing
    ( Errors
    , encodeErrors
    , fromDecodingError
    , fromErrorString
    , optional
    , required
    )

import Data.Common.DecodeUtils as DecodeUtils
import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Encode as Encode


type alias FieldName =
    String


type alias ErrorMessage =
    String


type alias Errors =
    Dict FieldName ErrorMessage


encodeErrors : Errors -> Encode.Value
encodeErrors =
    Encode.dict identity Encode.string


fromDecodingError : Decode.Error -> Errors
fromDecodingError =
    DecodeUtils.betterErrorToString >> Dict.singleton "decoding"


fromErrorString : String -> Errors
fromErrorString =
    Dict.singleton "general"


{-| Denote that validation should only be performed if a value is actually provided
-}
optional : String -> Maybe a -> (a -> Result String a) -> Result Errors (Maybe a -> b) -> Result Errors b
optional key maybeValue validator =
    maybeValue
        |> Maybe.map (validator >> Result.map Just)
        |> Maybe.withDefault (Ok Nothing)
        |> required key


{-| Denote a required value to validate
-}
required : String -> Result String a -> Result Errors (a -> b) -> Result Errors b
required key result accumulator =
    case ( result, accumulator ) of
        ( Ok _, Err accFn ) ->
            Err accFn

        ( Err error, Err accFn ) ->
            accFn
                |> Dict.union (Dict.singleton key error)
                |> Err

        ( valueOrError, Ok accFn ) ->
            valueOrError
                |> Result.mapError (Dict.singleton key)
                |> Result.map accFn
