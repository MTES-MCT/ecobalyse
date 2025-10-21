module Data.Matomo exposing (Stat, decodeStats, encodeStats)

import Dict
import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Result.Extra as RE
import Time exposing (Posix)


type alias Stat =
    { hits : Int
    , label : String
    , time : Posix
    }


decodeStats : String -> Decoder (List Stat)
decodeStats key =
    Decode.dict
        (Decode.oneOf
            [ Decode.at [ key ] Decode.int

            -- When no data is available at a given date, assume no traffic
            , Decode.succeed 0
            ]
        )
        |> Decode.andThen
            (Dict.toList
                >> List.map
                    (\( label, hits ) ->
                        Ok Stat
                            |> RE.andMap (Ok hits)
                            |> RE.andMap (Ok label)
                            |> RE.andMap (Iso8601.toTime label)
                            |> Result.mapError (always ("Format de date invalide: " ++ label))
                    )
                >> RE.combine
                >> (\res ->
                        case res of
                            Err err ->
                                Decode.fail err

                            Ok list ->
                                Decode.succeed list
                   )
            )


encodeStats : List Stat -> String
encodeStats stats =
    stats
        |> Encode.list
            (\{ hits, time } ->
                -- The format for Highcharts' line chart is [[timestamp, value], …]
                Encode.list Encode.int [ Time.posixToMillis time, hits ]
            )
        |> Encode.encode 0
