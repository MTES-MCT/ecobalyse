module Data.Matomo exposing (Stat, decodeStats)

import Dict
import Json.Decode as Decode exposing (Decoder)


type alias Stat =
    { label : String
    , hits : Int
    }


decodeStats : String -> Decoder (List Stat)
decodeStats key =
    Decode.dict (Decode.at [ key ] Decode.int)
        |> Decode.andThen
            (\dict ->
                dict
                    |> Dict.toList
                    |> List.map
                        (\( label, hits ) ->
                            { label = label, hits = hits }
                        )
                    |> Decode.succeed
            )
