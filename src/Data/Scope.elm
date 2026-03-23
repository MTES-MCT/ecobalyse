module Data.Scope exposing
    ( Dict
    , GenericScope(..)
    , Scope(..)
    , all
    , anyOf
    , decode
    , decodeDict
    , dictGet
    , encode
    , fromString
    , isGeneric
    , parse
    , toLabel
    , toString
    )

import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Url.Parser as Parser exposing (Parser)


type Scope
    = Food
    | Generic GenericScope
    | Textile


type GenericScope
    = Food2
    | Object
    | Veli


{-| A dict where keys are typed as `Scope`
-}
type alias Dict a =
    AnyDict String Scope a


all : List Scope
all =
    [ Food
    , Generic Food2
    , Generic Object
    , Generic Veli
    , Textile
    ]


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


decodeDict : Decoder a -> Decoder (Dict a)
decodeDict =
    AnyDict.decode_ (\key _ -> fromString key) toString


dictGet : Scope -> Dict a -> Maybe a
dictGet scope =
    AnyDict.get scope


encode : Scope -> Encode.Value
encode =
    toString >> Encode.string


fromString : String -> Result String Scope
fromString string =
    case string of
        "food" ->
            Ok Food

        "food2" ->
            Ok (Generic Food2)

        "object" ->
            Ok (Generic Object)

        "textile" ->
            Ok Textile

        "veli" ->
            Ok (Generic Veli)

        _ ->
            Err <| "Couldn't decode unknown scope " ++ string


isGeneric : Scope -> Bool
isGeneric scope =
    case scope of
        Generic _ ->
            True

        _ ->
            False


parse : Parser (Scope -> a) a
parse =
    Parser.custom "SCOPE" <|
        (fromString >> Result.toMaybe)


toLabel : Scope -> String
toLabel scope =
    case scope of
        Food ->
            "Alimentaire"

        Generic Food2 ->
            "Alimentaire²"

        Generic Object ->
            "Objets"

        Generic Veli ->
            "Véhicules"

        Textile ->
            "Textile"


toString : Scope -> String
toString scope =
    case scope of
        Food ->
            "food"

        Generic Food2 ->
            "food2"

        Generic Object ->
            "object"

        Generic Veli ->
            "veli"

        Textile ->
            "textile"
