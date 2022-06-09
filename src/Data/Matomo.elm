module Data.Matomo exposing (Stat, decodeStats, encodeStats)

import Dict
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Result.Extra as RE
import Time exposing (Posix)


type alias Stat =
    { label : String
    , hits : Int
    , time : Posix
    }


decodeStats : String -> Decoder (List Stat)
decodeStats key =
    Decode.dict (Decode.at [ key ] Decode.int)
        |> Decode.andThen
            (Dict.toList
                >> List.map
                    (\( label, hits ) ->
                        Iso8601.toTime label
                            |> Result.map (Stat label hits)
                            |> Result.mapError (always ("Format de date invalide: " ++ label))
                    )
                >> RE.combine
                >> (\res ->
                        case res of
                            Ok list ->
                                Decode.succeed list

                            Err err ->
                                Decode.fail err
                   )
            )


encodeStats : List Stat -> String
encodeStats stats =
    stats
        |> Encode.list
            (\{ time, hits } ->
                -- The format for Highcharts' line chart is [[timestamp, value], …]
                Encode.list Encode.int [ Time.posixToMillis time, hits ]
            )
        |> Encode.encode 0
