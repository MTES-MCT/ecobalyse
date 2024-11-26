module Data.Object.Component exposing
    ( Amount
    , Component
    , ComponentItem
    , Id
    , ProcessItem
    , Quantity
    , amountToFloat
    , componentItemToString
    , decodeComponentItem
    , decodeList
    , encodeComponentItem
    , findById
    , quantityFromInt
    , quantityToInt
    )

import Data.Object.Process as Process exposing (Process)
import Data.Uuid as Uuid exposing (Uuid)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as Encode
import Result.Extra as RE


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


componentItemToString : List Component -> List Process -> ComponentItem -> Result String String
componentItemToString components processes componentItem =
    case findById componentItem.id components of
        Err err ->
            Err err

        Ok component ->
            component.processes
                |> RE.combineMap (processItemToString processes)
                |> Result.map (String.join " | ")
                |> Result.map
                    (\processesString ->
                        String.fromInt (quantityToInt componentItem.quantity)
                            ++ " "
                            ++ component.name
                            ++ " [ "
                            ++ processesString
                            ++ " ]"
                    )


processItemToString : List Process -> ProcessItem -> Result String String
processItemToString processes processItem =
    processItem.processId
        |> Process.findById processes
        |> Result.map
            (\process ->
                String.fromFloat (amountToFloat processItem.amount)
                    ++ process.unit
                    ++ " "
                    ++ process.displayName
            )


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


encodeComponentItem : ComponentItem -> Encode.Value
encodeComponentItem componentItem =
    Encode.object
        [ ( "id", componentItem.id |> idToString |> Encode.string )
        , ( "quantity", componentItem.quantity |> quantityToInt |> Encode.int )
        ]


findById : Id -> List Component -> Result String Component
findById id =
    List.filter (.id >> (==) id)
        >> List.head
        >> Result.fromMaybe ("Aucun composant avec id=" ++ idToString id)


idToString : Id -> String
idToString (Id uuid) =
    Uuid.toString uuid


quantityFromInt : Int -> Quantity
quantityFromInt int =
    Quantity int


quantityToInt : Quantity -> Int
quantityToInt (Quantity int) =
    int
