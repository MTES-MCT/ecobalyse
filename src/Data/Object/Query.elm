module Data.Object.Query exposing
    ( Amount
    , Item
    , Query
    , amount
    , amountToFloat
    , b64encode
    , decode
    , default
    , defaultItem
    , parseBase64Query
    , removeItem
    , updateItem
    )

import Base64
import Data.Object.Process as Process exposing (Process)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Url.Parser as Parser exposing (Parser)


type alias Query =
    { items : List Item
    }


type alias Item =
    { amount : Amount
    , processId : Process.Id
    }


type Amount
    = Amount Float


amount : Float -> Amount
amount =
    Amount


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


default : Query
default =
    { items = [] }


defaultItem : Process -> Item
defaultItem process =
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
        [ ( "amount", item.amount |> amountToFloat |> Encode.float )
        , ( "process_id", Process.encodeId item.processId )
        ]


removeItem : Process.Id -> Query -> Query
removeItem processId query =
    { query | items = query.items |> List.filter (.processId >> (/=) processId) }


updateItem : Item -> Query -> Query
updateItem newItem query =
    { query
        | items =
            query.items
                |> List.map
                    (\item ->
                        if item.processId == newItem.processId then
                            newItem

                        else
                            item
                    )
    }



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
