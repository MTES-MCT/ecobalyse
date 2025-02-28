module Data.Common.DecodeUtils exposing
    ( betterErrorToString
    , strictOptional
    )

import Json.Decode as Decode exposing (Decoder, Error)
import Json.Decode.Extra as DE


{-| A stricter Decode.maybe using Json.Decode.Extra's optionalField here because we want
a failure when a Maybe decoded field value is invalid, while we still want to treat `null`
as an acepted value.
-}
strictOptional : String -> Decoder a -> Decoder (Maybe a -> b) -> Decoder b
strictOptional field decoder =
    DE.andMap (DE.optionalNullableField field decoder)


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
