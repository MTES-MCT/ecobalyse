module Data.Sector exposing
    ( Dict
    , GenericSector(..)
    , Sector(..)
    , all
    , allGeneric
    , anyOf
    , decode
    , decodeDict
    , decodeGeneric
    , dictGet
    , dictGetMaybe
    , encode
    , encodeGeneric
    , fromString
    , isGeneric
    , parse
    , parseGeneric
    , toGenericScope
    , toLabel
    , toString
    , toStringGeneric
    )

import Dict
import Dict.Any as AnyDict exposing (AnyDict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DE
import Json.Encode as Encode
import Url.Parser as Parser exposing (Parser)


type Sector
    = Food
    | Generic GenericSector
    | Textile


type GenericSector
    = Apparel
    | Food2
    | Object
    | Veli


{-| A dict where keys are typed as `Scope`
-}
type alias Dict a =
    AnyDict String Sector a


all : List Sector
all =
    -- Legacy scopes
    [ Food, Textile ]
        -- Generic scopes
        ++ List.map Generic allGeneric


allGeneric : List GenericSector
allGeneric =
    [ Apparel
    , Food2
    , Object
    , Veli
    ]


{-| Filter a list of scoped records against any passed allowed scopes
-}
anyOf : List Sector -> List { a | scopes : List Sector } -> List { a | scopes : List Sector }
anyOf scopes =
    List.filter <|
        .scopes
            >> List.any (\scope -> List.member scope scopes)


decode : Decoder Sector
decode =
    Decode.string
        |> Decode.andThen (fromString >> DE.fromResult)


decodeDict : Decoder a -> Decoder (Dict a)
decodeDict =
    AnyDict.decode_ (\key _ -> fromString key) toString


decodeGeneric : Decoder GenericSector
decodeGeneric =
    Decode.string
        |> Decode.andThen (fromStringGeneric >> DE.fromResult)


dictGet : Sector -> Dict a -> Maybe a
dictGet =
    AnyDict.get


dictGetMaybe : Sector -> Dict (Maybe a) -> Maybe a
dictGetMaybe scope dict =
    case dictGet scope dict of
        Just maybe ->
            maybe

        Nothing ->
            Nothing


encode : Sector -> Encode.Value
encode =
    toString >> Encode.string


encodeGeneric : GenericSector -> Encode.Value
encodeGeneric =
    toStringGeneric >> Encode.string


fromString : String -> Result String Sector
fromString string =
    case string of
        "food" ->
            Ok Food

        "textile" ->
            Ok Textile

        genericScopeString ->
            case fromStringGeneric genericScopeString of
                Err _ ->
                    Err <| "Couldn't decode unknown scope " ++ genericScopeString

                Ok genericScope ->
                    Ok (Generic genericScope)


fromStringGeneric : String -> Result String GenericSector
fromStringGeneric string =
    case Dict.get string genericNameDict of
        Just scope ->
            Ok scope

        Nothing ->
            Err <| "Couldn't decode unknown generic scope " ++ string


genericNameDict : Dict.Dict String GenericSector
genericNameDict =
    allGeneric
        |> List.foldl
            (\scope dict ->
                Dict.insert (toStringGeneric scope) scope dict
            )
            Dict.empty


isGeneric : Sector -> Bool
isGeneric scope =
    case scope of
        Generic _ ->
            True

        _ ->
            False


parse : Parser (Sector -> a) a
parse =
    Parser.custom "SCOPE" <|
        (fromString >> Result.toMaybe)


parseGeneric : Parser (GenericSector -> a) a
parseGeneric =
    Parser.custom "GENERIC_SCOPE" (fromStringGeneric >> Result.toMaybe)


toGenericScope : Sector -> Maybe GenericSector
toGenericScope scope =
    case scope of
        Generic genericScope ->
            Just genericScope

        _ ->
            Nothing


toLabel : Sector -> String
toLabel scope =
    case scope of
        Food ->
            "Alimentaire"

        Generic genericScope ->
            toLabelGeneric genericScope

        Textile ->
            "Textile"


toLabelGeneric : GenericSector -> String
toLabelGeneric genericScope =
    case genericScope of
        Apparel ->
            "Habillement"

        Food2 ->
            "Alimentaire BÉTA"

        Object ->
            "Objets"

        Veli ->
            "Véhicules"


toString : Sector -> String
toString scope =
    case scope of
        Food ->
            "food"

        Generic genericScope ->
            toStringGeneric genericScope

        Textile ->
            "textile"


toStringGeneric : GenericSector -> String
toStringGeneric genericScope =
    case genericScope of
        Apparel ->
            "apparel"

        Food2 ->
            "food2"

        Object ->
            "object"

        Veli ->
            "veli"
