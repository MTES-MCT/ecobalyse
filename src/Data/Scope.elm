module Data.Scope exposing
    ( Scope(..)
    , decode
    , encode
    , only
    , parseSlug
    , toLabel
    , toString
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Url.Parser as Parser exposing (Parser)


type Scope
    = Food
    | Textile


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
        "textile" ->
            Ok Textile

        "food" ->
            Ok Food

        _ ->
            Err <| "Couldn't decode unknown scope " ++ string


only : Scope -> List { a | scopes : List Scope } -> List { a | scopes : List Scope }
only scope =
    List.filter (.scopes >> List.member scope)


parseSlug : Parser (Scope -> a) a
parseSlug =
    Parser.custom "SCOPE" <|
        (fromString >> Result.toMaybe)


toLabel : Scope -> String
toLabel scope =
    case scope of
        Food ->
            "Alimentaire"

        Textile ->
            "Textile"


toString : Scope -> String
toString scope =
    case scope of
        Food ->
            "food"

        Textile ->
            "textile"
