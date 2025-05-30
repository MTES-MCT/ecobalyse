module Data.Scope exposing
    ( Scope(..)
    , all
    , allOf
    , anyOf
    , decode
    , encode
    , parse
    , toLabel
    , toString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Url.Parser as Parser exposing (Parser)


type Scope
    = Food
    | Object
    | Textile
    | Veli


all : List Scope
all =
    [ Food, Object, Textile, Veli ]


{-| Filter a list of scoped records against all passed allowed scopes
-}
allOf : List Scope -> List { a | scopes : List Scope } -> List { a | scopes : List Scope }
allOf scopes =
    List.filter <|
        .scopes
            >> List.all (\scope -> List.member scope scopes)


{-| Filter a list of scoped records against any passed allowed scopes
-}
anyOf : List Scope -> List { a | scopes : List Scope } -> List { a | scopes : List Scope }
anyOf scopes =
    List.filter <|
        .scopes
            >> List.any (\scope -> List.member scope scopes)


decode : Decoder Scope
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


encode : Scope -> Encode.Value
encode =
    toString >> Encode.string


fromString : String -> Result String Scope
fromString string =
    case string of
        "food" ->
            Ok Food

        "object" ->
            Ok Object

        "textile" ->
            Ok Textile

        "veli" ->
            Ok Veli

        _ ->
            Err <| "Couldn't decode unknown scope " ++ string


parse : Parser (Scope -> a) a
parse =
    Parser.custom "SCOPE" <|
        (fromString >> Result.toMaybe)


toLabel : Scope -> String
toLabel scope =
    case scope of
        Food ->
            "Alimentaire"

        Object ->
            "Objets"

        Textile ->
            "Textile"

        Veli ->
            "Véhicules intermédiaires"


toString : Scope -> String
toString scope =
    case scope of
        Food ->
            "food"

        Object ->
            "object"

        Textile ->
            "textile"

        Veli ->
            "veli"
