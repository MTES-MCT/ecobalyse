module Data.Object.Query exposing
    ( Query
    , addComponentItem
    , b64encode
    , buildApiQuery
    , decode
    , default
    , encode
    , parseBase64Query
    , removeComponent
    , toString
    , updateComponentItemQuantity
    )

import Base64
import Data.Component as Component exposing (Component)
import Data.Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Result.Extra as RE
import Url.Parser as Parser exposing (Parser)


type alias Query =
    { components : List Component.Item
    }


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
        |> Pipe.required "components" (Decode.list Component.decodeItem)


default : Query
default =
    { components = [] }


encode : Query -> Encode.Value
encode query =
    Encode.object
        [ ( "components"
          , query.components
                |> Encode.list Component.encodeItem
          )
        ]


addComponentItem : Component.Id -> Query -> Query
addComponentItem id query =
    { query
        | components =
            query.components
                ++ [ { custom = Nothing, id = id, quantity = Component.quantityFromInt 1 } ]
    }


removeComponent : Component.Id -> Query -> Query
removeComponent id ({ components } as query) =
    { query
        | components =
            components
                |> List.filter (.id >> (/=) id)
    }


updateComponentItemQuantity : Component.Id -> Component.Quantity -> Query -> Query
updateComponentItemQuantity id quantity query =
    { query
        | components =
            query.components
                |> List.map
                    (\item ->
                        if item.id == id then
                            { item | quantity = quantity }

                        else
                            item
                    )
    }


toString : List Component -> List Process -> Query -> Result String String
toString components processes query =
    query.components
        |> RE.combineMap (Component.itemToString { components = components, processes = processes })
        |> Result.map (String.join ", ")



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
