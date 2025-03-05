module Data.Validation exposing
    ( Errors
    , encodeErrors
    , fromDecodingError
    , fromErrorString
    , list
    , maybe
    , nonEmptyList
    , validate
    , validateWithin
    )

import Data.Common.DecodeUtils as DecodeUtils
import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Encode as Encode
import Result.Extra as RE


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


list : String -> List a -> (a -> Result String a) -> Result Errors (List a -> b) -> Result Errors b
list key list_ validator =
    list_
        |> List.map validator
        |> RE.combine
        |> validate key


nonEmptyList : String -> List a -> (a -> Result String a) -> Result Errors (List a -> b) -> Result Errors b
nonEmptyList key list_ validator accumulator =
    if List.isEmpty list_ then
        Err <| Dict.singleton key ("La liste '" ++ key ++ "' ne peut pas être vide.")

    else
        list key list_ validator accumulator


{-| Denote that validation should only be performed if a value is actually provided
-}
maybe : String -> Maybe a -> (a -> Result String a) -> Result Errors (Maybe a -> b) -> Result Errors b
maybe key maybeValue validator =
    maybeValue
        |> Maybe.map (validator >> Result.map Just)
        |> Maybe.withDefault (Ok Nothing)
        |> validate key


{-| Denote a required value to validate
-}
validate : String -> Result String a -> Result Errors (a -> b) -> Result Errors b
validate key result accumulator =
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


validateWithin : String -> { max : a, min : a, toNumber : a -> number, toString : a -> String } -> a -> Result String a
validateWithin what { max, min, toNumber, toString } value =
    if toNumber value < toNumber min || toNumber value > toNumber max then
        Err <|
            what
                ++ " doit être compris entre "
                ++ toString min
                ++ " et "
                ++ toString max
                ++ "."

    else
        Ok value
