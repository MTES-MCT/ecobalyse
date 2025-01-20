module Data.Scope exposing
    ( Scope(..)
    , decode
    , encode
    , only
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


only :
    List Scope
    -> List { a | scopes : List Scope }
    -> List { a | scopes : List Scope }
only scopes =
    List.filter <|
        .scopes
            >> List.any (\scope -> List.member scope scopes)


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
