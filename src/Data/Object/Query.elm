module Data.Object.Query exposing
    ( Amount
    , Item
    , Query
    , amount
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
import Json.Encode as Encode
import Result.Extra as RE
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


toString : List Process -> Query -> Result String String
toString processes =
    .items
        >> List.map
            (\item ->
                item.processId
                    |> Process.findById processes
                    |> Result.map
                        (\process ->
                            String.fromFloat (amountToFloat item.amount)
                                ++ process.unit
                                ++ " "
                                ++ process.displayName
                        )
            )
        >> RE.combine
        >> Result.map (String.join ", ")



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
