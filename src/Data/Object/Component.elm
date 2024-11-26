module Data.Object.Component exposing (Component)

import Data.Object.Process as Process exposing (Process)
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode


type Id
    = Id Uuid


type alias Component =
    { id : Id
    , name : String
    , processes : List ProcessItem
    , quantity : Quantity
    }


type alias ProcessItem =
    { amount : Amount
    , processId : Process.Id
    }


type Amount
    = Amount Float


type Quantity
    = Quantity Int


amountToFloat : Amount -> Float
amountToFloat (Amount float) =
    float


quantity : Int -> Quantity
quantity int =
    Quantity int


quantityToInt : Quantity -> Int
quantityToInt (Quantity int) =
    int


decode : Decoder Component
decode =
    Decode.succeed Component
        |> JDP.required "id" (Decode.map Id Uuid.decoder)
        |> JDP.required "name" Decode.string
        |> JDP.required "processes" (Decode.list decodeProcessItem)
        |> JDP.required "quantity" (Decode.map Quantity Decode.int)


decodeProcessItem : Decoder ProcessItem
decodeProcessItem =
    Decode.map2 ProcessItem
        (Decode.field "amount" (Decode.map Amount Decode.float))
        (Decode.field "process_id" Process.decodeId)
