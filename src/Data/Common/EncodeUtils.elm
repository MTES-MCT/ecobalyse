module Data.Common.EncodeUtils exposing (optionalPropertiesObject)

import Json.Encode as Encode exposing (Value)


{-| Encode an object omitting properties for which a Nothing value is provided
-}
optionalPropertiesObject : List ( String, Maybe Value ) -> Value
optionalPropertiesObject =
    Encode.object
        << List.filterMap
            (\( key, maybeVal ) ->
                maybeVal |> Maybe.map (\val -> ( key, val ))
            )
