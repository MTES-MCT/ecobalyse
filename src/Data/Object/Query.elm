module Data.Object.Query exposing
    ( Query
    , addComponentItem
    , addElement
    , addElementTransform
    , b64encode
    , buildApiQuery
    , decode
    , default
    , encode
    , parseBase64Query
    , removeComponent
    , removeElement
    , removeElementTransform
    , setElementMaterial
    , toString
    , updateComponentItemName
    , updateComponentItemQuantity
    , updateElementAmount
    )

import Base64
import Data.Component as Component exposing (Component)
import Data.Process exposing (Process)
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


addElement : Component -> Int -> Process -> Query -> Result String Query
addElement component componentIndex material query =
    query.components
        |> Component.addElement component componentIndex material
        |> Result.map (\components -> { query | components = components })


addElementTransform : Component -> Int -> Int -> Process -> Query -> Result String Query
addElementTransform component componentIndex elementIndex transform query =
    query.components
        |> Component.addElementTransform component componentIndex elementIndex transform
        |> Result.map (\components -> { query | components = components })


removeComponent : Int -> Query -> Query
removeComponent componentIndex ({ components } as query) =
    { query
        | components =
            components
                |> LE.removeAt componentIndex
    }


removeElement : Component -> Int -> Int -> Query -> Result String Query
removeElement component componentIndex elementIndex query =
    query.components
        |> Component.removeElement component componentIndex elementIndex
        |> Result.map (\components -> { query | components = components })


removeElementTransform : Component -> Int -> Int -> Int -> Query -> Query
removeElementTransform component componentIndex elementIndex transformIndex query =
    { query
        | components =
            query.components
                |> Component.removeElementTransform component componentIndex elementIndex transformIndex
    }


setElementMaterial : Component -> Int -> Int -> Process -> Query -> Result String Query
setElementMaterial component componentIndex elementIndex material query =
    query.components
        |> Component.setElementMaterial component componentIndex elementIndex material
        |> Result.map (\components -> { query | components = components })


updateComponentItemName : Component -> Int -> String -> Query -> Query
updateComponentItemName component componentIndex name query =
    { query
        | components =
            query.components
                |> Component.updateItemCustomName component componentIndex name
    }


updateComponentItemQuantity : Int -> Component.Quantity -> Query -> Query
updateComponentItemQuantity componentIndex quantity query =
    { query
        | components =
            query.components
                |> Component.updateItem componentIndex (\item -> { item | quantity = quantity })
    }


updateElementAmount : Component -> Int -> Int -> Component.Amount -> Query -> Query
updateElementAmount component componentIndex elementIndex amount query =
    { query
        | components =
            query.components
                |> Component.updateElement component
                    componentIndex
                    elementIndex
                    (\el -> { el | amount = amount })
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
