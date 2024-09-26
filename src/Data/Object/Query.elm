module Data.Object.Query exposing
    ( Amount
    , Item
    , Query
    , amountToFloat
    , decode
    )

import Data.Object.Process as Process
import Json.Decode as Decode exposing (Decoder)


type alias Query =
    { items : List Item
    }


type alias Item =
    { amount : Amount
    , processId : Process.Id
    }


type Amount
    = Amount Float


amountToFloat : Amount -> Float
amountToFloat (Amount float) =
    float


decode : Decoder Query
decode =
    Decode.map Query
        (Decode.field "processes" (Decode.list decodeItem))


decodeItem : Decoder Item
decodeItem =
    Decode.map2 Item
        (Decode.field "amount" (Decode.map Amount Decode.float))
        (Decode.field "process_id" Process.decodeId)
