module Data.Common.EncodeUtils exposing
    ( datetime
    , optionalPropertiesObject
    )

import DateFormat
import Json.Encode as Encode exposing (Value)
import Time exposing (Posix)


datetime : Posix -> Encode.Value
datetime =
    DateFormat.format "yyyy-MM-ddTHH:mm:ss.fffZ" Time.utc
        >> Encode.string


{-| Encode an object omitting properties for which a Nothing value is provided
-}
optionalPropertiesObject : List ( String, Maybe Value ) -> Value
optionalPropertiesObject =
    Encode.object
        << List.filterMap
            (\( key, maybeVal ) ->
                maybeVal |> Maybe.map (\val -> ( key, val ))
            )
