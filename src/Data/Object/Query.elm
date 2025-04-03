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
import Data.Component as Component exposing (Component, TargetElement, TargetItem)
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


addElement : TargetItem -> Process -> Query -> Result String Query
addElement ( component, itemIndex ) material query =
    query.components
        |> Component.addElement ( component, itemIndex ) material
        |> Result.map (\components -> { query | components = components })


addElementTransform : TargetElement -> Process -> Query -> Result String Query
addElementTransform ( ( component, itemIndex ), elementIndex ) transform query =
    query.components
        |> Component.addElementTransform ( ( component, itemIndex ), elementIndex ) transform
        |> Result.map (\components -> { query | components = components })


removeComponent : Int -> Query -> Query
removeComponent itemIndex ({ components } as query) =
    { query
        | components =
            components
                |> LE.removeAt itemIndex
    }


removeElement : TargetElement -> Query -> Result String Query
removeElement ( ( component, itemIndex ), elementIndex ) query =
    query.components
        |> Component.removeElement ( ( component, itemIndex ), elementIndex )
        |> Result.map (\components -> { query | components = components })


removeElementTransform : TargetElement -> Int -> Query -> Query
removeElementTransform ( ( component, itemIndex ), elementIndex ) transformIndex query =
    { query
        | components =
            query.components
                |> Component.removeElementTransform ( ( component, itemIndex ), elementIndex ) transformIndex
    }


setElementMaterial : TargetElement -> Process -> Query -> Result String Query
setElementMaterial ( ( component, itemIndex ), elementIndex ) material query =
    query.components
        |> Component.setElementMaterial ( ( component, itemIndex ), elementIndex ) material
        |> Result.map (\components -> { query | components = components })


updateComponentItemName : TargetItem -> String -> Query -> Query
updateComponentItemName targetItem name query =
    { query
        | components =
            query.components
                |> Component.updateItemCustomName targetItem name
    }


updateComponentItemQuantity : Int -> Component.Quantity -> Query -> Query
updateComponentItemQuantity itemIndex quantity query =
    { query
        | components =
            query.components
                |> Component.updateItem itemIndex (\item -> { item | quantity = quantity })
    }


updateElementAmount : TargetElement -> Component.Amount -> Query -> Query
updateElementAmount targetElement amount query =
    { query
        | components =
            query.components
                |> Component.updateElement targetElement (\el -> { el | amount = amount })
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
