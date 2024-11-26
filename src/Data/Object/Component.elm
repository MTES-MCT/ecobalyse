module Data.Object.Component exposing
    ( Component
    , ComponentItem
    , ProcessItem
    , amountToFloat
    , decodeList
    , quantityToInt
    )

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
    }


type alias ComponentItem =
    { id : Id
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


decode : Decoder Component
decode =
    Decode.succeed Component
        |> JDP.required "id" (Decode.map Id Uuid.decoder)
        |> JDP.required "name" Decode.string
        |> JDP.required "processes" (Decode.list decodeProcessItem)


decodeList : Decoder (List Component)
decodeList =
    Decode.list decode


decodeComponentItem : Decoder ComponentItem
decodeComponentItem =
    Decode.succeed ComponentItem
        |> JDP.required "id" (Decode.map Id Uuid.decoder)
        |> JDP.required "quantity" (Decode.map Quantity Decode.int)


decodeProcessItem : Decoder ProcessItem
decodeProcessItem =
    Decode.map2 ProcessItem
        (Decode.field "amount" (Decode.map Amount Decode.float))
        (Decode.field "process_id" Process.decodeId)


encode : Component -> Encode.Value
encode item =
    Encode.object
        [ ( "id", item.id |> extractUuid |> Uuid.encoder )
        , ( "name", item.name |> Encode.string )
        , ( "processes", item.processes |> Encode.list encodeProcessItem )
        ]


encodeComponentItem : ComponentItem -> Encode.Value
encodeComponentItem componentItem =
    Encode.object
        [ ( "id", componentItem.id |> idToString |> Encode.string )
        , ( "quantity", componentItem.quantity |> quantityToInt |> Encode.int )
        ]


encodeProcessItem : ProcessItem -> Encode.Value
encodeProcessItem processItem =
    Encode.object
        [ ( "amount", processItem.amount |> amountToFloat |> Encode.float )
        , ( "process_id", Process.encodeId processItem.processId )
        ]


extractUuid : Id -> Uuid
extractUuid (Id uuid) =
    uuid


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


quantity : Int -> Quantity
quantity int =
    Quantity int


quantityToInt : Quantity -> Int
quantityToInt (Quantity int) =
    int
