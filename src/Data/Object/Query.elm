module Data.Object.Query exposing
    ( Query
    , addComponentItem
    , addElementTransform
    , b64encode
    , buildApiQuery
    , decode
    , default
    , encode
    , parseBase64Query
    , removeComponent
    , removeElementTransform
    , toString
    , updateComponentItemQuantity
    , updateElementAmount
    )

import Base64
import Data.Component as Component exposing (Component)
import Data.Process as Process exposing (Process)
import Data.Scope as Scope exposing (Scope)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import List.Extra as LE
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
    { query | components = query.components |> Component.addItem id }


addElementTransform : Component -> Int -> Process.Id -> Query -> Query
addElementTransform component index transformId query =
    { query
        | components =
            query.components
                |> Component.addElementTransform component index transformId
    }


removeComponent : Component.Id -> Query -> Query
removeComponent id ({ components } as query) =
    { query
        | components =
            components
                |> List.filter (.id >> (/=) id)
    }


removeElementTransform : Component -> Int -> Int -> Query -> Query
removeElementTransform component index transformIndex query =
    { query
        | components =
            query.components
                |> Component.updateElement component
                    index
                    (\el ->
                        { el | transforms = el.transforms |> LE.removeAt transformIndex }
                    )
    }


updateComponentItemQuantity : Component.Id -> Component.Quantity -> Query -> Query
updateComponentItemQuantity id quantity query =
    { query
        | components =
            query.components
                |> Component.updateItem id (\item -> { item | quantity = quantity })
    }


updateElementAmount : Component -> Int -> Component.Amount -> Query -> Query
updateElementAmount component index amount query =
    { query
        | components =
            query.components
                |> Component.updateElement component index (\el -> { el | amount = amount })
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
