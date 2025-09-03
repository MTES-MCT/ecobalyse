module Data.Object.Query exposing
    ( Query
    , attemptUpdateComponents
    , b64encode
    , buildApiQuery
    , decode
    , default
    , encode
    , parseBase64Query
    , updateComponents
    , updateDurability
    )

import Base64
import Data.Component as Component exposing (Item)
import Data.Scope as Scope exposing (Scope)
import Data.Unit as Unit exposing (Ratio)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipe
import Json.Encode as Encode
import Url.Parser as Parser exposing (Parser)


type alias Query =
    { components : List Item

    -- Note: component durability is experimental, future work may eventually be needed to
    -- reuse existing mechanics and handle holistic durability like it's implemented for textile,
    -- though it's still an ongoing discussion and we need to move forward and iterate.
    , durability : Ratio
    }


{-| Update a list of component items that may fail
-}
attemptUpdateComponents : (List Item -> Result String (List Item)) -> Query -> Result String Query
attemptUpdateComponents fn query =
    fn query.components
        |> Result.map (\components -> { query | components = components })


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
        |> Pipe.optional "durability" Unit.decodeRatio (Unit.ratio 1)


default : Query
default =
    { components = []
    , durability = Unit.ratio 1
    }


encode : Query -> Encode.Value
encode query =
    Encode.object
        [ ( "components", query.components |> Encode.list Component.encodeItem )
        , ( "durability", query.durability |> Unit.encodeRatio )
        ]


updateComponents : (List Item -> List Item) -> Query -> Query
updateComponents fn query =
    { query | components = fn query.components }


updateDurability : Unit.Ratio -> Query -> Query
updateDurability durability query =
    { query | durability = durability }



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
