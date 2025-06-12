module Data.Common.DecodeUtils exposing
    ( betterErrorToString
    , decodeExpected
    , decodeNonEmptyString
    , strictOptional
    , strictOptionalWithDefault
    )

import Json.Decode as Decode exposing (Decoder, Error)
import Json.Decode.Extra as DE


decodeNonEmptyString : Decoder String
decodeNonEmptyString =
    Decode.string
        |> Decode.andThen
            (\str ->
                if String.trim str == "" then
                    Decode.fail "String can't be empty"

                else
                    Decode.succeed <| String.trim str
            )


{-| Decode a value only if matching an expected one. Useful for oneOf
checks where we want to fail if the value is not the expected one.
-}
decodeExpected : Decoder a -> a -> Decoder a
decodeExpected decoder expected =
    decoder
        |> Decode.andThen
            (\decoded ->
                if decoded == expected then
                    Decode.succeed expected

                else
                    Decode.fail "Unmatched expected value"
            )


{-| A stricter Decode.maybe using Json.Decode.Extra's optionalField here because we want
a failure when a Maybe decoded field value is invalid, while we still want to treat `null`
as an acepted value.
-}
strictOptional : String -> Decoder a -> Decoder (Maybe a -> b) -> Decoder b
strictOptional field decoder =
    DE.andMap (DE.optionalNullableField field decoder)


{-| Same as `strictOptional` but accepting a default value
-}
strictOptionalWithDefault : String -> Decoder a -> a -> Decoder (a -> b) -> Decoder b
strictOptionalWithDefault field decoder default =
    DE.andMap
        (DE.optionalNullableField field decoder
            |> Decode.map (Maybe.withDefault default)
        )


{-| Prettify Json.Decode error strings
-}
betterErrorToString : Error -> String
betterErrorToString =
    Decode.errorToString
        >> String.replace "\n" " "
        >> replaceDoubleSpaces


replaceDoubleSpaces : String -> String
replaceDoubleSpaces string =
    if String.contains "  " string then
        string |> String.replace "  " " " |> replaceDoubleSpaces

    else
        string
