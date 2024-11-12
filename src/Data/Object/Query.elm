module Data.Object.Query exposing
    ( Amount
    , Item
    , ProcessItem
    , Query
    , amountToFloat
    , b64encode
    , buildApiQuery
    , decode
    , default
    , defaultItem
    , encode
    , parseBase64Query
    , removeItem
    , toString
    , updateItem
    )

import Base64
import Data.Object.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Result.Extra as RE
import Url.Parser as Parser exposing (Parser)


type alias Query =
    { items : List Item
    }


type alias Item =
    { name : String
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


quantityToInt : Quantity -> Int
quantityToInt (Quantity int) =
    int


buildApiQuery : Scope -> String -> Query -> String
buildApiQuery scope clientUrl query =
    """curl -sS -X POST %apiUrl% \\
  -H "accept: application/json" \\
  -H "content-type: application/json" \\
  -d '%json%'
"""
        |> String.replace "%apiUrl%" (clientUrl ++ "api/" ++ Scope.toString scope ++ "/simulator")
        |> String.replace "%json%" (encode query |> Encode.encode 0)


decode : Decoder Query
decode =
    Decode.succeed Query
        |> Pipe.required "items" (Decode.list decodeItem)


decodeItem : Decoder Item
decodeItem =
    Decode.map3 Item
        (Decode.field "name" Decode.string)
        (Decode.field "processes" (Decode.list decodeProcessItem))
        (Decode.field "quantity" (Decode.map Quantity Decode.int))


decodeProcessItem : Decoder ProcessItem
decodeProcessItem =
    Decode.map2 ProcessItem
        (Decode.field "amount" (Decode.map Amount Decode.float))
        (Decode.field "process_id" Process.decodeId)


default : Query
default =
    { items = [] }


defaultItem : Process -> Item
defaultItem process =
    { name = "Composant par défaut"
    , processes = [ defaultProcessItem process ]
    , quantity = Quantity 1
    }


defaultProcessItem : Process -> ProcessItem
defaultProcessItem process =
    { amount = Amount 1, processId = process.id }


encode : Query -> Encode.Value
encode query =
    Encode.object
        [ ( "processes"
          , Encode.list encodeItem query.items
          )
        ]


encodeItem : Item -> Encode.Value
encodeItem item =
    Encode.object
        [ ( "name", item.name |> Encode.string )
        , ( "processes", item.processes |> Encode.list encodeProcessItem )
        , ( "qantity", item.quantity |> quantityToInt |> Encode.int )
        ]


encodeProcessItem : ProcessItem -> Encode.Value
encodeProcessItem processItem =
    Encode.object
        [ ( "amount", processItem.amount |> amountToFloat |> Encode.float )
        , ( "process_id", Process.encodeId processItem.processId )
        ]


removeProcessItem : Process.Id -> List ProcessItem -> List ProcessItem
removeProcessItem processId processes =
    processes |> List.filter (.processId >> (/=) processId)


removeItem : Process.Id -> Query -> Query
removeItem processId query =
    -- FIX: implement it for components
    query


updateItem : Item -> Query -> Query
updateItem newItem query =
    -- FIX: implement it for components
    query


updateProcessItem : ProcessItem -> List ProcessItem -> List ProcessItem
updateProcessItem newItem processes =
    processes
        |> List.map
            (\item ->
                if item.processId == newItem.processId then
                    newItem

                else
                    item
            )


toString : List Process -> Query -> Result String String
toString processes =
    .items
        >> RE.combineMap (itemToString processes)
        >> Result.map (String.join ", ")


itemToString : List Process -> Item -> Result String String
itemToString processes item =
    item.processes
        |> RE.combineMap (processItemToString processes)
        |> Result.map (String.join " | ")
        |> Result.map (\processesString -> String.fromInt (quantityToInt item.quantity) ++ " " ++ item.name ++ " [ " ++ processesString ++ " ]")


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



-- Parser


b64decode : String -> Result String Query
b64decode =
    Base64.decode
        >> Result.andThen
            (Decode.decodeString decode
                >> Result.mapError Decode.errorToString
            )


b64encode : Query -> String
b64encode =
    encode >> Encode.encode 0 >> Base64.encode


parseBase64Query : Parser (Maybe Query -> a) a
parseBase64Query =
    Parser.custom "QUERY" <|
        b64decode
            >> Result.toMaybe
            >> Just
