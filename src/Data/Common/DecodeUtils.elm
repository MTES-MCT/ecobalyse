module Data.Common.DecodeUtils exposing (strictOptional)

import Json.Decode exposing (Decoder)
import Json.Decode.Extra as DE


{-| A stricter Decode.maybe using Json.Decode.Extra's optionalField here because we want
a failure when a Maybe decoded field value is invalid, while we still want to treat `null`
as an acepted value.
-}
strictOptional : String -> Decoder a -> Decoder (Maybe a -> b) -> Decoder b
strictOptional field decoder =
    DE.andMap (DE.optionalNullableField field decoder)
