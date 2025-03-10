module Data.Validation exposing
    ( Errors
    , accept
    , boundedList
    , check
    , encodeErrors
    , fromDecodingError
    , fromErrorString
    , list
    , maybe
    , nonEmptyList
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


{-| Skip validation for this value. This is useful when a value is supposed to have already
been validated, eg. by a JSON decoder.
-}
accept : String -> a -> Result Errors (a -> b) -> Result Errors b
accept key value =
    check key (Ok value)


{-| Validate the size of a list, with a required minimum and an optional maximum length.
-}
boundedList : Int -> Maybe Int -> FieldName -> List a -> (a -> Result ErrorMessage a) -> Result Errors (List a -> b) -> Result Errors b
boundedList min maybeMax key list_ validator accumulator =
    let
        max =
            Maybe.withDefault infinity maybeMax
    in
    if List.length list_ < min || List.length list_ > max then
        Err <|
            Dict.singleton key
                ("La liste '"
                    ++ key
                    ++ "' doit contenir "
                    ++ (if max /= infinity then
                            (if min /= 0 then
                                "entre " ++ String.fromInt min ++ " et "

                             else
                                ""
                            )
                                ++ String.fromInt max
                                ++ " élément(s) maximum."

                        else
                            String.fromInt min ++ " élément(s) minimum."
                       )
                )

    else
        list key list_ validator accumulator


{-| Validate a value for a given key, accumulating errors for that key.
-}
check : FieldName -> Result ErrorMessage a -> Result Errors (a -> b) -> Result Errors b
check key result accumulator =
    case ( result, accumulator ) of
        ( Ok _, Err errors ) ->
            Err errors

        ( Err error, Err errors ) ->
            errors
                |> Dict.union (Dict.singleton key error)
                |> Err

        ( valueOrError, Ok accFn ) ->
            valueOrError
                |> Result.mapError (Dict.singleton key)
                |> Result.map accFn


encodeErrors : Errors -> Encode.Value
encodeErrors =
    Encode.dict identity Encode.string


fromDecodingError : Decode.Error -> Errors
fromDecodingError =
    DecodeUtils.betterErrorToString >> Dict.singleton "decoding"


fromErrorString : String -> Errors
fromErrorString =
    Dict.singleton "general"


infinity : Int
infinity =
    -- yes, this should be built-in Elm
    round (1 / 0)


{-| Validate a list, reporting the first encountered element validation error.
-}
list : FieldName -> List a -> (a -> Result ErrorMessage a) -> Result Errors (List a -> b) -> Result Errors b
list key list_ validator =
    list_
        |> RE.combineMap validator
        |> check key


{-| Validate a value if one's actually provided
-}
maybe : FieldName -> Maybe a -> (a -> Result ErrorMessage a) -> Result Errors (Maybe a -> b) -> Result Errors b
maybe key maybeValue validator =
    maybeValue
        |> Maybe.map (validator >> Result.map Just)
        |> Maybe.withDefault (Ok Nothing)
        |> check key


{-| Validate a non-empty list
-}
nonEmptyList : FieldName -> List a -> (a -> Result ErrorMessage a) -> Result Errors (List a -> b) -> Result Errors b
nonEmptyList =
    boundedList 1 Nothing


{-| Generic helper for validating a bounded range
-}
validateWithin : String -> { max : a, min : a, toNumber : a -> number, toString : a -> String } -> a -> Result ErrorMessage a
validateWithin what { max, min, toNumber, toString } value =
    if toNumber value < toNumber min || toNumber value > toNumber max then
        Err <|
            what
                ++ " doit être compris(e) entre "
                ++ toString min
                ++ " et "
                ++ toString max
                ++ "."

    else
        Ok value
