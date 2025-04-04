module Data.Object.Query exposing
    ( Query
    , b64encode
    , buildApiQuery
    , decode
    , default
    , encode
    , parseBase64Query
    , updateComponents
    , updateFromResults
    )

import Base64
import Data.Component as Component exposing (Item)
import Data.Scope as Scope exposing (Scope)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Url.Parser as Parser exposing (Parser)


type alias Query =
    { components : List Item
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


updateComponents : (List Item -> List Item) -> Query -> Query
updateComponents fn query =
    { query | components = fn query.components }


updateFromResults : (List Item -> Result String (List Item)) -> Query -> Result String Query
updateFromResults fn query =
    fn query.components
        |> Result.map (\components -> { query | components = components })



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
